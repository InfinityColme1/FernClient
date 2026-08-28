// La miniatura que sigue al cursor mientras se arrastra contenido.
//
// Tenia dos fallos que se veian igual desde fuera. `Draggable` conserva de
// fabrica el punto por el que se agarro el hijo, asi que agarrando una celda
// grande por su esquina la miniatura —que es pequena— se dibujaba desplazada esa
// misma distancia: el cursor se quedaba fuera de ella, y arrastrando hacia el
// menu lateral se iba tan lejos que parecia haber desaparecido.
//
// Y no habia forma de saber que se habia llegado a una etiqueta: la miniatura la
// pinta `Draggable` en la capa de encima, fuera del arbol del que arrastra y del
// que recoge.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/interaction/fern_drag_watch.dart';
import 'package:Fern/core/ui/interaction/fern_draggable_card.dart';
import 'package:Fern/core/ui/interaction/fern_drop_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _origen = Key('origen');
const _miniatura = Key('miniatura');
const _destino = Key('destino');

Future<void> _pump(
  WidgetTester tester, {
  bool aceptaElDestino = true,
  void Function(List<int>)? onAccept,
}) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          FernDraggableCard<List<int>>(
            data: const [1, 2],
            feedback: const SizedBox(
              key: _miniatura,
              width: dragFeedbackSize,
              height: dragFeedbackSize,
            ),
            // Una celda grande, como las de la rejilla: es lo que hacia visible
            // el desfase.
            child: const SizedBox(key: _origen, width: 300, height: 300),
          ),
          FernDropSlot<List<int>>(
            canAccept: (_) => aceptaElDestino,
            onAccept: (data) => onAccept?.call(data),
            builder: (context, _) =>
                const SizedBox(key: _destino, width: 200, height: 100),
          ),
        ],
      ),
    ),
  ));
}

void main() {
  setUp(() => fernDragIsOverTarget.value = false);

  testWidgets('la miniatura se cuelga del cursor, no de donde se agarro',
      (tester) async {
    await _pump(tester);

    // Se agarra por la esquina de abajo a la derecha, que es el caso peor.
    final esquina = tester.getBottomRight(find.byKey(_origen)) -
        const Offset(10, 10);
    final gesto = await tester.startGesture(esquina);
    await tester.pump();

    final destino = const Offset(40, 40);
    await gesto.moveTo(destino);
    await tester.pump();

    final miniatura = tester.getTopLeft(find.byKey(_miniatura));

    expect(
      miniatura,
      within(distance: 1, from: destino + const Offset(
        dragFeedbackCursorGap,
        dragFeedbackCursorGap,
      )),
      reason: 'la miniatura tiene que ir pegada al cursor, no a 250 px de el',
    );

    await gesto.up();
    await tester.pumpAndSettle();
  });

  testWidgets('sobre un sitio donde se puede soltar, avisa', (tester) async {
    await _pump(tester);

    final gesto =
        await tester.startGesture(tester.getCenter(find.byKey(_origen)));
    await tester.pump();

    await gesto.moveTo(tester.getCenter(find.byKey(_destino)));
    await tester.pump();

    expect(fernDragIsOverTarget.value, isTrue);

    await gesto.up();
    await tester.pumpAndSettle();
  });

  testWidgets('y deja de avisar al salirse', (tester) async {
    await _pump(tester);

    final gesto =
        await tester.startGesture(tester.getCenter(find.byKey(_origen)));
    await tester.pump();

    await gesto.moveTo(tester.getCenter(find.byKey(_destino)));
    await tester.pump();
    expect(fernDragIsOverTarget.value, isTrue);

    await gesto.moveTo(const Offset(20, 20));
    await tester.pump();
    expect(fernDragIsOverTarget.value, isFalse);

    await gesto.up();
    await tester.pumpAndSettle();
  });

  testWidgets('un destino que no acepta no avisa', (tester) async {
    await _pump(tester, aceptaElDestino: false);

    final gesto =
        await tester.startGesture(tester.getCenter(find.byKey(_origen)));
    await tester.pump();

    await gesto.moveTo(tester.getCenter(find.byKey(_destino)));
    await tester.pump();

    expect(fernDragIsOverTarget.value, isFalse);

    await gesto.up();
    await tester.pumpAndSettle();
  });

  testWidgets('soltar en el aire tambien apaga el aviso', (tester) async {
    // Si el arrastre termina fuera de todo, nadie avisa de que se ha salido: sin
    // apagarlo aqui, el siguiente arrastre empezaria encogido.
    await _pump(tester);

    final gesto =
        await tester.startGesture(tester.getCenter(find.byKey(_origen)));
    await tester.pump();

    await gesto.moveTo(tester.getCenter(find.byKey(_destino)));
    await tester.pump();
    expect(fernDragIsOverTarget.value, isTrue);

    // Se suelta lejos de cualquier destino.
    await gesto.moveTo(const Offset(5, 5));
    await gesto.up();
    await tester.pumpAndSettle();

    expect(fernDragIsOverTarget.value, isFalse);
  });
}
