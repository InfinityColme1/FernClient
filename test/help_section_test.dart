// La sección de ayuda, montada como la monta el diálogo de ajustes.
//
// El diálogo mete cada sección dentro de un `SingleChildScrollView`, así que la
// sección recibe **alto sin límite**. Una pieza flexible ahí dentro no es un
// defecto de estilo: revienta la maquetación.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/features/settings/presentation/widgets/help_settings_section.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_tours.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(
      // Igual que el diálogo: el que desplaza es el de fuera.
      body: SingleChildScrollView(child: HelpSettingsSection()),
    ),
  ));
}

void main() {
  testWidgets('cabe donde la mete el diálogo de ajustes', (tester) async {
    await _pump(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('salen los seis recorridos', (tester) async {
    await _pump(tester);

    for (final tour in TutorialTour.values) {
      expect(find.byIcon(tour.icon), findsOneWidget, reason: tour.name);
    }
  });
}
