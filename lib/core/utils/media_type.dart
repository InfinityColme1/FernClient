/// Detección del tipo de fichero multimedia a partir de su ruta.
///
/// Centraliza las comprobaciones de extensión que estaban duplicadas en los
/// widgets de rejilla y de visor.
class MediaExtensions {
  const MediaExtensions._();

  static const video = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];
  static const gif = ['.gif'];
}

extension MediaPathX on String {
  bool _hasAnyExtension(List<String> extensions) {
    final path = toLowerCase();
    return extensions.any(path.endsWith);
  }

  /// `true` si la ruta apunta a un vídeo reproducible.
  bool get isVideoPath => _hasAnyExtension(MediaExtensions.video);

  /// `true` si la ruta apunta a un GIF animado.
  bool get isGifPath => _hasAnyExtension(MediaExtensions.gif);
}
