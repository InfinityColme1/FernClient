// Qué contenidos se señalan al llegar de un aviso, y cuándo se dejan de señalar.
//
// Un aviso de «reconocimiento terminado» que sólo lleva a una pantalla deja al
// usuario delante de una rejilla de trescientas miniaturas sin saber cuáles son
// las suyas. Esto es lo que las señala.
//
// Y lo que las **deja** de señalar, que importa igual: un destacado que se queda
// puesto deja de significar «esto es nuevo» y pasa a ser decoración.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/presentation/widgets/highlight_scroll_marks.dart';
import 'package:Fern/features/recognition/data/services/recognition_highlight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RecognitionHighlight highlight;
  var changes = 0;

  setUp(() {
    highlight = RecognitionHighlight();
    changes = 0;
    highlight.addListener(() => changes++);
  });

  group('señalar', () {
    test('deja los contenidos y la pantalla', () {
      highlight.show(route: mediaRoute, mediaIds: {1, 2});

      expect(highlight.route, mediaRoute);
      expect(highlight.mediaIds, {1, 2});
      expect(highlight.contains(1), isTrue);
      expect(highlight.contains(9), isFalse);
    });

    test('avisa a quien lo esté mirando', () {
      highlight.show(route: mediaRoute, mediaIds: {1});

      expect(changes, 1);
    });

    test('un aviso nuevo reemplaza al anterior', () {
      highlight.show(route: importRoute, mediaIds: {1, 2});
      highlight.show(route: mediaRoute, mediaIds: {3});

      // Acumular dos reconocimientos dejaría marcado medio catálogo sin que nada
      // lo distinga.
      expect(highlight.mediaIds, {3});
      expect(highlight.route, mediaRoute);
    });

    test('sin contenidos no señala nada', () {
      highlight.show(route: mediaRoute, mediaIds: const {});

      expect(highlight.isEmpty, isTrue);
      expect(highlight.route, isNull);
      expect(changes, 0);
    });
  });

  group('dar por visto', () {
    test('se apaga del todo', () {
      highlight.show(route: mediaRoute, mediaIds: {1});
      highlight.clear();

      expect(highlight.isEmpty, isTrue);
      expect(highlight.route, isNull);
      expect(highlight.contains(1), isFalse);
    });

    test('apagar lo ya apagado no avisa', () {
      highlight.clear();

      // Sin esto, cada movimiento del ratón sobre la rejilla reconstruiría
      // trescientas celdas para no cambiar nada.
      expect(changes, 0);
    });
  });

  group('las marcas del scroll', () {
    /// Dónde caen las marcas, de 0 a 1.
    List<double> marksOf(List<int> ordered, Set<int> highlighted) {
      return HighlightScrollMarks(
        orderedIds: ordered,
        highlighted: highlighted,
      ).positionsForTest;
    }

    test('una marca por contenido señalado', () {
      expect(marksOf([1, 2, 3, 4], {2, 4}), hasLength(2));
    });

    test('la altura sigue al orden de la rejilla', () {
      final marks = marksOf([1, 2, 3, 4], {1, 3});

      // El primero arriba del todo, el tercero a mitad de camino.
      expect(marks, [0.0, 0.5]);
    });

    test('lo que no está en la rejilla no se marca', () {
      // Se señaló en otra pantalla: aquí no hay nada a qué apuntar.
      expect(marksOf([1, 2], {9}), isEmpty);
    });

    test('sin rejilla no hay marcas', () {
      expect(marksOf(const [], {1}), isEmpty);
    });
  });

  group('releer la pantalla', () {
    test('el aviso cae aquí y no hay nada marcado: se relee', () {
      expect(
        shouldReloadOnRecognition(
          highlighted: importRoute,
          screen: importRoute,
          hasSelection: false,
        ),
        isTrue,
      );
    });

    test('el aviso cae en otra pantalla: no se toca ésta', () {
      // Reconocer contenido definitivo señala la rejilla de la biblioteca;
      // releer también la de importación sería trabajo para nada.
      expect(
        shouldReloadOnRecognition(
          highlighted: mediaRoute,
          screen: importRoute,
          hasSelection: false,
        ),
        isFalse,
      );
    });

    test('sin aviso ninguno, no se relee', () {
      expect(
        shouldReloadOnRecognition(
          highlighted: null,
          screen: importRoute,
          hasSelection: false,
        ),
        isFalse,
      );
    });

    test('con un contenido abierto, se espera', () {
      // La rejilla está debajo del visor y su escucha sigue viva: releer le
      // cambia la lista al visor y le tira el estado, así que guardar deja de
      // llevar al siguiente.
      expect(
        shouldReloadOnRecognition(
          highlighted: importRoute,
          screen: importRoute,
          hasSelection: false,
          isViewingMedia: true,
        ),
        isFalse,
      );
    });

    test('con algo marcado, se espera', () {
      // Releer limpia la selección, y quien está marcando contenidos está
      // trabajando: quitarle lo marcado por un aviso es peor que esperar.
      expect(
        shouldReloadOnRecognition(
          highlighted: importRoute,
          screen: importRoute,
          hasSelection: true,
        ),
        isFalse,
      );
    });
  });
}
