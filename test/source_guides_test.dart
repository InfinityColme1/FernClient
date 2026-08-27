// Las guias para conectar Fern con cada fuente remota.
//
// Cada plataforma pide una cosa distinta y ninguna se puede evitar: unas quieren
// que registres una aplicacion, otras una clave de su ficha y otras que entres
// tu porque tienen captcha. Lo que si esta en nuestra mano es que no haya que ir
// a buscar como se hace a ninguna otra parte, que es lo que desanima antes de
// empezar.
//
// Lo que se comprueba: que todas las fuentes que piden algo tengan la suya, que
// esten en los cuatro idiomas, y que el paso que se falla vaya destacado — que
// es lo unico que distingue una guia util de una lista de pasos.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/settings/domain/entities/source_guide.dart';
import 'package:Fern/features/settings/presentation/widgets/source_guide_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Las fuentes que necesitan que el usuario haga algo antes de poder importar.
const _configurables = [
  ImportSource.reddit,
  ImportSource.danbooru,
  ImportSource.gelbooru,
  ImportSource.pixiv,
  ImportSource.pinterest,
  ImportSource.pawchive,
];

Future<AppLocalizations> _texts([Locale locale = const Locale('es')]) =>
    AppLocalizations.delegate.load(locale);

Future<void> _open(WidgetTester tester, SourceGuide guide) async {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SourceGuideDialog(guide: guide)),
  ));
}

void main() {
  group('la tabla', () {
    test('todas las fuentes que piden algo tienen guia', () async {
      final texts = await _texts();

      for (final source in _configurables) {
        expect(sourceGuideFor(source, texts), isNotNull,
            reason: source.id);
      }
    });

    test('lo que no pide nada no tiene guia', () async {
      final texts = await _texts();

      // El equipo local y el navegador no piden credenciales de nadie.
      expect(sourceGuideFor(ImportSource.local, texts), isNull);
      expect(sourceGuideFor(ImportSource.browser, texts), isNull);
    });

    test('todas llevan pasos y a donde ir', () async {
      final texts = await _texts();

      for (final source in _configurables) {
        final guide = sourceGuideFor(source, texts)!;

        expect(guide.steps, isNotEmpty, reason: source.id);
        expect(guide.openUrl, startsWith('https://'), reason: source.id);
        expect(guide.openLabel, isNotEmpty, reason: source.id);
      }
    });

    test('todas senalan el paso que se falla', () async {
      final texts = await _texts();

      for (final source in _configurables) {
        final guide = sourceGuideFor(source, texts)!;

        // Siempre es del mismo tipo: uno que la otra web deja pasar sin
        // quejarse y que rompe todo lo demas en silencio.
        expect(
          guide.steps.where((step) => step.isCritical),
          hasLength(1),
          reason: source.id,
        );
      }
    });

    test('estan en los cuatro idiomas y no se repiten', () async {
      for (final locale in const [
        Locale('en'),
        Locale('es'),
        Locale('ca'),
        Locale('fr'),
      ]) {
        final texts = await _texts(locale);
        final titles = <String>{};

        for (final source in _configurables) {
          final guide = sourceGuideFor(source, texts)!;

          expect(guide.title, isNotEmpty, reason: '${source.id} $locale');
          expect(titles.add(guide.title), isTrue,
              reason: 'dos fuentes con el mismo titulo en $locale');
        }
      }
    });

    test('la de Reddit lleva la direccion que hay que copiar', () async {
      final texts = await _texts();
      final guide = sourceGuideFor(ImportSource.reddit, texts)!;

      // Es obligatoria, no se usa para nada, y equivocarse en ella deja la
      // aplicacion creada y sin funcionar.
      expect(
        guide.steps.map((step) => step.copyable).whereType<String>(),
        [redditRedirectUri],
      );
    });
  });

  group('el dialogo', () {
    testWidgets('numera los pasos', (tester) async {
      final texts = await _texts();
      final guide = sourceGuideFor(ImportSource.gelbooru, texts)!;

      await _open(tester, guide);

      for (var step = 1; step <= guide.steps.length; step++) {
        expect(find.text('$step'), findsOneWidget, reason: 'paso $step');
      }
    });

    testWidgets('ensena las notas', (tester) async {
      final texts = await _texts();
      final guide = sourceGuideFor(ImportSource.pawchive, texts)!;

      await _open(tester, guide);

      for (final note in guide.notes) {
        expect(find.text(note), findsOneWidget);
      }
    });

    testWidgets('lo que hay que copiar se copia', (tester) async {
      final copied = <String>[];

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );

      final texts = await _texts();
      await _open(tester, sourceGuideFor(ImportSource.reddit, texts)!);

      await tester.tap(find.byTooltip(texts.redditGuideCopy));
      await tester.pump();

      expect(copied, [redditRedirectUri]);
    });

    testWidgets('una guia sin nada que copiar no ensena el boton',
        (tester) async {
      final texts = await _texts();
      await _open(tester, sourceGuideFor(ImportSource.pixiv, texts)!);

      expect(find.byTooltip(texts.redditGuideCopy), findsNothing);
    });
  });
}
