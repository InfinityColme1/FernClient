// El aviso del boton de añadir al pasar por encima.
//
// El realce estaba solo en el circulo, y el boton es ancho a proposito —de eso
// se trata, que sea facil de acertar—: pasando el raton por el rotulo, que es
// la mitad del boton, se encendia algo lejos del cursor. Eso se lee como que no
// responde.
//
// Que el rotulo quepa entero se mide donde vive el hueco que se le da:
// `media_info_header_test.dart`.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _label = 'Añadir etiquetas';

Future<void> _pump(WidgetTester tester, {double? width}) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: FernAddButton.compact(label: _label, onTap: () {}),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

/// El fondo de la pildora ahora mismo.
///
/// El primero de los dos contenedores: la pildora envuelve al circulo, asi que
/// en el arbol va delante. El de dentro es el circulo, que en esta variante ya
/// no se enciende.
Color? _pill(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.byType(AnimatedContainer).first,
  );

  return (container.decoration as BoxDecoration?)?.color;
}

Future<TestGesture> _hoverLabel(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);

  await gesture.moveTo(tester.getCenter(find.text(_label)));
  await tester.pumpAndSettle();

  return gesture;
}

void main() {
  testWidgets('en reposo no se enciende', (tester) async {
    await _pump(tester);

    expect(_pill(tester)?.a ?? 0, 0);
  });

  // Por el **rotulo**, que es la mitad del boton y donde antes no pasaba nada.
  testWidgets('pasando por el rotulo, se enciende entero', (tester) async {
    await _pump(tester);
    await _hoverLabel(tester);

    expect(_pill(tester)?.a ?? 0, greaterThan(0));
  });

  testWidgets('y al salirse se apaga', (tester) async {
    await _pump(tester);
    final gesture = await _hoverLabel(tester);

    await gesture.moveTo(const Offset(600, 500));
    await tester.pumpAndSettle();

    expect(_pill(tester)?.a ?? 0, 0);
  });

  // Aunque el hueco que le den se quede corto, se recorta: nunca desborda.
  testWidgets('con menos sitio del que pide, se recorta sin desbordar',
      (tester) async {
    await _pump(tester, width: 80);

    expect(tester.takeException(), isNull);
  });
}
