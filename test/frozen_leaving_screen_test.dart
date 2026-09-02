// La pantalla que sale se estampa una vez en lugar de repintarse.
//
// Durante un fundido cruzado hay **dos pantallas vivas a la vez**, y las dos se
// miden y se pintan en cada fotograma. Con dos rejillas de miniaturas eso es el
// doble de trabajo justo donde no sobra. La que se va no cambia mientras se va,
// asi que se rasteriza una vez y lo que se anima es esa imagen.
//
// Solo mientras dura la salida: congelarla siempre dejaria el contenido quieto.

import 'package:Fern/core/navigation/screen_choreography.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/navigation/screen_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Si ahora mismo la pantalla se esta pintando como imagen.
bool _isFrozen(WidgetTester tester) {
  final widget = tester.widget<SnapshotWidget>(find.byType(SnapshotWidget));

  return widget.controller.allowSnapshotting;
}

void main() {
  late AnimationController leaving;

  setUp(() async {
    await getIt.reset();
    // La coreografia dice si hay que animar; de fabrica, dos pantallas llanas,
    // que es un fundido cruzado.
    getIt.registerSingleton<ScreenChoreography>(ScreenChoreography());
    addTearDown(getIt.reset);
  });

  Future<void> pump(WidgetTester tester) async {
    leaving = AnimationController(
      vsync: tester,
      duration: const Duration(milliseconds: 200),
    );
    addTearDown(leaving.dispose);

    await tester.pumpWidget(MaterialApp(
      home: ScreenTransitionScope(
        entering: kAlwaysCompleteAnimation,
        leaving: leaving,
        child: const ScreenSlotTransition(
          slot: ScreenSlot.grid,
          child: Text('contenido'),
        ),
      ),
    ));
  }

  testWidgets('quieta, la pantalla se pinta de verdad', (tester) async {
    await pump(tester);

    expect(_isFrozen(tester), isFalse);
  });

  testWidgets('mientras se va, se estampa', (tester) async {
    await pump(tester);

    leaving.forward();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(_isFrozen(tester), isTrue);

    // El reloj se para antes de acabar: una prueba no puede dejarlo corriendo.
    leaving.stop();
  });

  // Al volver —se cancela la navegacion, o la pantalla vuelve a ser la de
  // delante— tiene que volver a pintarse: congelada se quedaria con la imagen
  // de entonces.
  testWidgets('y al volver, se despierta', (tester) async {
    await pump(tester);

    leaving.forward();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    leaving.stop();
    leaving.value = 0;
    await tester.pump();

    expect(_isFrozen(tester), isFalse);
  });

  testWidgets('y lo de dentro sigue estando', (tester) async {
    await pump(tester);

    expect(find.text('contenido'), findsOneWidget);
  });
}
