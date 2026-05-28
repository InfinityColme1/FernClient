
enum MediaType { photo, video, gif }

class MediaItem {
  final String id;
  final String name;
  final String path;
  final MediaType type;
  final String origin;
  final DateTime downloadedAt;
  final Duration? duration;
  final List<String> tags;

  MediaItem({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.origin,
    required this.downloadedAt,
    this.duration,
    required this.tags,
  });
}