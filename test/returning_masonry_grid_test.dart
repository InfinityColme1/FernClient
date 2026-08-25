// La rejilla que vuelve a lo que se acaba de mirar.
//
// La cuenta de a qué altura hay que ir se comprueba aparte
// (`grid_return_scroll_test.dart`). Lo que se sostiene aquí es lo que sólo se ve
// montándola: que el salto ocurra de verdad, que deje la celda **dentro de la
// pantalla**, que no se dé cuando no hay a dónde volver, y sobre todo que se dé
// **una sola vez** — repintar la rejilla porque se marque algo no puede
// arrastrar al usuario de vuelta a donde estaba mirando hace un rato.

import 'package:Fern/features/media/presentation/widgets/returning_masonry_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cell = 200.0;
  const count = 200;

  /// Monta la rejilla con celdas de alto fijo, de una sola columna: así la
  /// posición de cada una es sabida y se puede decir si la que se buscaba ha
  /// quedado a la vista o no.
  Future<void> pump(WidgetTester tester, {int? focusIndex}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 600,
          child: ReturningMasonryGrid(
            columns: 1,
            padding: EdgeInsets.zero,
            cacheExtent: 600,
            spacing: 0,
            itemCount: count,
            focusIndex: focusIndex,
            itemBuilder: (context, index, key) => SizedBox(
              key: key,
              height: cell,
              child: Text('celda $index'),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  /// A qué altura ha quedado el scroll.
  double offsetOf(WidgetTester tester) =>
      tester.widget<Scrollable>(find.byType(Scrollable)).controller!.offset;

  testWidgets('sin nada que buscar se queda al principio', (tester) async {
    await pump(tester);

    expect(offsetOf(tester), 0);
    expect(find.text('celda 0'), findsOneWidget);
  });

  testWidgets('va a buscar la celda y la deja a la vista', (tester) async {
    await pump(tester, focusIndex: 120);

    expect(offsetOf(tester), greaterThan(0));
    // Lo que de verdad importa: que se vea. El número exacto es cosa de la
    // cuenta, que se comprueba aparte.
    expect(find.text('celda 120'), findsOneWidget);
  });

  testWidgets('y la deja centrada, no pegada al canto', (tester) async {
    await pump(tester, focusIndex: 120);

    final box = tester.getRect(find.text('celda 120'));

    // El medio de la celda en el medio de la pantalla, que mide 600.
    expect(box.center.dy, closeTo(300, 1));
  });

  // Con celdas de alto desigual la cuenta se desvía: estima por la posición en
  // la lista, y en una rejilla de mampostería cada celda mide lo que le toca.
  // Es el caso de verdad —contenido apaisado y contenido vertical mezclados— y
  // lo que lo salva es el afinado con la celda ya construida.
  testWidgets('aunque las celdas midan cosas distintas', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 600,
          child: ReturningMasonryGrid(
            columns: 1,
            padding: EdgeInsets.zero,
            cacheExtent: 600,
            spacing: 0,
            itemCount: count,
            focusIndex: 120,
            itemBuilder: (context, index, key) => SizedBox(
              key: key,
              height: index.isEven ? 80.0 : 320.0,
              child: Text('celda $index'),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.getRect(find.text('celda 120')).center.dy, closeTo(300, 1));
  });

  testWidgets('la primera no pide un desplazamiento imposible', (tester) async {
    await pump(tester, focusIndex: 0);

    expect(offsetOf(tester), 0);
  });

  testWidgets('la última se queda pegada al final', (tester) async {
    await pump(tester, focusIndex: count - 1);

    expect(find.text('celda ${count - 1}'), findsOneWidget);
  });

  // Lo que separa esto de un salto molesto.
  testWidgets('sólo salta una vez: repintar no arrastra de vuelta',
      (tester) async {
    await pump(tester, focusIndex: 120);

    final landed = offsetOf(tester);

    // El usuario sigue mirando hacia abajo por su cuenta.
    await tester.drag(find.byType(Scrollable), const Offset(0, -400));
    await tester.pumpAndSettle();

    final moved = offsetOf(tester);
    expect(moved, greaterThan(landed));

    // Y la rejilla se rehace por cualquier motivo: marcar algo, llegar
    // contenido nuevo, cambiar un filtro.
    await pump(tester, focusIndex: 120);

    expect(offsetOf(tester), moved);
  });

  testWidgets('pero una celda nueva sí que se busca', (tester) async {
    await pump(tester, focusIndex: 120);
    await pump(tester, focusIndex: 30);

    expect(find.text('celda 30'), findsOneWidget);
  });
}
