// El botón de quitar de la píldora, el que lleva cada etiqueta elegida en el
// diálogo de asignación.
//
// Se monta el widget de verdad: la píldora no necesita ni base de datos ni
// blocs, recibe el texto y qué hacer al quitarla.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/display/fern_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

Future<void> _pumpChip(WidgetTester tester, {VoidCallback? onRemove}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Center(child: FernChip(label: 'Miraculous', onRemove: onRemove)),
    ),
  ));
}

void main() {
  testWidgets('sin nada que hacer al quitarla no lleva botón', (tester) async {
    await _pumpChip(tester);

    expect(find.text('Miraculous'), findsOneWidget);
    expect(find.byIcon(Symbols.cancel), findsNothing);
  });

  testWidgets('el botón de quitar avisa al pulsarlo', (tester) async {
    var removed = 0;
    await _pumpChip(tester, onRemove: () => removed++);

    expect(find.byIcon(Symbols.cancel), findsOneWidget);

    await tester.tap(find.byIcon(Symbols.cancel));
    await tester.pump();

    expect(removed, 1);
  });
}
