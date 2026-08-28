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
import 'package:Fern/features/settings/presentation/widgets/wipe_database_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
