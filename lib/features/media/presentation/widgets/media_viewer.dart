import 'dart:io';

import 'package:Fern/core/utils/media_type.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaViewer extends StatefulWidget {
  final String path;

  const MediaViewer({
    super.key,
    required this.path,
  });

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  Player? _player;
  VideoController? _controller;

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

    player.open(Media(widget.path)).catchError((Object e) {
      debugPrint('MediaViewer: no se pudo abrir el vídeo: $e');
    });
  }

  void _disposeVideo() {
    final player = _player;
    _player = null;
    _controller = null;
    player?.dispose();
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
