import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:equatable/equatable.dart';

/// De qué es una pastilla de la barra de búsqueda.
///
/// Va aparte de [SearchResultType] a propósito, aunque se parezcan: aquél es el
/// eje del filtro de la cabecera («de dónde salen los resultados») y tiene sus
/// tres valores contados. Añadirle el texto libre le añadiría una casilla al
/// filtro y cambiaría el conjunto de fábrica de todas las instalaciones.
enum SearchCriterionKind {
  /// Lo escrito, sin ser nada de la base en concreto.
  text,

  /// Un contenido, por su descripción.
  media,
  tag,
  creator,
}

/// Una de las cosas por las que se está buscando: una pastilla de la barra.
///
/// Las pastillas son **acumulativas y se cruzan**: con dos puestas se enseña lo
/// que cumple las dos, no lo que cumple alguna. Es lo que las hace útiles —
/// «esta etiqueta, de este creador»— y lo que las distingue del buscador de
/// antes, que sólo sabía una cosa a la vez.
class SearchCriterionEntity extends Equatable {
  final SearchCriterionKind kind;

  /// Identificador de la entidad, o `null` si es texto libre.
  ///
  /// Se busca **por el identificador y no por el nombre**: pulsar el creador
  /// «Pompeu» trae sus contenidos y nada más, aunque haya una etiqueta que
  /// también contenga la palabra.
  final int? id;

  /// Lo que se lee en la pastilla.
  final String label;

  final String? imagePath;
  final bool isNsfw;

  /// La pastilla todavía no se ha confirmado: es lo que hay escrito en el campo.
  ///
  /// Se busca igual —escribir y esperar sigue actualizando la rejilla, como
  /// antes de que hubiera pastillas— pero no se pinta como pastilla, y al volver
  /// a la pantalla se restaura en el campo y no como una más.
  final bool isPending;

  const SearchCriterionEntity({
    required this.kind,
    required this.label,
    this.id,
    this.imagePath,
    this.isNsfw = false,
    this.isPending = false,
  });

  /// La pastilla de una sugerencia elegida en el desplegable.
  factory SearchCriterionEntity.of(SearchSuggestionEntity suggestion) {
    return SearchCriterionEntity(
      kind: switch (suggestion.type) {
        SearchResultType.media => SearchCriterionKind.media,
        SearchResultType.tag => SearchCriterionKind.tag,
        SearchResultType.creator => SearchCriterionKind.creator,
      },
      id: suggestion.id,
      label: suggestion.label,
      imagePath: suggestion.imagePath,
      isNsfw: suggestion.isNsfw,
    );
  }

  /// La pastilla de lo escrito cuando no es nada de la base en concreto.
  const SearchCriterionEntity.text(String term, {this.isPending = false})
      : kind = SearchCriterionKind.text,
        label = term,
        id = null,
        imagePath = null,
        isNsfw = false;

  /// A qué grupo pertenece lo que devuelve.
  ///
  /// El texto libre cuenta como contenido, que es lo que hace que el filtro de
  /// «de dónde salen los resultados» siga significando lo mismo que hasta ahora.
  SearchResultType get resultType => switch (kind) {
        SearchCriterionKind.text ||
        SearchCriterionKind.media =>
          SearchResultType.media,
        SearchCriterionKind.tag => SearchResultType.tag,
        SearchCriterionKind.creator => SearchResultType.creator,
      };

  SearchCriterionEntity get confirmed =>
      isPending ? SearchCriterionEntity.text(label) : this;

  @override
  List<Object?> get props => [kind, id, label, isPending];
}
