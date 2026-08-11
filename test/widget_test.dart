// Comprueba que los cuatro idiomas soportados resuelven y traducen.
//
// No monta la aplicación entera (necesitaría la base de datos y el reproductor
// de vídeo): monta el mismo `MaterialApp` con los delegados generados y lee los
// textos con el idioma puesto, que es lo que hace cada pantalla.

import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppLocalizations> _textsIn(WidgetTester tester, String languageCode) async {
  late AppLocalizations texts;

  await tester.pumpWidget(MaterialApp(
    locale: Locale(languageCode),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(builder: (context) {
      texts = AppLocalizations.of(context);
      return const SizedBox.shrink();
    }),
  ));

  return texts;
}

void main() {
  testWidgets('los cuatro idiomas están soportados', (tester) async {
    expect(
      AppLocalizations.supportedLocales.map((locale) => locale.languageCode).toSet(),
      {'en', 'fr', 'es', 'ca'},
    );
  });

  testWidgets('cada idioma trae sus propios textos', (tester) async {
    expect((await _textsIn(tester, 'en')).settingsTitle, 'Settings');
    expect((await _textsIn(tester, 'es')).settingsTitle, 'Configuración');
    expect((await _textsIn(tester, 'ca')).settingsTitle, 'Configuració');
    expect((await _textsIn(tester, 'fr')).settingsTitle, 'Paramètres');
  });

  testWidgets('los plurales concuerdan con el número', (tester) async {
    final texts = await _textsIn(tester, 'es');

    expect(texts.mediaCount(0), 'Sin contenido');
    expect(texts.mediaCount(1), '1 archivo');
    expect(texts.mediaCount(7), '7 archivos');
  });
}
