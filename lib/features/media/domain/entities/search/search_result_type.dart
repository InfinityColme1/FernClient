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

/// Los tres tipos a la vez, que es con lo que arranca el filtro de la pantalla
/// de media: sin tocar nada se ve todo lo que ha encontrado el buscador.
const Set<SearchResultType> allSearchResultTypes = {
  SearchResultType.media,
  SearchResultType.tag,
  SearchResultType.creator,
};
