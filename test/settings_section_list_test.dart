// La columna de secciones de los ajustes, con la ventana en su tamaño mínimo.
//
// Es lo que se rompe al añadir una sección: eran once y la columna no se
// desplazaba, así que en cuanto la ventana era más baja que el diálogo la última
// se salía por abajo —y encima sin forma de llegar a ella—. Como ya no hay un
// layout aparte al que caer cuando la ventana se estrecha, esto tiene que
// aguantar en el tamaño más pequeño al que la ventana puede llegar.

import 'dart:io';

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/features/settings/presentation/widgets/settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/settings_section_list.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _locales = [Locale('en'), Locale('es'), Locale('ca'), Locale('fr')];

/// El alto mínimo de la ventana, el que impone el ejecutable, menos lo que la
/// barra superior y los márgenes del diálogo se quedan. Es el peor caso real.
const _shortestDialogHeight = 460.0;

Future<void> _loadAppFont() async {
  final loader = FontLoader('Google Sans Flex');
  for (final weight in ['Light', 'Medium', 'Regular', 'SemiBold']) {
    loader.addFont(File('assets/fonts/GoogleSansFlex_24pt-$weight.ttf')
        .readAsBytes()
        .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer)));
  }
  await loader.load();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadAppFont();
  });

  Future<Object?> _pumpAt(
    WidgetTester tester, {
    required double height,
    required Locale locale,
    SettingsSection selected = SettingsSection.language,
  }) async {
    // El árbol se tira abajo antes de cada medida: reaprovechando los render
    // objects, el aviso de desbordamiento sólo se da la primera vez y las
    // medidas siguientes saldrían limpias sin serlo.
    await tester.pumpWidget(const SizedBox.shrink());
    tester.takeException();

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: height,
            child: SettingsSectionList(
              selected: selected,
              onSelected: (_) {},
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    return tester.takeException();
  }

  testWidgets('cabe en la ventana más pequeña, en los cuatro idiomas',
      (tester) async {
    for (final locale in _locales) {
      expect(
        await _pumpAt(tester, height: _shortestDialogHeight, locale: locale),
        isNull,
        reason: 'la lista de secciones desborda en ${locale.languageCode}',
      );
    }
  });

  testWidgets('y aguanta aunque el hueco sea absurdamente bajo',
      (tester) async {
    // No es un tamaño al que se pueda llegar, pero si aquí no desborda es que
    // no desborda por alto en ningún sitio.
    expect(
      await _pumpAt(tester, height: 120, locale: const Locale('es')),
      isNull,
    );
  });

  testWidgets('se puede llegar a la última sección desplazándose',
      (tester) async {
    await _pumpAt(tester, height: _shortestDialogHeight, locale: const Locale('es'));

    final texts = await AppLocalizations.delegate.load(const Locale('es'));
    final last = SettingsSection.values.last;

    // Desbordar es feo; no poder llegar a una sección es que la sección no
    // existe para quien tiene la ventana pequeña.
    await tester.scrollUntilVisible(find.text(last.title(texts)), 100);

    expect(find.text(last.title(texts)), findsOneWidget);
  });

  testWidgets('con sitio de sobra están todas a la vista', (tester) async {
    await _pumpAt(tester, height: 900, locale: const Locale('es'));

    final texts = await AppLocalizations.delegate.load(const Locale('es'));

    for (final section in SettingsSection.values) {
      expect(
        find.text(section.title(texts)),
        findsOneWidget,
        reason: 'falta ${section.name}',
      );
    }
  });
}
