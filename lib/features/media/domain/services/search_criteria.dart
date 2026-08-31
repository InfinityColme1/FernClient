import 'package:Fern/features/media/domain/entities/search/search_criterion_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';

/// La pastilla que le toca a lo escrito al pulsar enter.
///
/// Si lo escrito **es** el nombre entero de una etiqueta o de un creador, la
/// pastilla es de esa entidad y busca por su identificador: acotar a la etiqueta
/// «Ladybug» no es lo mismo que buscar la palabra suelta. Si no lo es, sale una
/// de texto libre, que recoge lo mismo que recogía escribir antes de que
/// hubiera pastillas.
///
/// **La coincidencia tiene que ser entera**, sin distinguir mayúsculas ni los
/// espacios de los extremos. Bastando con que empezara igual, lo mismo escrito
/// daría una cosa u otra según lo que hubiera en la base ese día: escribir
/// «lady» acotaría a una etiqueta hoy y buscaría el texto mañana, cuando exista
/// una segunda que también empiece así.
///
/// Un contenido nunca: su «nombre» es su descripción, y que una descripción
/// coincida entera con lo escrito es casualidad y no lo que se ha pedido. Para
/// llegar a un contenido concreto está el desplegable.
SearchCriterionEntity criterionFor(
  String term,
  List<SearchSuggestionEntity> suggestions,
) {
  final needle = term.trim().toLowerCase();

  for (final suggestion in suggestions) {
    if (suggestion.type == SearchResultType.media) continue;
    if (suggestion.label.trim().toLowerCase() != needle) continue;

    return SearchCriterionEntity.of(suggestion);
  }

  return SearchCriterionEntity.text(term.trim());
}
