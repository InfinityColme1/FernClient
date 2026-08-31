// Los dos avisos antes de vaciar la base de datos.
//
// Lo que se sostiene aquí es lo único que puede salir mal de verdad: que el
// botón de borrar **no se pueda pulsar** mientras lo escrito no sea exactamente
// la frase. La comparación se comprueba aparte, como función pura; esto
// comprueba que el diálogo la usa para decidir, que es otra cosa.
//
// El borrado en sí no se dispara desde aquí a propósito: pulsar el botón
// encendido llamaría al caso de uso de verdad, y lo que hace ése ya está
// comprobado contra una base de datos real en `database_wipe_test.dart`.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/domain/services/database_wipe_options.dart';
import 'package:Fern/features/settings/presentation/widgets/wipe_database_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  late AppLocalizations texts;

  setUpAll(() async {
    texts = await AppLocalizations.delegate.load(const Locale('es'));
  });

  Future<void> pump(WidgetTester tester, Widget dialog) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: dialog),
    ));
    await tester.pumpAndSettle();
  }

  /// Abre el primer aviso y recoge lo que devuelve.
  Future<void> pumpChoice(
    WidgetTester tester,
    void Function(DatabaseWipeOptions options) onChosen, {
    bool canWipeNsfwOnly = false,
  }) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final options = await showDialog<DatabaseWipeOptions>(
                context: context,
                builder: (_) => WipeDatabaseWarningDialog(
                  canWipeNsfwOnly: canWipeNsfwOnly,
                ),
              );

              if (options != null) onChosen(options);
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  /// Si el botón de la acción se puede pulsar.
  bool canPress(WidgetTester tester) =>
      tester.widget<FernActionButton>(find.byType(FernActionButton)).onPressed !=
      null;

  group('el primer aviso', () {
    testWidgets('dice lo que se pierde y lo que se queda', (tester) async {
      await pump(tester, const WipeDatabaseWarningDialog());

      // Las dos cosas, y la segunda no es un detalle: es lo que distingue
      // empezar de cero de perderlo todo.
      expect(find.text(texts.databaseWipeLoses), findsOneWidget);
      expect(find.text(texts.databaseWipeKeeps), findsOneWidget);
    });

    testWidgets('no borra nada: sólo lleva al siguiente', (tester) async {
      await pump(tester, const WipeDatabaseWarningDialog());

      // Si este diálogo pudiera borrar, la frase no serviría de nada.
      expect(find.text(texts.databaseWipeContinue), findsOneWidget);
      expect(find.text(texts.databaseWipeAction), findsNothing);
    });
  });

  group('el segundo aviso', () {
    testWidgets('nace con el botón apagado', (tester) async {
      await pump(tester, const WipeDatabaseConfirmDialog());

      expect(canPress(tester), isFalse);
    });

    testWidgets('y sigue apagado con algo parecido', (tester) async {
      await pump(tester, const WipeDatabaseConfirmDialog());

      await tester.enterText(find.byType(TextField), 'eliminar base de datos');
      await tester.pump();

      expect(canPress(tester), isFalse);
    });

    testWidgets('se enciende con la frase entera', (tester) async {
      await pump(tester, const WipeDatabaseConfirmDialog());

      await tester.enterText(find.byType(TextField), texts.databaseWipePhrase);
      await tester.pump();

      expect(canPress(tester), isTrue);
    });

    testWidgets('y se vuelve a apagar si se corrige', (tester) async {
      await pump(tester, const WipeDatabaseConfirmDialog());

      await tester.enterText(find.byType(TextField), texts.databaseWipePhrase);
      await tester.pump();

      // Un carácter de menos y ya no vale: el botón no se queda encendido por
      // haberlo estado.
      await tester.enterText(
        find.byType(TextField),
        texts.databaseWipePhrase.substring(0, texts.databaseWipePhrase.length - 1),
      );
      await tester.pump();

      expect(canPress(tester), isFalse);
    });

    testWidgets('la frase que hay que escribir está a la vista',
        (tester) async {
      await pump(tester, const WipeDatabaseConfirmDialog());

      // Hay que poder copiarla carácter a carácter: se compara exactamente.
      expect(find.text(texts.databaseWipePhrase), findsOneWidget);
    });
  });

  // Lo que se elige antes de la frase: cuanto se borra y si los ficheros se van
  // tambien. Las dos decisiones cambian lo que esto significa, asi que van donde
  // se explica que hace y no al lado del boton de confirmar.
  group('lo que se elige', () {
    testWidgets('de fabrica, todo y sin tocar los ficheros', (tester) async {
      DatabaseWipeOptions? chosen;

      await pumpChoice(tester, (options) => chosen = options);

      await tester.ensureVisible(find.text(texts.databaseWipeContinue));
      await tester.pumpAndSettle();
      await tester.tap(find.text(texts.databaseWipeContinue));
      await tester.pumpAndSettle();

      expect(chosen, const DatabaseWipeOptions());
    });

    // Con el bloqueo cerrado ese contenido no se ve: elegirlo seria borrar a
    // ciegas algo que no hay forma de comprobar.
    testWidgets('sin el bloqueo abierto no se ofrece lo no apto',
        (tester) async {
      await pumpChoice(tester, (_) {});

      expect(find.text(texts.databaseWipeScopeNsfw), findsNothing);
    });

    testWidgets('y con el bloqueo abierto si', (tester) async {
      await pumpChoice(tester, (_) {}, canWipeNsfwOnly: true);

      expect(find.text(texts.databaseWipeScopeNsfw), findsOneWidget);
    });

    testWidgets('elegir solo lo no apto se devuelve', (tester) async {
      DatabaseWipeOptions? chosen;

      await pumpChoice(
        tester,
        (options) => chosen = options,
        canWipeNsfwOnly: true,
      );

      // En una ventana de prueba de 600 px estos mandos quedan por debajo del
      // borde: el contenido del diálogo se desplaza, así que hay que traerlos.
      await tester.ensureVisible(find.text(texts.databaseWipeScopeNsfw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(texts.databaseWipeScopeNsfw));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(texts.databaseWipeContinue));
      await tester.pumpAndSettle();
      await tester.tap(find.text(texts.databaseWipeContinue));
      await tester.pumpAndSettle();

      expect(chosen?.scope, DatabaseWipeScope.nsfwOnly);
    });

    testWidgets('y marcar los ficheros tambien', (tester) async {
      DatabaseWipeOptions? chosen;

      await pumpChoice(tester, (options) => chosen = options);

      await tester.ensureVisible(find.text(texts.databaseWipeFiles));
      await tester.pumpAndSettle();
      await tester.tap(find.text(texts.databaseWipeFiles));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(texts.databaseWipeContinue));
      await tester.pumpAndSettle();
      await tester.tap(find.text(texts.databaseWipeContinue));
      await tester.pumpAndSettle();

      expect(chosen?.deletesFiles, isTrue);
    });

    // Cerrarlo no es elegir nada.
    testWidgets('cerrarlo no devuelve opciones', (tester) async {
      var answered = false;

      await pumpChoice(tester, (_) => answered = true);

      await tester.tap(find.byIcon(Symbols.close));
      await tester.pumpAndSettle();

      expect(answered, isFalse);
    });
  });

  // La ultima pantalla antes de que no haya vuelta. Llegar a ella con una
  // casilla marcada dos pantallas atras y sin recordarlo es como se borran cosas
  // sin querer.
  group('el segundo aviso dice lo que se eligio', () {
    testWidgets('que los ficheros se van del disco', (tester) async {
      await pump(
        tester,
        const WipeDatabaseConfirmDialog(
          options: DatabaseWipeOptions(deletesFiles: true),
        ),
      );

      expect(find.text(texts.databaseWipeConfirmFiles), findsOneWidget);
    });

    testWidgets('y que solo se va lo no apto', (tester) async {
      await pump(
        tester,
        const WipeDatabaseConfirmDialog(
          options: DatabaseWipeOptions(scope: DatabaseWipeScope.nsfwOnly),
        ),
      );

      expect(find.text(texts.databaseWipeConfirmNsfw), findsOneWidget);
    });

    // Sin haber elegido nada raro no se dice nada de mas: un aviso que sale
    // siempre deja de leerse.
    testWidgets('sin elegir nada, no dice nada de mas', (tester) async {
      await pump(tester, const WipeDatabaseConfirmDialog());

      expect(find.text(texts.databaseWipeConfirmFiles), findsNothing);
      expect(find.text(texts.databaseWipeConfirmNsfw), findsNothing);
    });
  });

  // 600 px es lo mas bajo que la ventana se deja poner, y el primer aviso ha
  // ganado dos mandos: con el bloqueo abierto lleva la explicacion, los dos
  // alcances y la casilla de los ficheros.
  group('el alto', () {
    for (final height in [600.0, 400.0]) {
      testWidgets('no desborda a ${height.toInt()}px en ningun idioma',
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

          // El arbol se tira abajo antes de cada medida: reaprovechando los
          // render objects, el aviso solo se da la primera vez.
          await tester.pumpWidget(const SizedBox.shrink());
          tester.takeException();

          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.lightTheme,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: WipeDatabaseWarningDialog(canWipeNsfwOnly: true),
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

    testWidgets('ni el segundo con todo dicho', (tester) async {
      for (final locale in const [
        Locale('en'),
        Locale('es'),
        Locale('ca'),
        Locale('fr'),
      ]) {
        tester.view.physicalSize = const Size(1000, 400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(const SizedBox.shrink());
        tester.takeException();

        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: WipeDatabaseConfirmDialog(
              options: DatabaseWipeOptions(
                scope: DatabaseWipeScope.nsfwOnly,
                deletesFiles: true,
              ),
            ),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 400));

        expect(tester.takeException(), isNull, reason: locale.languageCode);
      }
    });
  });
}
