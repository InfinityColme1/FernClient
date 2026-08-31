// El diálogo que dice de dónde ha salido cada cosa que tiene un contenido.
//
// Lo que hay que sostener aquí es **la diferencia entre lo que consta y lo que
// se deduce**: para el contenido anterior al registro no se apuntó nada, y una
// lista de motivos sin ese aviso se lee como un registro. Diría que consta algo
// que no consta, que es peor que no tener la pantalla.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/tag_log_entry_entity.dart';
import 'package:Fern/features/media/presentation/widgets/tag_log_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

TagLogEntryEntity _entry(
  TagLogReason reason, {
  String label = 'Rombo',
  String? detail,
}) =>
    TagLogEntryEntity(
      mediaId: 1,
      reason: reason,
      label: label,
      detail: detail,
      at: DateTime(2026),
    );

void main() {
  late AppLocalizations texts;

  setUpAll(() async {
    texts = await AppLocalizations.delegate.load(const Locale('es'));
  });

  Future<void> pump(
    WidgetTester tester, {
    required List<TagLogEntryEntity> entries,
    bool isGuess = false,
  }) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: TagLogDialog(
          mediaId: 1,
          view: (entries: entries, isGuess: isGuess),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  group('lo que dice de cada línea', () {
    testWidgets('el nombre y el porqué', (tester) async {
      await pump(tester, entries: [_entry(TagLogReason.manual)]);

      expect(find.text('Rombo'), findsOneWidget);
      expect(find.text(texts.tagLogManual), findsOneWidget);
    });

    // «Heredada» a secas no sirve para nada: lo que hace falta saber es qué
    // etiqueta la arrastró, que es lo que hay que quitar para que no vuelva.
    testWidgets('y de quién viene lo heredado', (tester) async {
      await pump(tester, entries: [
        _entry(TagLogReason.ancestor, label: 'Figuras', detail: 'Rombo'),
      ]);

      expect(find.text(texts.tagLogAncestorOf('Rombo')), findsOneWidget);
    });

    testWidgets('con el fernie que la puso', (tester) async {
      await pump(tester, entries: [
        _entry(TagLogReason.fernie, detail: 'Marinette'),
      ]);

      expect(find.text(texts.tagLogFernieOf('Marinette')), findsOneWidget);
    });

    testWidgets('y lo que no consta se dice', (tester) async {
      await pump(tester, entries: [_entry(TagLogReason.unknown)]);

      expect(find.text(texts.tagLogUnknown), findsOneWidget);
    });

    // En una lista mezclada, el aviso de arriba no dice **cuáles** no constan.
    testWidgets('lo deducido va marcado línea a línea', (tester) async {
      await pump(
        tester,
        isGuess: true,
        entries: [
          TagLogEntryEntity(
            mediaId: 1,
            reason: TagLogReason.manual,
            label: 'Apuntada',
            at: DateTime(2026),
          ),
          TagLogEntryEntity(
            mediaId: 1,
            reason: TagLogReason.manual,
            label: 'Deducida',
            at: DateTime(2026),
            isGuess: true,
          ),
        ],
      );

      expect(find.text(texts.tagLogManual), findsOneWidget);
      expect(
        find.text('${texts.tagLogManual} · ${texts.tagLogGuessed}'),
        findsOneWidget,
      );
    });

    testWidgets('cada motivo tiene el suyo', (tester) async {
      await pump(tester, entries: [
        _entry(TagLogReason.manual, label: 'Una'),
        _entry(TagLogReason.sourceUrl, label: 'Dos'),
        _entry(TagLogReason.platform, label: 'Tres'),
        _entry(TagLogReason.recognition, label: 'Cuatro'),
      ]);

      expect(find.text(texts.tagLogManual), findsOneWidget);
      expect(find.text(texts.tagLogSourceUrl), findsOneWidget);
      expect(find.text(texts.tagLogPlatform), findsOneWidget);
      expect(find.text(texts.tagLogRecognition), findsOneWidget);
    });
  });

  // El avatar y no un icono por motivo: es cómo se reconoce una etiqueta en el
  // resto de la aplicación, y el porqué ya se lee debajo del nombre.
  group('lo que se pinta al lado', () {
    testWidgets('el avatar de la etiqueta', (tester) async {
      await pump(tester, entries: [_entry(TagLogReason.manual)]);

      expect(find.byType(FernAvatar), findsOneWidget);
    });

    // Lo único que aquí no se ve en el nombre es si la línea habla de una
    // etiqueta o de un creador, y de eso se encarga el icono de reserva.
    testWidgets('y sin imagen, el icono de su clase', (tester) async {
      await pump(tester, entries: [
        _entry(TagLogReason.manual, label: 'Rombo'),
        TagLogEntryEntity(
          mediaId: 1,
          reason: TagLogReason.manual,
          creatorId: 7,
          label: 'Pompeu',
          at: DateTime(2026),
        ),
      ]);

      expect(find.byIcon(Symbols.sell), findsOneWidget);
      expect(find.byIcon(Symbols.person), findsOneWidget);
    });
  });

  group('lo que consta y lo que se deduce', () {
    testWidgets('con registro, se cuenta lo que pasó', (tester) async {
      await pump(tester, entries: [_entry(TagLogReason.manual)]);

      expect(find.text(texts.tagLogNote), findsOneWidget);
      expect(find.text(texts.tagLogGuessNote), findsNothing);
    });

    // El aviso no es un detalle: sin él, lo deducido se lee como un registro.
    testWidgets('sin él, se avisa de que es deducido', (tester) async {
      await pump(
        tester,
        entries: [_entry(TagLogReason.unknown)],
        isGuess: true,
      );

      expect(find.text(texts.tagLogGuessNote), findsOneWidget);
      expect(find.text(texts.tagLogNote), findsNothing);
    });

    testWidgets('y sin nada puesto lo dice', (tester) async {
      await pump(tester, entries: const []);

      expect(find.text(texts.tagLogEmpty), findsOneWidget);
    });
  });

  // 600 px es lo más bajo que la ventana se deja poner, y un contenido con
  // veinte etiquetas es normal: el registro tiene que poder desplazarse.
  group('el alto', () {
    for (final height in [600.0, 400.0]) {
      testWidgets('no desborda a ${height.toInt()}px en ningún idioma',
          (tester) async {
        for (final locale in const [
          Locale('en'),
          Locale('es'),
          Locale('ca'),
          Locale('fr'),
        ]) {
          tester.view.physicalSize = Size(1000, height);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(const SizedBox.shrink());
          tester.takeException();

          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.lightTheme,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: TagLogDialog(
                mediaId: 1,
                view: (
                  entries: [
                    for (var each = 0; each < 20; each++)
                      _entry(
                        TagLogReason.ancestor,
                        label: 'Etiqueta con un nombre largo $each',
                        detail: 'Otra etiqueta con un nombre largo',
                      ),
                  ],
                  isGuess: true,
                ),
              ),
            ),
          ));
          await tester.pump(const Duration(milliseconds: 400));

          expect(
            tester.takeException(),
            isNull,
            reason: 'desborda a ${height.toInt()}px en ${locale.languageCode}',
          );
        }
      });
    }
  });
}
