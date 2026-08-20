import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import '../utils/media_type.dart';

/// Datos necesarios para pintar un fichero multimedia en la rejilla sin tener
/// que decodificarlo entero: proporciones reales, duración (vídeos) y la ruta
/// de la miniatura extraída (vídeos).
@immutable
class MediaPreview {
  /// Ancho intrínseco en píxeles. `null` si no se ha podido determinar.
  final int? width;

  /// Alto intrínseco en píxeles. `null` si no se ha podido determinar.
  final int? height;

  /// Duración del vídeo. `null` para imágenes y GIFs.
  final Duration? duration;

  /// Fotograma extraído del vídeo, cacheado en disco. `null` para imágenes.
  final String? thumbnailPath;

  const MediaPreview({
    this.width,
    this.height,
    this.duration,
    this.thumbnailPath,
  });

  /// Proporción ancho/alto, o `null` si se desconoce.
  double? get aspectRatio {
    if (width == null || height == null) return null;
    if (width! <= 0 || height! <= 0) return null;
    return width! / height!;
  }
}

/// Resuelve (y cachea) la información de previsualización de cada fichero.
///
/// - Imágenes y GIFs: lee sólo la cabecera del fichero, sin decodificar el
///   bitmap completo, para conocer sus dimensiones reales.
/// - Vídeos: extrae un fotograma y la duración con `media_kit` (libmpv), que es
///   el único backend con soporte en Windows. El resultado se guarda en el
///   directorio temporal para no repetir el trabajo en siguientes arranques.
class MediaPreviewService {
  MediaPreviewService._();

  static final MediaPreviewService instance = MediaPreviewService._();

  final Map<String, MediaPreview> _cache = {};
  final Map<String, Future<MediaPreview?>> _pending = {};
  final List<Completer<void>> _waiting = [];

  int _runningVideoJobs = 0;
  Directory? _thumbnailDir;

  /// Clave con la que se guarda una previsualización.
  ///
  /// El fotograma pedido forma parte de ella: sin eso, la miniatura de la
  /// región marcada en el segundo doce se pisaría con la del segundo uno, y las
  /// celdas de la rejilla de fernies enseñarían todas el mismo fotograma.
  String _key(String path, Duration? frame) =>
      frame == null ? path : '$path|${frame.inMilliseconds}';

  /// Previsualización ya resuelta, si la hay. Permite pintar el primer
  /// fotograma sin parpadeos cuando la rejilla reconstruye un elemento.
  MediaPreview? peek(String path, {Duration? frame}) => _cache[_key(path, frame)];

  /// Resuelve la previsualización, reutilizando la petición en curso si el
  /// mismo fichero se pide desde varios sitios a la vez.
  ///
  /// Con [frame] se saca el fotograma de ese instante en vez del de por
  /// defecto. Es lo que necesitan las regiones marcadas sobre vídeo y GIF, que
  /// llevan apuntado de qué momento son.
  Future<MediaPreview?> load(String path, {Duration? frame}) {
    final key = _key(path, frame);

    final cached = _cache[key];
    if (cached != null) return Future.value(cached);

    return _pending.putIfAbsent(key, () async {
      try {
        final preview = path.isVideoPath
            ? await _loadVideo(path, frame: frame)
            : await _loadImage(path);
        if (preview != null) _cache[key] = preview;
        return preview;
      } catch (e) {
        debugPrint('MediaPreviewService: no se pudo procesar "$path": $e');
        return null;
      } finally {
        _pending.remove(key);
      }
    });
  }

  Future<MediaPreview?> _loadImage(String path) async {
    final buffer = await ui.ImmutableBuffer.fromFilePath(path);
    try {
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      final preview =
          MediaPreview(width: descriptor.width, height: descriptor.height);
      descriptor.dispose();
      return preview;
    } finally {
      buffer.dispose();
    }
  }

  Future<MediaPreview?> _loadVideo(String path, {Duration? frame}) async {
    final file = File(path);
    if (!file.existsSync()) return null;

    final directory = await _ensureThumbnailDir();
    final key = _cacheKey(path, file.statSync(), frame);
    final thumbnail = File(p.join(directory.path, '$key.jpg'));
    final metadata = File(p.join(directory.path, '$key.json'));

    final fromDisk = await _readFromDisk(thumbnail, metadata);
    if (fromDisk != null) return fromDisk;

    await _acquireSlot();
    try {
      return await _extractVideoPreview(path, thumbnail, metadata, frame);
    } finally {
      _releaseSlot();
    }
  }

  Future<MediaPreview?> _readFromDisk(File thumbnail, File metadata) async {
    if (!thumbnail.existsSync() || !metadata.existsSync()) return null;
    try {
      final json =
          jsonDecode(await metadata.readAsString()) as Map<String, dynamic>;
      return MediaPreview(
        width: json['width'] as int?,
        height: json['height'] as int?,
        duration: Duration(milliseconds: json['durationMs'] as int? ?? 0),
        thumbnailPath: thumbnail.path,
      );
    } catch (_) {
      return null;
    }
  }

  Future<MediaPreview?> _extractVideoPreview(
    String path,
    File thumbnail,
    File metadata,
    Duration? frame,
  ) async {
    final player = Player(
      configuration: const PlayerConfiguration(
        muted: true,
        logLevel: MPVLogLevel.error,
      ),
    );
    // El controlador es imprescindible aunque no se pinte: sin salida de vídeo
    // libmpv no decodifica el fotograma que queremos capturar.
    final controller = VideoController(player);

    try {
      await player.open(Media(path), play: false);

      final duration = await player.stream.duration
          .firstWhere((value) => value > Duration.zero)
          .timeout(videoProbeTimeout, onTimeout: () => Duration.zero);

      await player.stream.width
          .firstWhere((value) => value != null && value > 0)
          .timeout(videoProbeTimeout, onTimeout: () => null);

      // El fotograma pedido manda, y si se sale del vídeo se recorta a su
      // final: una región marcada sobre un fichero que luego se ha recortado no
      // debe dejar la miniatura en negro.
      final wanted = frame ?? videoThumbnailSeek;
      final seek = duration > wanted ? wanted : Duration.zero;
      await player.seek(seek);

      final platform = await controller.platform.future;
      await platform.waitUntilFirstFrameRendered
          .timeout(videoProbeTimeout, onTimeout: () {});

      final bytes = await _screenshot(player);
      if (bytes != null) {
        await thumbnail.writeAsBytes(bytes, flush: true);
      }

      final preview = MediaPreview(
        width: player.state.width,
        height: player.state.height,
        duration: duration,
        thumbnailPath: bytes != null ? thumbnail.path : null,
      );

      if (bytes != null) {
        await metadata.writeAsString(jsonEncode({
          'width': preview.width,
          'height': preview.height,
          'durationMs': duration.inMilliseconds,
        }));
      }

      return preview;
    } finally {
      // `Player.dispose()` libera también el [VideoController] asociado.
      await player.dispose();
    }
  }

  Future<Uint8List?> _screenshot(Player player) async {
    for (var attempt = 0; attempt < videoScreenshotAttempts; attempt++) {
      final bytes = await player.screenshot();
      if (bytes != null && bytes.isNotEmpty) return bytes;
      await Future.delayed(videoScreenshotRetryDelay);
    }
    return null;
  }

  /// La clave del fichero en disco. Lleva el fotograma dentro por lo mismo que
  /// [_key]: dos fotogramas del mismo vídeo no pueden compartir miniatura.
  String _cacheKey(String path, FileStat stat, Duration? frame) {
    final seed = '$path|${stat.size}|${stat.modified.millisecondsSinceEpoch}'
        '|${frame?.inMilliseconds ?? 0}';
    return md5.convert(utf8.encode(seed)).toString();
  }

  Future<Directory> _ensureThumbnailDir() async {
    final cached = _thumbnailDir;
    if (cached != null) return cached;

    final temp = await getTemporaryDirectory();
    final directory = Directory(p.join(temp.path, videoThumbnailFolder));
    if (!directory.existsSync()) directory.createSync(recursive: true);
    return _thumbnailDir = directory;
  }

  Future<void> _acquireSlot() {
    if (_runningVideoJobs < maxConcurrentVideoJobs) {
      _runningVideoJobs++;
      return Future.value();
    }
    final completer = Completer<void>();
    _waiting.add(completer);
    return completer.future;
  }

  void _releaseSlot() {
    if (_waiting.isNotEmpty) {
      _waiting.removeAt(0).complete();
      return;
    }
    _runningVideoJobs--;
  }
}
