// Qué pastilla le toca a lo escrito al pulsar enter.
//
// La regla es que la coincidencia sea **entera**. Bastando con que empiece
// igual, lo mismo escrito daría una cosa u otra según lo que hubiera en la base
// ese día: «lady» acotaría a la etiqueta «Ladybug» hoy y buscaría el texto
// mañana, cuando exista una segunda que también empiece así. Eso es un buscador
// que se comporta distinto sin que nadie haya cambiado nada.

import 'package:Fern/features/media/domain/entities/search/search_criterion_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/domain/services/search_criteria.dart';
import 'package:flutter_test/flutter_test.dart';

SearchSuggestionEntity _suggestion(
  int id,
  String label,
  SearchResultType type,
) =>
    SearchSuggestionEntity(id: id, type: type, label: label);

void main() {
  final ladybug = _suggestion(1, 'Ladybug', SearchResultType.tag);
  final pompeu = _suggestion(10, 'Pompeu', SearchResultType.creator);
  final media = _suggestion(100, 'una ladybug de perfil', SearchResultType.media);

  test('el nombre entero de una etiqueta acota a esa etiqueta', () {
    final criterion = criterionFor('Ladybug', [ladybug, media]);

    expect(criterion.kind, SearchCriterionKind.tag);
    expect(criterion.id, 1);
  });

  test('sin distinguir mayúsculas', () {
    expect(criterionFor('LADYBUG', [ladybug]).kind, SearchCriterionKind.tag);
  });

  test('ni los espacios de los extremos', () {
    expect(criterionFor('  Ladybug  ', [ladybug]).kind, SearchCriterionKind.tag);
  });

  test('un creador también', () {
    final criterion = criterionFor('Pompeu', [pompeu]);

    expect(criterion.kind, SearchCriterionKind.creator);
    expect(criterion.id, 10);
  });

  test('un trozo del nombre es texto libre', () {
    final criterion = criterionFor('lady', [ladybug]);

    expect(criterion.kind, SearchCriterionKind.text);
    expect(criterion.label, 'lady');
    expect(criterion.id, isNull);
  });

  test('sin nada que se le parezca, texto libre', () {
    expect(criterionFor('nada', const []).kind, SearchCriterionKind.text);
  });

  // Su «nombre» es su descripción, y que coincida entera con lo escrito es
  // casualidad y no lo que se ha pedido. Para llegar a un contenido concreto
  // está el desplegable.
  test('un contenido nunca acota, aunque coincida entero', () {
    final criterion = criterionFor('una ladybug de perfil', [media]);

    expect(criterion.kind, SearchCriterionKind.text);
  });

  test('la pastilla de texto guarda lo escrito sin los espacios', () {
    expect(criterionFor('  algo  ', const []).label, 'algo');
  });

  // El desplegable llega en orden de turnos (contenido, etiqueta, creador): la
  // que coincida entera manda, esté donde esté.
  test('la coincidencia entera manda sobre el orden de las sugerencias', () {
    final criterion = criterionFor('Pompeu', [media, ladybug, pompeu]);

    expect(criterion.kind, SearchCriterionKind.creator);
  });
}
