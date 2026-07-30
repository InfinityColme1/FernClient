// lib/features/media/presentation/widgets/media_item.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/media/media_summary_entity.dart';

class MediaItem extends StatefulWidget {
  final MediaSummaryEntity media;
  final VoidCallback? onTap;

  const MediaItem({super.key, required this.media, this.onTap});

  @override
  State<MediaItem> createState() => _MediaItemState();
}

class _MediaItemState extends State<MediaItem> {
  VideoPlayerController? _controller;
  String? _thumbnailPath;
  bool _isPlaying = false;
  String _duration = "--:--";
  bool _isLoadingThumbnail = false;

  @override
  void initState() {
    super.initState();
    if (_isVideo) _initVideo();
  }

  bool get _isVideo => widget.media.path.toLowerCase().endsWith('.mp4') ||
      widget.media.path.toLowerCase().endsWith('.mov');
  bool get _isGif => widget.media.path.toLowerCase().endsWith('.gif');

  Future<void> _initVideo() async {
    setState(() => _isLoadingThumbnail = true);

    try {

      final tempDir = await getTemporaryDirectory();
      final fileName = p.basenameWithoutExtension(widget.media.path);
      final thumbPath = p.join(tempDir.path, 'thumb_$fileName.jpg');


      if (!File(thumbPath).existsSync()) {
        final session = await FFmpegKit.execute(
            '-i "${widget.media.path}" -ss 00:00:01.000 -vframes 1 -s 320x240 "$thumbPath"'
        );
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          if (mounted) setState(() => _thumbnailPath = thumbPath);
        }
      } else {
        if (mounted) setState(() => _thumbnailPath = thumbPath);
      }


      _controller = VideoPlayerController.file(File(widget.media.path));
      await _controller!.initialize();
      if (mounted) {
        final dur = _controller!.value.duration;
        setState(() => _duration = "${dur.inMinutes}:${(dur.inSeconds % 60).toString().padLeft(2, '0')}");
      }
    } catch (e) {
      debugPrint("Error FFmpeg/Video: $e");
    } finally {
      if (mounted) setState(() => _isLoadingThumbnail = false);
    }
  }

  void _togglePreview(bool play) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (play) {
      _controller!.setLooping(true);
      _controller!.play();
      setState(() => _isPlaying = true);
    } else {
      _controller!.pause();
      _controller!.seekTo(Duration.zero);
      setState(() => _isPlaying = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: (_) => _togglePreview(true),
      onLongPressEnd: (_) => _togglePreview(false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.black87,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _isPlaying
                  ? AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!))
                  : Image.file(
                File(_isVideo ? (_thumbnailPath ?? widget.media.path) : widget.media.path),
                fit: BoxFit.contain,
                cacheWidth: 300,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white24),
              ),

              if (_isLoadingThumbnail && _thumbnailPath == null)
                const CircularProgressIndicator(strokeWidth: 2),

              if (_isVideo && !_isPlaying) ...[
                const CircleAvatar(backgroundColor: Colors.black45, child: Icon(Icons.play_arrow, color: Colors.white)),
                Positioned(
                  bottom: 5, right: 5,
                  child: Text(_duration, style: const TextStyle(color: Colors.white, fontSize: 10, backgroundColor: Colors.black54)),
                )
              ],
              if (_isGif)
                Positioned(top: 5, left: 5, child: Container(color: Colors.orange, padding: EdgeInsets.all(2), child: Text("GIF", style: TextStyle(fontSize: 9, color: Colors.white)))),
            ],
          ),
        ),
      ),
    );
  }
}