import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/services/gif_frames.dart';
import 'package:Fern/features/recognition/domain/services/frame_sampling.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Saca a disco los fotogramas de un GIF que hay que reconocer.
///
/// Un GIF no se abre con el reproductor de vídeo aunque se mueva: `GifFrames` lo
/// descodifica entero en otro hilo y devuelve todos sus fotogramas de una vez,
/// con sus tiempos. Es más rápido, no bloquea el dibujado, y da la duración de
/// verdad en vez de la que libmpv deduzca.
///
/// El sidecar lee de disco, así que hay que escribirlos. Se guardan en la misma
/// carpeta temporal que las miniaturas de vídeo y con la ruta y la fecha del
/// fichero en la clave: si el GIF cambia, los fotogramas viejos dejan de valer
/// solos.
class GifFrameExtractor {
  Directory? _directory;

  /// El último GIF descodificado.
  ///
  /// Se guarda uno porque la duración y los fotogramas se piden **seguidos y
  /// del mismo fichero**: primero cuánto dura, para repartir las miradas, y
  /// luego los fotogramas de esos momentos. Sin esto se descodifica dos veces.
  String? _lastPath;
  GifFrames? _lastGif;

  /// Cuánto dura el GIF de [path], o `null` si no es uno animado.
  Future<Duration?> durationOf(String path) async => (await _gifAt(path))?.total;

  Future<GifFrames?> _gifAt(String path) async {
    if (_lastPath == path) return _lastGif;

    final gif = await GifFrames.load(path);

    _lastPath = path;
    _lastGif = gif;

    return gif;
  }

  /// Los fotogramas de [path] que cubren [moments], por momento.
  ///
  /// Dos momentos que caigan en el mismo fotograma dan **uno**: mirar dos veces
  /// la misma imagen es pagar dos predicciones por una respuesta que ya se
  /// tenía. El momento con el que vuelve es el de inicio del fotograma, que es
  /// el que hay que apuntar en la detección.
  Future<Map<Duration, String>> extract(
    String path,
    List<Duration> moments,
  ) async {
    if (moments.isEmpty) return const {};

    final gif = await _gifAt(path);
    if (gif == null || gif.isEmpty) return const {};

    final directory = await _ensureDirectory();
    final stat = File(path).statSync();
    final frames = <Duration, String>{};

    for (final index in distinctFrames(moments, gif.indexAt)) {
      final file = File(p.join(
        directory.path,
        '${_keyOf(path, stat, index)}.png',
      ));

      try {
        // Lo ya escrito no se reescribe: reconocer el mismo GIF dos veces no
        // tiene por qué volver a tocar el disco.
        if (!file.existsSync()) {
          await file.writeAsBytes(gif.frames[index], flush: true);
        }

        frames[gif.starts[index]] = file.path;
      } on Object catch (error) {
        debugPrint('GifFrameExtractor: no se pudo escribir "$path": $error');
      }
    }

    return frames;
  }

  String _keyOf(String path, FileStat stat, int index) {
    final seed = '$path|${stat.size}|${stat.modified.millisecondsSinceEpoch}'
        '|gif|$index';

    return md5.convert(seed.codeUnits).toString();
  }

  Future<Directory> _ensureDirectory() async {
    final cached = _directory;
    if (cached != null) return cached;

    final temp = await getTemporaryDirectory();
    final directory = Directory(p.join(temp.path, videoThumbnailFolder));
    if (!directory.existsSync()) directory.createSync(recursive: true);

    return _directory = directory;
  }
}
