// Lo que la rejilla deriva de una lista, guardado entre pantallas.
//
// Abrir una pantalla construye la rejilla desde cero, y con ella tres recorridos
// de toda la lista: las proporciones de cada celda, el orden en el que se pintan
// y el reparto en columnas. Con veinte mil contenidos es el trozo mas grande del
// primer fotograma de la pantalla que entra —justo encima de la transicion— y se
// rehacia **aunque la lista fuera exactamente la misma**, porque el widget que
// lo guardaba era nuevo.

import 'package:Fern/core/utils/grid_layout_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GridLayoutCache cache;

  setUp(() => cache = GridLayoutCache());

  group('lo derivado de una lista', () {
    test('se calcula una sola vez', () {
      final source = [1, 2, 3];
      var calls = 0;

      List<double?> build() {
        calls++;
        return const [1.0, 1.0, 1.0];
      }

      cache.ratiosOf(source, build);
      cache.ratiosOf(source, build);

      expect(calls, 1);
    });

    // La clave es la identidad: dos listas distintas son dos trabajos, y una
    // lista nueva nunca puede contestar con el reparto de otra.
    test('y otra lista se calcula aparte', () {
      var calls = 0;

      List<double?> build() {
        calls++;
        return const [1.0];
      }

      cache.ratiosOf([1], build);
      cache.ratiosOf([1], build);

      expect(calls, 2);
    });

    test('el orden se guarda igual y aparte', () {
      final source = [1, 2];
      var ratios = 0;
      var ids = 0;

      cache.ratiosOf(source, () {
        ratios++;
        return const [1.0, 1.0];
      });
      cache.idsOf(source, () {
        ids++;
        return const [1, 2];
      });
      cache.idsOf(source, () {
        ids++;
        return const [1, 2];
      });

      expect(ratios, 1);
      expect(ids, 1);
    });

    // Durante un fundido cruzado hay dos rejillas vivas: con una sola entrada
    // se pisarian la una a la otra en cada fotograma.
    test('caben varias listas a la vez', () {
      final one = [1];
      final other = [2];
      var calls = 0;

      List<double?> build() {
        calls++;
        return const [1.0];
      }

      cache.ratiosOf(one, build);
      cache.ratiosOf(other, build);
      cache.ratiosOf(one, build);
      cache.ratiosOf(other, build);

      expect(calls, 2);
    });
  });

  group('el reparto en columnas', () {
    const ratios = <double?>[1, 1, 1, 1];

    test('se reutiliza con las mismas medidas', () {
      final first = cache.layoutOf(
        ratios: ratios,
        columns: 4,
        crossAxisExtent: 1000,
        spacing: 8,
        fallbackRatio: 1,
      );

      final second = cache.layoutOf(
        ratios: ratios,
        columns: 4,
        crossAxisExtent: 1000,
        spacing: 8,
        fallbackRatio: 1,
      );

      expect(identical(first, second), isTrue);
    });

    // Cambiar de ancho es otro reparto: la ventana se ha redimensionado.
    test('pero no con otro ancho', () {
      final first = cache.layoutOf(
        ratios: ratios,
        columns: 4,
        crossAxisExtent: 1000,
        spacing: 8,
        fallbackRatio: 1,
      );

      final second = cache.layoutOf(
        ratios: ratios,
        columns: 4,
        crossAxisExtent: 900,
        spacing: 8,
        fallbackRatio: 1,
      );

      expect(identical(first, second), isFalse);
    });

    test('ni con otras columnas', () {
      final first = cache.layoutOf(
        ratios: ratios,
        columns: 4,
        crossAxisExtent: 1000,
        spacing: 8,
        fallbackRatio: 1,
      );

      final second = cache.layoutOf(
        ratios: ratios,
        columns: 3,
        crossAxisExtent: 1000,
        spacing: 8,
        fallbackRatio: 1,
      );

      expect(identical(first, second), isFalse);
    });

    // Otra lista es otro reparto aunque diga lo mismo: la clave es la
    // instancia, y una lista nueva quiere decir que el contenido ha cambiado.
    // (Sin `const`, que Dart devuelve la misma instancia para dos listas
    // constantes iguales y aqui eso taparia lo que se quiere medir.)
    test('ni con otras proporciones', () {
      final first = cache.layoutOf(
        ratios: ratios,
        columns: 4,
        crossAxisExtent: 1000,
        spacing: 8,
        fallbackRatio: 1,
      );

      final second = cache.layoutOf(
        ratios: <double?>[1, 1, 1, 1],
        columns: 4,
        crossAxisExtent: 1000,
        spacing: 8,
        fallbackRatio: 1,
      );

      expect(identical(first, second), isFalse);
    });

    // Y lo que devuelve tiene que ser el reparto de verdad, no una caja vacia.
    test('y lo que devuelve es el reparto que toca', () {
      final layout = cache.layoutOf(
        ratios: ratios,
        columns: 4,
        crossAxisExtent: 1000,
        spacing: 8,
        fallbackRatio: 1,
      );

      expect(layout.cells, hasLength(4));
      expect(layout.cells.every((cell) => cell.top == 0), isTrue);
    });
  });
}
