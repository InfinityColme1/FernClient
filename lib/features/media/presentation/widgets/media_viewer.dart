import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
  VideoPlayerController? _videoController;
  bool _isInitialized = false;

  bool get _isVideo =>
      widget.path.toLowerCase().endsWith('.mp4') ||
      widget.path.toLowerCase().endsWith('.mov') ||
      widget.path.toLowerCase().endsWith('.avi');

  @override
  void initState() {
    super.initState();
    if (_isVideo) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.file(File(widget.path));
    try {
      await _videoController!.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint("Error initializing video player: $e");
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideo) {
      return _buildVideoPlayer();
    } else {
      return _buildImagePlayer();
    }
  }

  Widget _buildImagePlayer() {
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
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_videoController!),
            _VideoControls(controller: _videoController!),
          ],
        ),
      ),
    );
  }
}

class _VideoControls extends StatefulWidget {
  final VideoPlayerController controller;

  const _VideoControls({required this.controller});

  @override
  State<_VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<_VideoControls> {
  bool _showControls = true;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => setState(() => _showControls = true),
      child: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: AnimatedOpacity(
          opacity: _showError() ? 1.0 : (_showControls ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 300),
          child: Container(
            color: Colors.black26,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildProgressBar(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white),
                      onPressed: () {
                        final newPos = widget.controller.value.position - const Duration(seconds: 10);
                        widget.controller.seekTo(newPos);
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: widget.controller,
                      builder: (context, VideoPlayerValue value, child) {
                        return IconButton(
                          iconSize: 48,
                          icon: Icon(
                            value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            value.isPlaying ? widget.controller.pause() : widget.controller.play();
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10, color: Colors.white),
                      onPressed: () {
                        final newPos = widget.controller.value.position + const Duration(seconds: 10);
                        widget.controller.seekTo(newPos);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _showError() => widget.controller.value.hasError;

  Widget _buildProgressBar() {
    return VideoProgressIndicator(
      widget.controller,
      allowScrubbing: true,
      colors: const VideoProgressColors(
        playedColor: Colors.red,
        bufferedColor: Colors.white24,
        backgroundColor: Colors.white10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }
}
