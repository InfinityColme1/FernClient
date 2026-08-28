import 'package:Fern/core/constants/app_constants.dart';
import 'package:path/path.dart' as p;

/// La extensión de [url] si apunta a un fichero multimedia de los que la
/// aplicación reconoce, y `null` en cualquier otro caso.
///
/// Los parámetros de la dirección no cuentan: `foto.jpg?width=640` es una
/// imagen. Es lo que decide qué se descarga de una fuente remota, así que un
/// enlace a una página web (que no lleva extensión) se queda fuera.
String? mediaExtensionOfUrl(String url) {
  final path = Uri.tryParse(url)?.path ?? '';
  final extension = p.extension(path).toLowerCase();

  return mediaExtensions.contains(extension) ? extension : null;
}

/// Detección del tipo de fichero multimedia a partir de su ruta.
///
/// Centraliza las comprobaciones de extensión que estaban duplicadas en los
/// widgets de rejilla y de visor.
class MediaExtensions {
  const MediaExtensions._();

  static const video = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];
  static const gif = ['.gif'];
}

/// Las tres clases de contenido que la aplicación distingue.
///
/// Sale de aquí y no de cada pantalla porque la discriminación por extensión ya
/// vive en este fichero: tenerla en dos sitios es tener dos respuestas distintas
/// a la misma pregunta en cuanto alguien añada una extensión.
enum MediaKind {
  image,
  gif,
  video;

  /// De qué clase es el fichero de [path].
  static MediaKind of(String path) {
    if (path.isVideoPath) return MediaKind.video;
    if (path.isGifPath) return MediaKind.gif;

    return MediaKind.image;
  }
}

/// Las tres, que es la biblioteca entera.
const allMediaKinds = {MediaKind.image, MediaKind.gif, MediaKind.video};

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
