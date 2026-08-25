// Volver del visor con la rejilla puesta donde estaba lo que se acaba de ver.
//
// La cuenta es una estimación, así que lo que se sostiene no es un número
// exacto: es que lo mirado quede **dentro de la pantalla**, que no se pida un
// desplazamiento imposible —ni negativo ni más allá del final— y que los dos
// extremos de la lista se comporten como uno espera, que es quedarse pegados al
// principio y al final en vez de intentar centrarse en el vacío.

import 'package:Fern/features/media/domain/services/grid_return_scroll.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Mil contenidos en una rejilla de 600 de alto con 9.400 de recorrido: el
  // contenido total mide 10.000.
  const maxScroll = 9400.0;
  const viewport = 600.0;

  double offsetOf(int index, {int count = 1000}) => gridReturnOffset(
        index: index,
        count: count,
        maxScrollExtent: maxScroll,
        viewportHeight: viewport,
      );

  /// Dónde se estima que cae el contenido [index], en el lienzo entero.
  double positionOf(int index, {int count = 1000}) =>
      (index + 0.5) / count * (maxScroll + viewport);

  test('lo mirado queda dentro de la pantalla', () {
    for (final index in [0, 1, 37, 499, 500, 998, 999]) {
      final offset = offsetOf(index);
      final position = positionOf(index);

      expect(
        position,
        inInclusiveRange(offset, offset + viewport),
        reason: 'el contenido $index se queda fuera de la pantalla',
      );
    }
  });

  test('y a media altura cuando hay sitio de sobra a los dos lados', () {
    // El del medio es el caso sin bordes que estorben: ahí se puede centrar de
    // verdad, y centrado es lo que se pidió.
    expect(offsetOf(500), closeTo(positionOf(500) - viewport / 2, 0.001));
  });

  group('los extremos', () {
    test('el primero no pide un desplazamiento negativo', () {
      expect(offsetOf(0), 0);
    });

    test('el último no pide pasarse del final', () {
      expect(offsetOf(999), lessThanOrEqualTo(maxScroll));
      expect(offsetOf(999), maxScroll);
    });
  });

  group('cuando no hay a dónde ir', () {
    test('la lista vacía se queda donde está', () {
      expect(gridReturnOffset(
        index: 0,
        count: 0,
        maxScrollExtent: maxScroll,
        viewportHeight: viewport,
      ), 0);
    });

    test('lo que cabe entero en la pantalla tampoco se mueve', () {
      expect(gridReturnOffset(
        index: 2,
        count: 4,
        maxScrollExtent: 0,
        viewportHeight: viewport,
      ), 0);
    });

    test('un índice que no es de esta lista no salta a ninguna parte', () {
      // Pasa de verdad: se mira algo, se borra, y la lista de vuelta es más
      // corta que el índice que se traía.
      expect(offsetOf(4000), 0);
      expect(offsetOf(-1), 0);
    });
  });
}
