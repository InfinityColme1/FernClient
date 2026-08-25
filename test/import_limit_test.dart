// Con cuánto se importa.
//
// El tope de fábrica era «todo»: pulsar el botón sin haber mirado el
// desplegable se traía la cuenta entera, que en una grande son horas de
// descarga y gigas de disco. Ahora arranca en diez, se recuerda el último
// elegido, y pedir «todo» avisa **sea cual sea la plataforma** —antes sólo
// avisaba de una—.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/presentation/widgets/confirm_remote_import_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<PreferencesService> _preferences() async =>
    PreferencesService(await SharedPreferences.getInstance());

/// Los textos en castellano, que es con lo que se comparan los avisos.
Future<AppLocalizations> _texts() => AppLocalizations.delegate.load(
      const Locale('es'),
    );

Future<void> _pumpDialog(
  WidgetTester tester, {
  required List<ImportSource> sources,
  required int limit,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ConfirmRemoteImportDialog(sources: sources, limit: limit),
    ),
  ));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('el tope de fábrica', () {
    test('es diez, no todo', () async {
      // Es la diferencia entre traerse una muestra y traerse la cuenta entera
      // sin haberlo pedido.
      expect(defaultImportLimit, 10);
      expect(defaultImportLimit, isNot(unlimitedImportLimit));
      expect((await _preferences()).getImportLimit(), defaultImportLimit);
    });

    test('está entre las opciones del desplegable', () {
      // Si no lo estuviera, el desplegable arrancaría sin nada seleccionado.
      expect(importLimitOptions, contains(defaultImportLimit));
    });
  });

  group('el último elegido', () {
    test('se recuerda', () async {
      final preferences = await _preferences();

      await preferences.setImportLimit(100);

      expect((await _preferences()).getImportLimit(), 100);
    });

    test('vale también «todo», si es lo que se eligió', () async {
      final preferences = await _preferences();

      await preferences.setImportLimit(unlimitedImportLimit);

      expect((await _preferences()).getImportLimit(), unlimitedImportLimit);
    });

    // Un valor guardado que ya no está en la lista dejaría el desplegable sin
    // nada seleccionado, y eso en Flutter no es un aviso: es una excepción al
    // pintar.
    test('uno que ya no existe cae en el de fábrica', () async {
      SharedPreferences.setMockInitialValues({importLimitPreferenceKey: 37});

      expect((await _preferences()).getImportLimit(), defaultImportLimit);
    });
  });

  group('el aviso de pedirlo todo', () {
    testWidgets('sale con cualquier plataforma', (tester) async {
      final texts = await _texts();

      await _pumpDialog(
        tester,
        sources: [ImportSource.reddit],
        limit: unlimitedImportLimit,
      );

      expect(find.text(texts.remoteImportAllWarning), findsOneWidget);
    });

    test('la de Pawchive tiene su propio aviso', () async {
      final texts = await _texts();

      // Trae publicaciones con todo lo que llevan dentro: es otra magnitud y
      // merece su propia frase.
      expect(
        texts.remoteImportHeavyWarning,
        isNot(texts.remoteImportAllWarning),
      );
    });

    testWidgets('y es la que sale en Pawchive', (tester) async {
      final texts = await _texts();

      await _pumpDialog(
        tester,
        sources: [ImportSource.pawchive],
        limit: unlimitedImportLimit,
      );

      expect(find.text(texts.remoteImportHeavyWarning), findsOneWidget);
      expect(find.text(texts.remoteImportAllWarning), findsNothing);
    });

    testWidgets('con un tope puesto no se avisa de nada', (tester) async {
      final texts = await _texts();

      await _pumpDialog(tester, sources: [ImportSource.reddit], limit: 25);

      expect(find.text(texts.remoteImportAllWarning), findsNothing);
      expect(find.text(texts.remoteImportHeavyWarning), findsNothing);
    });
  });
}
