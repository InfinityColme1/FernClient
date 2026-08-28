// Comprueba los mandos que se desvanecen del visor.
//
// Lo que importa de ellos es que escondidos no se puedan pulsar: la opacidad no
// deja de atender al raton por bajar a cero, asi que un boton desvanecido
// seguiria respondiendo y el clic a ciegas estaria esperando a pasar.
//
// Aqui hay ademas un caso que no comprueba este widget sino una suposicion sobre
// Flutter, y esta a proposito: dio pie a un arreglo que sobraba. Pulsar un boton
// con el raton **no le da el foco del teclado**, asi que la tecla siguiente no
// vuelve a dispararlo y no hacia falta sacar estos mandos del reparto de teclas.
// Si algun dia deja de ser cierto, esta prueba lo dira.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

Future<void> _pump(
  WidgetTester tester, {
  required bool isVisible,
  required VoidCallback onPressed,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Center(
        child: FernFadingControls(
          isVisible: isVisible,
          child: IconButton(
            onPressed: onPressed,
            icon: const Icon(Symbols.fullscreen),
          ),
        ),
      ),
    ),
  ));
}

void main() {
  testWidgets('a la vista se pulsa como cualquier boton', (tester) async {
    var pressed = 0;

    await _pump(tester, isVisible: true, onPressed: () => pressed++);
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(pressed, 1);
  });

  testWidgets('escondido no se puede pulsar', (tester) async {
    var pressed = 0;

    await _pump(tester, isVisible: false, onPressed: () => pressed++);
    await tester.tap(find.byType(IconButton), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(pressed, 0);
  });

  testWidgets('el desvanecido llega a cero de verdad', (tester) async {
    await _pump(tester, isVisible: false, onPressed: () {});
    await tester.pumpAndSettle();

    final opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );

    expect(opacity.opacity, 0);
  });

  testWidgets('pulsar con el raton no se queda con el teclado', (tester) async {
    var pressed = 0;

    await _pump(tester, isVisible: true, onPressed: () => pressed++);
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    // Enter activa un boton de Material que tenga el foco. Si pulsarlo con el
    // raton se lo diera, esto lo dispararia por segunda vez y el visor tendria
    // que defenderse de ello.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(pressed, 1);
  });
}
