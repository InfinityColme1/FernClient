/// Un fichero que hay que descargarse de una fuente remota.
///
/// Una publicación puede dar varios (una galería son varias imágenes), y cada
/// uno acaba siendo un contenido de la aplicación por su cuenta: [id] es único
/// dentro de la fuente y es lo que se usa para nombrar el fichero.
///
/// Es lo que hablan todas las fuentes remotas con el repositorio, así que vive
/// aparte de cualquiera de ellas: lo que cambia de una plataforma a otra es de
/// dónde sale, no lo que es.
class RemoteMediaItem {
  /// Identificador dentro de la fuente, ya apto para nombrar un fichero.
  final String id;

  /// De dónde se descarga el fichero.
  final String url;

  /// Título de la publicación, que es lo que se guarda como descripción.
  final String title;

  /// Identificador de la publicación de la que sale.
  ///
  /// Varios ficheros de una misma galería lo comparten. Es la marca con la que
  /// se reconoce por dónde se quedó la importación anterior, así que tiene que
  /// ser el de la publicación y no el del fichero.
  final String postId;

  /// Direcciones que dicen de dónde sale este contenido dentro de la
  /// plataforma: la comunidad, la publicación, la galería del autor.
  ///
  /// No es de dónde se descarga el fichero ([url], que suele ser un servidor de
  /// contenidos sin nada que identifique el sitio), sino lo que el usuario
  /// reconoce como el origen y lo que puede haber vinculado con una etiqueta.
  final List<String> sourceUrls;

  /// Cabeceras que hay que mandar para poder descargar [url].
  ///
  /// Vacías en casi todas las fuentes: un fichero suele bajarse pidiéndolo sin
  /// más. Hay servidores de contenidos que sólo lo dan si la petición dice
  /// venir de su web (Pixiv es uno), y eso sólo lo sabe la fuente que dio la
  /// dirección, así que viaja con ella.
  final Map<String, String> headers;

  /// De qué listado de la fuente sale, cuando la fuente tiene más de uno.
  ///
  /// Sirve para llevar la cuenta de por dónde se quedó la última importación
  /// por separado en cada listado: dos listados recorridos del más nuevo al más
  /// antiguo son dos recorridos distintos, y una sola marca para los dos
  /// pararía el segundo donde no toca. `null` en las fuentes de un solo
  /// listado, que es el caso normal.
  final String? collection;

  /// Lo que dura cada fotograma, en milisegundos, cuando [url] no lleva a un
  /// fichero sino a un paquete de fotogramas sueltos que hay que montar.
  ///
  /// `null` en lo normal, que es que la dirección ya sea el fichero. Hay
  /// plataformas que sirven sus animaciones así (Pixiv es una), y sólo la
  /// fuente que dio la dirección sabe que lo que hay detrás no se puede guardar
  /// tal cual.
  final List<int>? frameDelays;

  const RemoteMediaItem({
    required this.id,
    required this.url,
    required this.title,
    required this.postId,
    this.sourceUrls = const [],
    this.headers = const {},
    this.collection,
    this.frameDelays,
  });
}
