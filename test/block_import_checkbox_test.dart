// La casilla de «que no se vuelva a importar», en el aviso de descarte.
//
// Son **dos decisiones independientes**: no volver a querer algo y querer su
// fichero fuera del disco no son lo mismo, y atarlas obligaría a tomar una para
// tomar la otra.
//
// Lo que más importa aquí es lo que no cambia: descartar sin marcarla tiene que
// comportarse exactamente como antes de que esto existiera.
//
// La tipografía de la aplicación se carga a mano, como en las demás pruebas que
// tocan un diálogo: sin ella se mide con la de pruebas, en la que cada letra es
// un cuadrado, y las explicaciones ocupan mucho más de lo que se ven.

import 'dart:io';

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media_deletion_kind.dart';
import 'package:Fern/features/media/presentation/widgets/confirm_delete_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadAppFont() async {
  final loader = FontLoader('Google Sans Flex');
  for (final weight in ['Light', 'Medium', 'Regular', 'SemiBold']) {
    loader.addFont(File('assets/fonts/GoogleSansFlex_24pt-$weight.ttf')
        .readAsBytes()
        .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer)));
  }
  await loader.load();
}

Future<AppLocalizations> _texts() =>
    AppLocalizations.delegate.load(const Locale('es'));

/// Abre el aviso de verdad, con su ruta detrás: se cierra pulsando su botón y
/// devuelve lo decidido, que es justo lo que hay que medir.
Future<DeleteDecision?> _open(
  WidgetTester tester, {
  required MediaDeletionKind kind,
  bool canBlockImport = false,
}) async {
  DeleteDecision? decision;
  var closed = false;

  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              decision = await showDialog<DeleteDecision>(
                context: context,
                builder: (_) => ConfirmDeleteDialog(
                  kind: kind,
                  count: 1,
                  canBlockImport: canBlockImport,
                ),
              );
              closed = true;
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  ));

  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();

  return closed ? decision : null;
}

/// Confirma y espera a que el aviso se cierre del todo.
Future<void> _confirm(WidgetTester tester) async {
  final texts = await _texts();

  await tester.tap(find.widgetWithText(FernPillButton, texts.actionDelete));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesService preferences;

  setUpAll(_loadAppFont);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = PreferencesService(await SharedPreferences.getInstance());

    if (getIt.isRegistered<PreferencesService>()) {
      await getIt.unregister<PreferencesService>();
    }
    getIt.registerSingleton<PreferencesService>(preferences);
  });

  group('cuándo se ofrece', () {
    // Es la fuente la que guarda lo marcado y lo vuelve a ofrecer en cada
    // importación. Un contenido local no tiene dirección que bloquear, así que
    // la casilla no sale en vez de salir apagada sin explicar por qué.
    testWidgets('no sale en contenido local', (tester) async {
      final texts = await _texts();

      await _open(tester, kind: MediaDeletionKind.discard);

      expect(find.text(texts.blockImportAgain), findsNothing);
      expect(find.text(texts.deleteFilesFromDisk), findsOneWidget);
    });

    testWidgets('sí en lo que ha venido de una fuente', (tester) async {
      final texts = await _texts();

      await _open(
        tester,
        kind: MediaDeletionKind.discard,
        canBlockImport: true,
      );

      expect(find.text(texts.blockImportAgain), findsOneWidget);
    });
  });

  group('lo que se decide', () {
    testWidgets('descartar sin marcarla no bloquea nada', (tester) async {
      await _open(
        tester,
        kind: MediaDeletionKind.discard,
        canBlockImport: true,
      );
      await _confirm(tester);

      // El comportamiento de siempre, intacto.
      expect(preferences.getBlocksImportOnDiscard(), isFalse);
    });

    testWidgets('marcándola, sí', (tester) async {
      final texts = await _texts();

      await _open(
        tester,
        kind: MediaDeletionKind.discard,
        canBlockImport: true,
      );

      await tester.tap(find.text(texts.blockImportAgain));
      await tester.pumpAndSettle();
      await _confirm(tester);

      expect(preferences.getBlocksImportOnDiscard(), isTrue);
    });

    // Independientes: se puede bloquear conservando el fichero.
    testWidgets('bloquear no arrastra el borrado del fichero', (tester) async {
      final texts = await _texts();

      await _open(
        tester,
        kind: MediaDeletionKind.discard,
        canBlockImport: true,
      );

      await tester.tap(find.text(texts.blockImportAgain));
      await tester.pumpAndSettle();
      await _confirm(tester);

      expect(preferences.getDeleteFiles(MediaDeletionKind.discard), isFalse);
    });

    // Y al revés.
    testWidgets('borrar el fichero no arrastra el bloqueo', (tester) async {
      final texts = await _texts();

      await _open(
        tester,
        kind: MediaDeletionKind.discard,
        canBlockImport: true,
      );

      await tester.tap(find.text(texts.deleteFilesFromDisk));
      await tester.pumpAndSettle();
      await _confirm(tester);

      expect(preferences.getDeleteFiles(MediaDeletionKind.discard), isTrue);
      expect(preferences.getBlocksImportOnDiscard(), isFalse);
    });
  });

  group('lo que se recuerda', () {
    testWidgets('arranca como quedó la última vez', (tester) async {
      final texts = await _texts();

      await preferences.setBlocksImportOnDiscard(true);

      await _open(
        tester,
        kind: MediaDeletionKind.discard,
        canBlockImport: true,
      );

      expect(
        tester
            .widget<FernCheckboxTile>(
              find.widgetWithText(FernCheckboxTile, texts.blockImportAgain),
            )
            .value,
        isTrue,
      );
    });

    // Lo que no se ha llegado a hacer no dice nada de lo que se quiere hacer la
    // próxima vez.
    testWidgets('cancelar no lo recuerda', (tester) async {
      final texts = await _texts();

      await _open(
        tester,
        kind: MediaDeletionKind.discard,
        canBlockImport: true,
      );

      await tester.tap(find.text(texts.blockImportAgain));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(preferences.getBlocksImportOnDiscard(), isFalse);
    });
  });

  // La casilla nueva son una línea más y una explicación más, y el diálogo le da
  // a su contenido la altura que sobra: en una ventana baja es donde se nota.
  // 600 px es lo más bajo que la ventana se deja poner (`kMinimumWindowHeight`),
  // y 400 el caso extremo en el que ya no cabe nada y todo tiene que poder
  // desplazarse.
  group('el alto', () {
    for (final height in [600.0, 400.0]) {
      testWidgets('no desborda a ${height.toInt()}px en ningún idioma',
          (tester) async {
        // Los cuatro juntos: el que desborda es siempre el texto más largo, y no
        // es el mismo idioma en cada aviso.
        for (final locale in const [
          Locale('en'),
          Locale('es'),
          Locale('ca'),
          Locale('fr'),
        ]) {
          tester.view.physicalSize = Size(1000, height);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          // El árbol se tira abajo antes de cada medida: reaprovechando los
          // render objects, el aviso sólo se da la primera vez.
          await tester.pumpWidget(const SizedBox.shrink());
          tester.takeException();

          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.lightTheme,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: ConfirmDeleteDialog(
                kind: MediaDeletionKind.discard,
                count: 1,
                canBlockImport: true,
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

    // Lo que sube y baja es el aviso, no el diálogo entero: el botón de borrar
    // se queda fijo abajo.
    testWidgets('lo que no cabe se alcanza desplazándose', (tester) async {
      await _open(
        tester,
        kind: MediaDeletionKind.discard,
        canBlockImport: true,
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  // Vaciar la papelera es otra cosa: ahí el contenido ya se dio por bueno y la
  // fuente hace tiempo que dejó de ofrecerlo.
  testWidgets('vaciar la papelera no ofrece bloquear', (tester) async {
    final texts = await _texts();

    await _open(tester, kind: MediaDeletionKind.trash);

    expect(find.text(texts.blockImportAgain), findsNothing);
  });
}
