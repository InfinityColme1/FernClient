/// En qué orden se pinta la biblioteca.
///
/// Hasta ahora salía en el orden en el que Isar devuelve las filas, que es el de
/// sus identificadores. Y como el identificador de un contenido es el hash de su
/// ruta, ese orden no significa **nada**: ni cuándo llegó, ni cómo se llama, ni
/// de qué tipo es. Parece aleatorio pero sin la ventaja de serlo, porque es
/// siempre el mismo.
enum MediaSortOrder {
  /// Lo último que llegó, primero. Es el de fábrica: lo que se acaba de
  /// importar es lo que se va a querer mirar.
  newestFirst(id: 'newest'),

  /// Lo primero que llegó, primero.
  oldestFirst(id: 'oldest'),

  /// Por el nombre del fichero, sin la carpeta.
  ///
  /// Sin la carpeta a propósito: con la biblioteca organizada por la
  /// aplicación, todas las rutas empiezan igual y ordenar por la ruta entera
  /// sería ordenar por subcarpeta, que no es lo que se pide.
  fileName(id: 'file'),

  /// Por la descripción, y lo que no tenga al final.
  ///
  /// Al final y no al principio: un bloque de contenido sin describir abriendo
  /// la rejilla es lo mismo que no haber ordenado nada.
  description(id: 'description'),

  /// Agrupado por tipo: imágenes, GIF y vídeos.
  kind(id: 'kind'),

  /// Al azar, pero **el mismo azar mientras dure la sesión**.
  ///
  /// Si cambiara en cada consulta, la rejilla se recolocaría al desplazarse y
  /// al volver del visor, y se vería contenido repetido y contenido saltado.
  random(id: 'random');

  const MediaSortOrder({required this.id});

  final String id;

  /// Los que se ofrecen en la pantalla de importación.
  ///
  /// Todos menos el azar. Lo que hay ahí es una tanda que se está revisando de
  /// arriba abajo: barajarla es perder el sitio, y encima el azar de la sesión
  /// no cambia, así que ni siquiera sirve para redescubrir nada.
  static List<MediaSortOrder> get forImport =>
      [for (final order in values) if (order != random) order];

  static MediaSortOrder fromId(String? id) {
    return MediaSortOrder.values.firstWhere(
      (order) => order.id == id,
      orElse: () => MediaSortOrder.newestFirst,
    );
  }
}
