// Comprueba que la ayuda del modo fernie no se queda con lo que va a la pestaña
// de una región.
//
// El texto de ayuda ocupa la franja de arriba del contenido, que es justo donde
// sale la pestaña de una región marcada cerca del borde superior. Aquí se
// reproduce esa pila —algo pulsable debajo, la ayuda encima y tapándolo del
// todo— y se comprueba lo que se espera de ella: que el texto se aparta al pasar
// el ratón, que deja pasar los clics y que los botones de la barra siguen
// respondiendo.
//
// La ayuda se pone cubriendo toda el área a propósito: si sólo se solapara un
// poco, el clic podría acertar de casualidad por caer en un hueco y la prueba no
// diría nada.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

/// La pila del modo fernie: lo pulsable debajo y la ayuda por encima.
class _Harness extends StatefulWidget {
  final VoidCallback onTabPressed;
  final VoidCallback onCancelPressed;

  const _Harness({required this.onTabPressed, required this.onCancelPressed});

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  bool _isHintHovered = false;

  void _setHintHovered(bool value) {
    if (_isHintHovered == value) return;
    setState(() => _isHintHovered = value);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Lo que hay debajo: la pestaña de la región elegida.
        Positioned.fill(
          child: Center(
            child: SizedBox(
              width: 120,
              height: 40,
              child: ElevatedButton(
                onPressed: widget.onTabPressed,
                child: const Text('pestaña'),
              ),
            ),
          ),
        ),

        // Encima, el botón de cancelar de la barra, que nunca se aparta.
        Positioned(
          top: 0,
          left: 0,
          child: IconButton(
            onPressed: widget.onCancelPressed,
            icon: const Icon(Symbols.close),
          ),
        ),

        // Y la ayuda, tapándolo todo.
        Positioned.fill(
          child: MouseRegion(
            opaque: false,
            hitTestBehavior: HitTestBehavior.translucent,
            onEnter: (_) => _setHintHovered(true),
            onExit: (_) => _setHintHovered(false),
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _isHintHovered ? 0 : 1,
                duration: const Duration(milliseconds: 10),
                child: const Center(
                  child: Text('arrastra para marcar una región'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _pump(
  WidgetTester tester, {
  required VoidCallback onTabPressed,
  required VoidCallback onCancelPressed,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: SizedBox(
        width: 600,
        height: 400,
        child: _Harness(
          onTabPressed: onTabPressed,
          onCancelPressed: onCancelPressed,
        ),
      ),
    ),
  ));
}

double _hintOpacity(WidgetTester tester) {
  return tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;
}

void main() {
  testWidgets('la ayuda se aparta al pasar el ratón por encima',
      (tester) async {
    await _pump(tester, onTabPressed: () {}, onCancelPressed: () {});

    expect(_hintOpacity(tester), 1, reason: 'de partida se lee');

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    await gesture.moveTo(tester.getCenter(find.byType(_Harness)));
    await tester.pumpAndSettle();

    expect(_hintOpacity(tester), 0, reason: 'con el ratón encima estorba');

    await gesture.moveTo(const Offset(-100, -100));
    await tester.pumpAndSettle();

    expect(_hintOpacity(tester), 1, reason: 'al salir vuelve');
  });

  testWidgets('pulsar sobre la ayuda llega a lo que hay debajo',
      (tester) async {
    var tabPresses = 0;

    await _pump(
      tester,
      onTabPressed: () => tabPresses++,
      onCancelPressed: () {},
    );

    // La ayuda cubre por completo a la pestaña.
    //
    // Hoy un texto suelto no se queda con las pulsaciones, así que esto no falla
    // aunque se le quite el `IgnorePointer`: es una red por si algún día la
    // ayuda deja de ser un texto pelado (un fondo, una píldora, un tooltip
    // propio) y empieza a comerse los clics de lo que tiene debajo.
    await tester.tapAt(tester.getCenter(find.text('pestaña')));
    await tester.pumpAndSettle();

    expect(tabPresses, 1);
  });

  testWidgets('los botones de la barra siguen respondiendo', (tester) async {
    var cancelPresses = 0;

    await _pump(
      tester,
      onTabPressed: () {},
      onCancelPressed: () => cancelPresses++,
    );

    // Cancelar está debajo de la ayuda igual que la pestaña, y tampoco puede
    // quedarse sin sus pulsaciones: es una de las dos salidas del modo. Vale lo
    // mismo que se dice arriba sobre lo que esta prueba llega a demostrar.
    await tester.tap(find.byIcon(Symbols.close));
    await tester.pumpAndSettle();

    expect(cancelPresses, 1);
  });
}
