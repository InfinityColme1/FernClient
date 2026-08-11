/// Naturaleza de un resultado del buscador principal.
///
/// El buscador mira a la vez las descripciones de los contenidos, los nombres
/// de las etiquetas y los nombres de los creadores, así que hace falta saber de
/// dónde viene cada resultado: es lo que decide el avatar que se le pinta y el
/// orden en el que se agrupan los contenidos en la rejilla.
enum SearchResultType {
  /// El contenido en sí, encontrado por su descripción.
  media,

  tag,

  creator,
}
