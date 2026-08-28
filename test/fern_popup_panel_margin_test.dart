// Un panel colgado de un boton del extremo derecho de la cabecera.
//
// Lo unico que se comprueba aqui es que **no se pegue al borde de la ventana**.
// El panel se corre hacia la izquierda lo justo para caber, y ese calculo se
// hacia con el ancho del contenido en vez de con el del panel: con relleno
// lateral se salia justo esos pixeles y quedaba pegado al canto de la pantalla.

import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

const _panelWidth = 320.0;
const _margin = 32.0;
const _screen = Size(900, 600);

Future<void> _open(
  WidgetTester tester, {
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
    vertical: AppSpacing.l,
    horizontal: AppSpacing.l,
  ),
}) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      // Arriba a la derecha, que es donde vive el boton de tareas.
      body: Align(
        alignment: Alignment.topRight,
        child: FernPopupPanel(
          width: _panelWidth,
          windowMargin: _margin,
          padding: padding,
          builder: (context, toggle) => IconButton(
            onPressed: toggle,
            icon: const Icon(Symbols.sync),
          ),
          children: const [Text('Tareas en segundo plano')],
        ),
      ),
    ),
  ));

  await tester.tap(find.byType(IconButton));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// El rectangulo que ocupa el panel abierto.
Rect _panelRect(WidgetTester tester) {
  // El primer Material que envuelve al contenido es el del propio panel; los de
  // mas afuera son el andamiaje de la pantalla.
  return tester.getRect(find.ancestor(
    of: find.text('Tareas en segundo plano'),
    matching: find.byType(Material),
  ).first);
}

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  testWidgets('no se pega al borde derecho de la ventana', (tester) async {
    tester.view.physicalSize = _screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _open(tester);

    final panel = _panelRect(tester);

    // El relleno lateral cuenta: con el ancho del contenido a secas, el panel se
    // salia justo esos pixeles.
    expect(panel.right, lessThanOrEqualTo(_screen.width - _margin));
  });

  testWidgets('sin relleno lateral tampoco', (tester) async {
    tester.view.physicalSize = _screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _open(tester, padding: EdgeInsets.zero);

    expect(_panelRect(tester).right, lessThanOrEqualTo(_screen.width - _margin));
  });

  testWidgets('no se corre mas de lo necesario', (tester) async {
    tester.view.physicalSize = _screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _open(tester);

    // Pegado al margen, no en mitad de la pantalla: el panel cuelga de su boton
    // y separarlo de mas lo desconecta de lo que se ha pulsado.
    expect(
      _panelRect(tester).right,
      closeTo(_screen.width - _margin, 1),
    );
  });
}
