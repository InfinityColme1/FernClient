// La rejilla de mamposteria, calculada entera y por adelantado.
//
// Lo que arregla: una rejilla perezosa no sabe cuanto mide hasta haberla
// recorrido, asi que va estimando el total con la media de lo que lleva
// colocado. Esa estimacion cambia con cada celda nueva, y con ella cambia el
// tamano y la posicion de la barra: se arrastra hacia abajo y de pronto salta
// sola, porque debajo le han movido la referencia.
//
// Calculandola entera el alto es exacto, la barra deja de moverse sola, y saber
// que hay a una altura concreta es una consulta y no una adivinanza.

import 'package:Fern/core/utils/masonry_layout.dart';
import 'package:flutter_test/flutter_test.dart';

MasonryLayout layout(
  List<double?> ratios, {
  int columns = 4,
  double width = 1000,
  double spacing = 8,
}) {
  return MasonryLayout.of(
    ratios: ratios,
    columns: columns,
    crossAxisExtent: width,
    spacing: spacing,
    fallbackRatio: 1,
  );
}

void main() {
  group('el reparto', () {
    test('las primeras llenan una columna cada una', () {
      final grid = layout([1, 1, 1, 1]);

      expect(grid.cells.map((cell) => cell.column), [0, 1, 2, 3]);
      // Y todas arriba del todo: ninguna columna llevaba nada.
      expect(grid.cells.every((cell) => cell.top == 0), isTrue);
    });

    test('la siguiente va a la columna que va mas corta', () {
      // La primera es el doble de alta que las demas.
      final grid = layout([0.5, 1, 1, 1, 1]);

      expect(grid.cells[4].column, 1,
          reason: 'la 0 dejo su columna larga, asi que toca la siguiente');
    });

    test('el ancho de columna descuenta los huecos', () {
      final grid = layout([1], columns: 4, width: 1000, spacing: 8);

      // Mil menos tres huecos de ocho, entre cuatro.
      expect(grid.columnWidth, (1000 - 24) / 4);
    });

    test('cada columna empieza donde le toca', () {
      final grid = layout([1, 1, 1, 1], columns: 4, width: 1000, spacing: 8);

      expect(grid.cells[0].left, 0);
      expect(grid.cells[1].left, closeTo(grid.columnWidth + 8, 0.001));
      expect(grid.cells[3].left, closeTo(3 * (grid.columnWidth + 8), 0.001));
    });

    test('el mismo reparto siempre para los mismos datos', () {
      final ratios = [for (var i = 0; i < 50; i++) 1 + (i % 7) * 0.3];

      final first = layout(ratios);
      final second = layout(ratios);

      expect(
        first.cells.map((cell) => cell.column),
        second.cells.map((cell) => cell.column),
      );
      expect(first.extent, second.extent);
    });
  });

  group('lo que mide', () {
    test('con celdas iguales, el alto es exacto', () {
      // Doce celdas cuadradas en cuatro columnas: tres filas.
      final grid = layout([for (var i = 0; i < 12; i++) 1.0]);

      expect(grid.extent, closeTo(grid.columnWidth * 3 + 8 * 2, 0.001));
    });

    test('el alto es el de la columna mas larga', () {
      final grid = layout([0.25, 1, 1, 1]);

      // La primera es cuatro veces mas alta que ancha.
      expect(grid.extent, closeTo(grid.columnWidth * 4, 0.001));
    });

    test('sin nada que colocar no mide nada', () {
      expect(layout(const []).extent, 0);
      expect(layout(const []).isEmpty, isTrue);
    });

    test('una proporcion que no se sabe entra con la de reserva', () {
      final grid = layout([null, 0, -1]);

      // Se colocan igual: mal, pero se colocan. Dejarlas fuera abriria un hueco.
      expect(grid.cells, hasLength(3));
      expect(grid.cells.every((cell) => cell.height > 0), isTrue);
    });
  });

  group('que hay a esta altura', () {
    test('arriba del todo empieza por la primera', () {
      final grid = layout([for (var i = 0; i < 40; i++) 1.0]);

      expect(grid.firstVisibleAt(0), 0);
    });

    test('no se salta ninguna celda que se vea', () {
      final ratios = [for (var i = 0; i < 200; i++) 0.5 + (i % 9) * 0.25];
      final grid = layout(ratios);

      const viewport = 900.0;

      // Se recorre la rejilla entera de pantalla en pantalla comprobando lo
      // unico que importa: que el rango que se pide construir contenga a todas
      // las que de verdad se cruzan con lo que se ve. Saltarse una deja un
      // hueco en pantalla, y es el fallo que nadie sabe explicar.
      for (var top = 0.0; top < grid.extent; top += 150) {
        final bottom = top + viewport;

        final first = grid.firstVisibleAt(top);
        final last = grid.lastVisibleAt(bottom);

        for (var index = 0; index < grid.cells.length; index++) {
          final cell = grid.cells[index];
          final visible = cell.bottom > top && cell.top < bottom;

          if (!visible) continue;

          expect(index, greaterThanOrEqualTo(first), reason: 'a $top');
          expect(index, lessThanOrEqualTo(last), reason: 'a $top');
        }
      }
    });

    // El fallo de la captura: cuatro contenidos, uno mucho mas alto que los
    // demas, y la rejilla enseñaba uno. La celda alta se quedaba ella sola con
    // los tramos de abajo, asi que preguntar por el final de la pantalla
    // contestaba con su indice y las otras tres no se llegaban a construir.
    test('una celda alta no se lleva por delante a las de al lado', () {
      final grid = layout(
        [0.42, 1.4, 1.4, 1.4],
        columns: 4,
        width: 1900,
      );

      // Las cuatro empiezan arriba del todo, asi que las cuatro se ven.
      expect(grid.firstVisibleAt(0), 0);
      expect(grid.lastVisibleAt(900), 3);
    });

    // Lo mismo mas abajo: una columna con una celda larguisima y las de al lado
    // avanzando en indices mas altos.
    test('y tampoco a media rejilla', () {
      final ratios = <double?>[
        for (var i = 0; i < 10; i++) 1.0,
        0.2,
        for (var i = 0; i < 10; i++) 1.0,
      ];
      final grid = layout(ratios, columns: 3);

      const viewport = 900.0;

      for (var top = 0.0; top < grid.extent; top += 100) {
        final first = grid.firstVisibleAt(top);
        final last = grid.lastVisibleAt(top + viewport);

        for (var index = 0; index < grid.cells.length; index++) {
          final cell = grid.cells[index];
          if (cell.bottom <= top || cell.top >= top + viewport) continue;

          expect(index, greaterThanOrEqualTo(first), reason: 'a $top');
          expect(index, lessThanOrEqualTo(last), reason: 'a $top');
        }
      }
    });

    test('preguntar mas alla del final no se sale', () {
      final grid = layout([for (var i = 0; i < 20; i++) 1.0]);

      expect(grid.firstVisibleAt(grid.extent * 10), lessThan(20));
      expect(grid.lastVisibleAt(grid.extent * 10), lessThan(20));
      expect(grid.firstVisibleAt(-500), 0);
    });
  });

  group('volver a una celda', () {
    test('la deja centrada', () {
      final grid = layout([for (var i = 0; i < 60; i++) 1.0]);
      const viewport = 800.0;

      final cell = grid.cells[30];
      final offset = grid.offsetToCentre(30, viewport);

      final middle = cell.top + cell.height / 2;
      expect(offset + viewport / 2, closeTo(middle, 0.001));
    });

    test('no se sale por arriba ni por abajo', () {
      final grid = layout([for (var i = 0; i < 60; i++) 1.0]);
      const viewport = 800.0;

      expect(grid.offsetToCentre(0, viewport), 0);
      expect(
        grid.offsetToCentre(59, viewport),
        lessThanOrEqualTo(grid.extent - viewport),
      );
    });

    test('una celda que no existe no lleva a ninguna parte', () {
      final grid = layout([for (var i = 0; i < 10; i++) 1.0]);

      expect(grid.offsetToCentre(-1, 800), 0);
      expect(grid.offsetToCentre(999, 800), 0);
    });
  });
}
