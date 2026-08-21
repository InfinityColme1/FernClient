// Arrastrar y soltar, sin dominio de por medio.
//
// Lo que hay que sostener es **la cara de rechazo**. Sin ella, soltar algo donde
// no vale se ve exactamente igual que soltarlo bien, solo que no pasa nada, y no
// hay forma de saber si el fallo fue del sitio o de la punteria. El usuario lo
// vuelve a intentar en el mismo sitio, y otra vez.
//
// Son genericos a proposito: los usa el arbol de modelos y los va a usar
// arrastrar contenidos sobre una etiqueta del menu.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo que viaja en las pruebas.
class _Thing {
  final String name;

  const _Thing(this.name);
}

const _good = _Thing('vale');
const _bad = _Thing('no vale');

/// Una pantalla con algo que arrastrar arriba y donde soltarlo abajo.
Future<void> _pump(
  WidgetTester tester, {
  required List<_Thing> accepted,
  bool Function(_Thing)? canAccept,
  bool isDraggable = true,
  bool isSlotEnabled = true,
  List<FernDropState>? states,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Column(
        children: [
          FernDraggableCard<_Thing>(
            data: _good,
            isEnabled: isDraggable,
            child: const SizedBox(
              width: 100,
              height: 60,
              child: Text('origen'),
            ),
          ),
          const SizedBox(height: 200),
          FernDropSlot<_Thing>(
            isEnabled: isSlotEnabled,
            canAccept: canAccept ?? (_) => true,
            onAccept: accepted.add,
            builder: (context, state) {
              states?.add(state);

              return const SizedBox(
                width: 200,
                height: 100,
                child: Text('destino'),
              );
            },
          ),
        ],
      ),
    ),
  ));
}

/// Coge lo de arriba, lo lleva a lo de abajo y lo suelta.
Future<void> _dragOnto(WidgetTester tester) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.text('origen')),
  );

  await tester.pump(const Duration(milliseconds: 600));
  await gesture.moveTo(tester.getCenter(find.text('destino')));
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}

/// Lo coge y lo deja encima, sin soltarlo.
Future<TestGesture> _hoverOnto(WidgetTester tester) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.text('origen')),
  );

  await tester.pump(const Duration(milliseconds: 600));
  await gesture.moveTo(tester.getCenter(find.text('destino')));
  await tester.pump();

  return gesture;
}

void main() {
  group('soltar', () {
    testWidgets('lo que se acepta llega', (tester) async {
      final accepted = <_Thing>[];
      await _pump(tester, accepted: accepted);

      await _dragOnto(tester);

      expect(accepted, [_good]);
    });

    testWidgets('lo que no se acepta no llega', (tester) async {
      final accepted = <_Thing>[];
      await _pump(tester, accepted: accepted, canAccept: (_) => false);

      await _dragOnto(tester);

      expect(accepted, isEmpty);
    });

    testWidgets('con la zona apagada tampoco', (tester) async {
      final accepted = <_Thing>[];
      await _pump(tester, accepted: accepted, isSlotEnabled: false);

      await _dragOnto(tester);

      expect(accepted, isEmpty);
    });

    testWidgets('con el origen apagado no se arrastra nada', (tester) async {
      final accepted = <_Thing>[];
      await _pump(tester, accepted: accepted, isDraggable: false);

      await _dragOnto(tester);

      expect(accepted, isEmpty);
    });
  });

  group('lo que se ve', () {
    testWidgets('en reposo no hay estado de nada', (tester) async {
      final states = <FernDropState>[];
      await _pump(tester, accepted: [], states: states);

      expect(states.last, FernDropState.idle);
    });

    testWidgets('con algo aceptable encima, se dice', (tester) async {
      final states = <FernDropState>[];
      await _pump(tester, accepted: [], states: states);

      final gesture = await _hoverOnto(tester);

      expect(states.last, FernDropState.accepting);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('con algo que no vale encima, tambien se dice', (tester) async {
      final states = <FernDropState>[];
      await _pump(
        tester,
        accepted: [],
        canAccept: (_) => false,
        states: states,
      );

      final gesture = await _hoverOnto(tester);

      // Esta es la que no se puede omitir: sin ella, no valer se ve igual que
      // valer.
      expect(states.last, FernDropState.rejecting);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('al soltar vuelve al reposo', (tester) async {
      final states = <FernDropState>[];
      await _pump(tester, accepted: [], states: states);

      await _dragOnto(tester);

      expect(states.last, FernDropState.idle);
    });

    testWidgets('mientras se arrastra queda el hueco atenuado', (tester) async {
      await _pump(tester, accepted: []);

      final gesture = await _hoverOnto(tester);

      // Atenuado y no invisible: se ve de donde salio, y si se suelta donde no
      // vale, el ojo ya sabe a donde vuelve.
      expect(find.byType(Opacity), findsWidgets);
      expect(find.text('origen'), findsNWidgets(2));

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('dentro de un visor con zoom', () {
    // El arbol de modelos vive dentro de un `InteractiveViewer`, que es de los
    // widgets que se quedan los gestos. Esto sostiene que una tarjeta metida
    // dentro **se sigue pudiendo arrastrar**: el dia que alguien envuelva el
    // lienzo en algo que si se coma el arrastre, esta prueba lo dice.
    testWidgets('una tarjeta metida dentro se sigue arrastrando',
        (tester) async {
      final accepted = <_Thing>[];

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Row(
            children: [
              SizedBox(
                width: 400,
                height: 600,
                child: InteractiveViewer(
                  constrained: false,
                  child: const SizedBox(
                    width: 400,
                    height: 600,
                    child: FernDraggableCard<_Thing>(
                      data: _good,
                      child: SizedBox(
                        width: 100,
                        height: 60,
                        child: Text('origen'),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FernDropSlot<_Thing>(
                  canAccept: (_) => true,
                  onAccept: accepted.add,
                  builder: (context, state) => const SizedBox(
                    height: 600,
                    child: Text('destino'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ));

      await _dragOnto(tester);

      expect(accepted, [_good]);
    });
  });

  group('quien decide', () {
    testWidgets('la zona pregunta por lo que le traen', (tester) async {
      final asked = <_Thing>[];

      await _pump(
        tester,
        accepted: [],
        canAccept: (thing) {
          asked.add(thing);
          return thing == _good;
        },
      );

      await _dragOnto(tester);

      // Aqui no se sabe que se arrastra ni por que unas cosas valen: eso es de
      // quien lo usa.
      expect(asked, contains(_good));
      expect(asked, isNot(contains(_bad)));
    });
  });
}
