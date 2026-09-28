// Cargar al llegar, en paralelo con la transicion.
//
// Esperar a que la animacion terminara dejaba la rejilla vacia mientras
// corria y el contenido llegaba de golpe al acabar. Ahora se lee en el
// fotograma siguiente al de montar la pantalla, con la transicion en marcha:
// la animacion corre con los huecos de carga puestos y cada celda los va
// sustituyendo segun esta lista.

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
  testWidgets('carga en el fotograma siguiente al de montarse', (tester) async {
    var loads = 0;

    await tester.pumpWidget(MaterialApp(home: _Screen(onLoad: () => loads++)));

    expect(loads, 1);
  });

  testWidgets('sin esperar a que termine la transicion', (tester) async {
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

    expect(controller.isCompleted, isFalse);
    expect(loads, 1, reason: 'se lee mientras la transicion corre');
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
