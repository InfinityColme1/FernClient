import 'package:Fern/core/utils/media_type.dart';

/// Un contenido que se ha encontrado en la página que el usuario tiene delante.
///
/// No es lo mismo que lo que trae una fuente remota: aquí todavía no se ha
/// decidido nada. El usuario ve la lista, señala lo que quiere y sólo eso se
/// descarga, así que cada uno lleva con qué señalarlo en la página ([mark]) y
/// con qué reconocerlo en la lista.
class BrowserMedia {
  /// La marca que se le ha puesto al elemento dentro de la página. Es con lo
  /// que se le resalta cuando el usuario pasa por encima de su fila.
  ///
  /// `null` en lo que no es un elemento de la página sino algo que ésta declara
  /// de sí misma (las etiquetas con las que se anuncia a las redes sociales):
  /// se puede descargar, pero no hay nada que señalar.
  final String? mark;

  /// De dónde se descarga.
  final String url;

  /// Qué etiqueta de la página lo daba (`img`, `video`, `a`...). Es lo que
  /// distingue en la lista una imagen de un vídeo o de un enlace suelto.
  final String kind;

  /// Lo que ocupa en la página, si es que se está viendo. Sirve para separar el
  /// contenido de verdad de los iconos y los adornos.
  final int width;
  final int height;

  const BrowserMedia({
    required this.mark,
    required this.url,
    required this.kind,
    this.width = 0,
    this.height = 0,
  });

  /// El nombre del fichero al final de la dirección, que es lo que se enseña en
  /// la lista. Si no lo hay (una dirección que acaba en el sitio y poco más), se
  /// enseña la dirección entera.
  String get name {
    final path = Uri.tryParse(url)?.pathSegments;
    final last = (path == null || path.isEmpty) ? '' : path.last;

    return last.isEmpty ? url : last;
  }

  /// La extensión del fichero, para decir de un vistazo qué es cada cosa.
  String get extension => mediaExtensionOfUrl(url) ?? '';

  /// Está a la vista en la página y ocupa algo. Lo que mide cero es lo que la
  /// página tiene escondido, y lo que mide muy poco son sus iconos.
  bool get isVisible => width > 0 && height > 0;
}
