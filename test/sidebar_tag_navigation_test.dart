// Pulsar una etiqueta del menú desde otra pantalla.
//
// Antes se hacían dos cosas a la vez: el menú navegaba a la biblioteca y, en el
// fotograma siguiente, mandaba la búsqueda por la etiqueta. Pero la pantalla, al
// abrirse, **también** pide lo que hubiera en marcha —que todavía era lo de
// antes—, así que llegaban dos peticiones al mismo bloc y la rejilla se quedaba
// con la que terminara la última: unas veces la etiqueta y otras la biblioteca
// entera.
//
// Ahora la etiqueta viaja con la navegación y la busca la propia pantalla: una
// sola petición, sin carrera que perder.

import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/presentation/pages/media_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const filtro = SearchSuggestionEntity(
    id: 7,
    type: SearchResultType.tag,
    label: 'Paisajes',
  );

  test('la pantalla puede abrirse ya filtrando', () {
    expect(const MediaPage(initialFilter: filtro).initialFilter, filtro);
  });

  // Llegando por cualquier otro camino —el menú de la izquierda, volver del
  // visor— la pantalla repite lo que hubiera en marcha, como siempre.
  test('y sin filtro sigue abriéndose como antes', () {
    expect(const MediaPage().initialFilter, isNull);
  });
}
