// Los mandos del visor, que se quitan de en medio cuando no hacen falta.
//
// Lo que se comprueba aqui es cuando avisan de que el raton esta encima. La
// cuenta atras se reinicia con el movimiento, y quieto sobre un boton no hay
// movimiento: sin el aviso, el boton se desvanecia debajo del cursor de quien
// iba a pulsarlo.
//
// Y el aviso tiene que ser **del boton**, no de la franja donde vive. Una barra
// de acciones ocupa el ancho entero y casi todo es aire; si el aire contara, los
// mandos no se irian jamas.

import 'package:Fern/core/ui/display/fern_fading_controls.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Un raton que empieza **lejos de la barra**.
///
/// En el origen estaria justo encima del primer boton, y entonces la primera
/// medida ya vendria con un aviso de entrada dentro.
const _fuera = Offset(400, 500);

Future<TestGesture> _raton(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: _fuera);
  addTearDown(gesture.removePointer);
  await tester.pump();

  return gesture;
}

/// Una barra como la del visor: dos botones en los extremos y aire en medio.
Future<void> _pump(
  WidgetTester tester, {
  required bool isVisible,
  ValueChanged<bool>? onHoverChanged,
}) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: FernFadingControls(
        isVisible: isVisible,
        onHoverChanged: onHoverChanged,
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Symbols.close)),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Symbols.check)),
          ],
        ),
      ),
    ),
  ));
}

void main() {
  testWidgets('avisa al entrar y al salir de un boton', (tester) async {
    final avisos = <bool>[];
    await _pump(tester, isVisible: true, onHoverChanged: avisos.add);

    final raton = await _raton(tester);

    await raton.moveTo(tester.getCenter(find.byIcon(Symbols.close)));
    await tester.pump();
    expect(avisos, [true]);

    await raton.moveTo(_fuera);
    await tester.pump();
    expect(avisos, [true, false]);
  });

  testWidgets('el hueco entre botones no cuenta', (tester) async {
    // Es lo que hacia que en pantalla completa no se fueran nunca: la barra
    // ocupa el ancho entero, asi que el raton parado en cualquier punto de esa
    // franja se tomaba por «encima de un mando».
    final avisos = <bool>[];
    await _pump(tester, isVisible: true, onHoverChanged: avisos.add);

    final raton = await _raton(tester);
    await raton.moveTo(tester.getCenter(find.byType(Spacer)));
    await tester.pump();

    expect(avisos, isEmpty);
  });

  testWidgets('escondidos no atienden al raton', (tester) async {
    // Un mando desvanecido sigue ocupando su sitio, y si atendiera al raton la
    // cuenta atras no llegaria a terminar nunca: bastaria con dejar el cursor
    // parado encima de donde estuvo.
    final avisos = <bool>[];
    await _pump(tester, isVisible: false, onHoverChanged: avisos.add);

    final raton = await _raton(tester);
    await raton.moveTo(tester.getCenter(find.byIcon(Symbols.close)));
    await tester.pump();

    expect(avisos, isEmpty);
  });
}
