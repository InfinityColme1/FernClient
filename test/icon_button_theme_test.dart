// Un botón de icono apagado tiene que verse apagado.
//
// No tiene ni fondo ni texto, así que el color del icono es lo único que
// distingue "no se puede pulsar" de "no ha pasado nada al pulsar".

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

Color? _iconColor(WidgetTester tester, IconData icon) {
  final widget = tester.widget<Icon>(find.byIcon(icon));
  if (widget.color != null) return widget.color;

  return IconTheme.of(tester.element(find.byIcon(icon))).color;
}

Future<void> _pump(WidgetTester tester, {required bool isEnabled}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: IconButton(
        onPressed: isEnabled ? () {} : null,
        icon: const Icon(Symbols.refresh),
      ),
    ),
  ));
}

void main() {
  testWidgets('un botón de icono que se puede pulsar va en negro',
      (tester) async {
    await _pump(tester, isEnabled: true);

    expect(_iconColor(tester, Symbols.refresh), AppColors.light.black);
  });

  testWidgets('un botón de icono apagado va en gris claro', (tester) async {
    await _pump(tester, isEnabled: false);

    expect(_iconColor(tester, Symbols.refresh), AppColors.light.lightgray);
  });
}
