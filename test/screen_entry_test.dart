// Cargar al terminar de entrar, no encima de la transicion.
//
// Abrir una pantalla es leer de la base de datos, y con una biblioteca grande
// eso se come varios fotogramas. Hecho en `initState`, ese trabajo cae justo
// encima de la animacion: la transicion no llega a verse y la ventana parece
// colgada. Lo que se arregla no es la espera —que es la misma— sino que el
// cambio de pantalla se vea.

import 'package:Fern/core/navigation/screen_entry.dart';
import 'package:Fern/core/navigation/screen_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Una pantalla de mentira que apunta cuantas veces le han pedido cargar.
class _Screen extends StatefulWidget {
  final void Function() onLoad;

  const _Screen({required this.onLoad});

  @override
  State<_Screen> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> with ScreenEntryTask<_Screen> {
  @override
  void onScreenEntered() => widget.onLoad();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  testWidgets('sin transicion carga en el acto', (tester) async {
    var loads = 0;

    await tester.pumpWidget(MaterialApp(home: _Screen(onLoad: () => loads++)));

    expect(loads, 1);
  });

  testWidgets('con la transicion a medias, espera', (tester) async {
    var loads = 0;

    final controller = AnimationController(
      vsync: tester,
      duration: const Duration(milliseconds: 300),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(MaterialApp(
      home: ScreenTransitionScope(
        entering: controller,
        leaving: kAlwaysDismissedAnimation,
        child: _Screen(onLoad: () => loads++),
      ),
    ));

    expect(loads, 0, reason: 'la transicion no ha terminado');

    controller.forward();
    await tester.pumpAndSettle();

    expect(loads, 1);
  });

  testWidgets('con la transicion ya terminada, en el acto', (tester) async {
    var loads = 0;

    await tester.pumpWidget(MaterialApp(
      home: ScreenTransitionScope(
        entering: kAlwaysCompleteAnimation,
        leaving: kAlwaysDismissedAnimation,
        child: _Screen(onLoad: () => loads++),
      ),
    ));

    expect(loads, 1);
  });

  // La red: una transicion que se queda a medias no puede dejar la pantalla sin
  // cargar para siempre.
  testWidgets('y si la transicion no termina, carga igual', (tester) async {
    var loads = 0;

    final controller = AnimationController(
      vsync: tester,
      duration: const Duration(milliseconds: 300),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(MaterialApp(
      home: ScreenTransitionScope(
        entering: controller,
        leaving: kAlwaysDismissedAnimation,
        child: _Screen(onLoad: () => loads++),
      ),
    ));

    expect(loads, 0);

    await tester.pump(const Duration(seconds: 2));

    expect(loads, 1);
  });

  // Repintar la pantalla no es volver a entrar en ella: `didChangeDependencies`
  // se llama mas de una vez y cargar en cada una seria peor que no esperar.
  testWidgets('carga una sola vez', (tester) async {
    var loads = 0;

    await tester.pumpWidget(MaterialApp(home: _Screen(onLoad: () => loads++)));
    await tester.pumpWidget(MaterialApp(home: _Screen(onLoad: () => loads++)));
    await tester.pump();

    expect(loads, 1);
  });
}
