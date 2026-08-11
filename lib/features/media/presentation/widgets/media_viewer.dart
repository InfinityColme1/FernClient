import 'dart:async';
import 'dart:io';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaViewer extends StatefulWidget {
  final String path;

  /// Se invoca, una sola vez por fichero, cuando el contenido no se ha podido
  /// abrir. Quien lo escuche decide qué hacer con el contenido.
  final VoidCallback? onLoadFailed;

  const MediaViewer({
    super.key,
    required this.path,
    this.onLoadFailed,
  });

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  Player? _player;
  VideoController? _controller;
  StreamSubscription<String>? _errorSubscription;

  /// Evita repetir el aviso de fallo mientras se esté enseñando el mismo
  /// fichero: reproducir un vídeo roto puede dar varios errores seguidos.
  bool _loadFailureReported = false;

  bool get _isVideo => widget.path.isVideoPath;

  @override
  void initState() {
    super.initState();
    if (_isVideo) _initVideo();
  }

  @override
  void didUpdateWidget(covariant MediaViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path == widget.path) return;

    _disposeVideo();
    _loadFailureReported = false;
    if (_isVideo) _initVideo();
    setState(() {});
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  void _initVideo() {
    final player = Player();
    _player = player;
    _controller = VideoController(player);

    // libmpv no lanza al abrir un fichero que no está: el aviso llega por el
    // flujo de errores del reproductor.
    _errorSubscription = player.stream.error.listen((error) {
      debugPrint('MediaViewer: error al reproducir el vídeo: $error');
      _reportLoadFailure();
    });

    player.open(Media(widget.path)).catchError((Object e) {
      debugPrint('MediaViewer: no se pudo abrir el vídeo: $e');
      _reportLoadFailure();
    });
  }

  void _disposeVideo() {
    _errorSubscription?.cancel();
    _errorSubscription = null;

    final player = _player;
    _player = null;
    _controller = null;
    player?.dispose();
  }

  /// Avisa de que este contenido no se ha podido abrir.
  ///
  /// No se juzga aquí el motivo: sólo se cuenta lo que ha pasado y quien
  /// escucha comprueba si el fichero sigue estando.
  void _reportLoadFailure() {
    if (_loadFailureReported) return;
    _loadFailureReported = true;
    widget.onLoadFailed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return _isVideo ? _buildVideoPlayer() : _buildImageViewer();
  }

  Widget _buildImageViewer() {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.file(
          File(widget.path),
          fit: BoxFit.contain,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, _, _) {
            _reportLoadFailure();
            return const Icon(
              Icons.broken_image_outlined,
              color: AppColors.lightgray,
              size: AppSizes.iconExtraLarge,
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final controller = _controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Video(
      controller: controller,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
