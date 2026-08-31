// El desplegable del campo de búsqueda con el campo vacío.
//
// Hasta ahora un campo vacío no tenía nada que enseñar, y `_refreshOverlay`
// cortaba en seco en cuanto no había texto. Los que ofrecen los últimos usados sí
// tienen algo antes de escribir, así que esa guarda hubo que relajarla — y eso es
// exactamente lo que hay que sostener aquí: **que sólo se relaje para ellos**.
//
// El resto de campos (el de la etiqueta madre, el del enlace de un fernie) filtran
// sus sugerencias por el texto escrito, y con el campo vacío un `contains('')`
// las dejaría pasar todas de golpe: pulsar el campo abriría una lista con las
// doscientas etiquetas de la aplicación.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/inputs/fern_search_input.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// El campo arriba del todo, con sitio debajo: el desplegable se pinta bajo él,
/// y con el campo centrado se salía de la pantalla y no había dónde pulsar.
Future<void> _pump(
  WidgetTester tester, {
  required List<String> suggestions,
  bool showsSuggestionsWhenEmpty = false,
  bool filterSuggestions = true,
  VoidCallback? onFocusedEmpty,
  ValueChanged<String>? onSelected,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 400,
          child: FernSearchInput(
            label: 'Buscar',
            suggestions: suggestions,
            filterSuggestions: filterSuggestions,
            showsSuggestionsWhenEmpty: showsSuggestionsWhenEmpty,
            onFocusedEmpty: onFocusedEmpty,
            onSelected: onSelected,
          ),
        ),
      ),
    ),
  ));
}

void main() {
  group('sin recientes que ofrecer', () {
    testWidgets('pulsar el campo vacío no abre nada', (tester) async {
      await _pump(tester, suggestions: ['uno', 'dos']);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.text('uno'), findsNothing);
      expect(find.text('dos'), findsNothing);
    });

    testWidgets('escribiendo sí', (tester) async {
      await _pump(tester, suggestions: ['uno', 'dos']);

      await tester.enterText(find.byType(TextField), 'un');
      await tester.pumpAndSettle();

      expect(find.text('uno'), findsOneWidget);
      expect(find.text('dos'), findsNothing);
    });
  });

  group('con recientes', () {
    testWidgets('pulsar el campo vacío los enseña', (tester) async {
      await _pump(
        tester,
        suggestions: ['reciente'],
        filterSuggestions: false,
        showsSuggestionsWhenEmpty: true,
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.text('reciente'), findsOneWidget);
    });

    // Es cuándo hay que ir a buscarlos: antes no hay nada que ofrecer.
    testWidgets('y se piden al recibir el foco', (tester) async {
      var asked = 0;

      await _pump(
        tester,
        suggestions: const [],
        filterSuggestions: false,
        showsSuggestionsWhenEmpty: true,
        onFocusedEmpty: () => asked++,
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(asked, 1);
    });

    testWidgets('sin ninguno, no se abre un desplegable vacío', (tester) async {
      await _pump(
        tester,
        suggestions: const [],
        filterSuggestions: false,
        showsSuggestionsWhenEmpty: true,
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNothing);
    });

    // Flotando en la capa de encima, el desplegable no es hijo del campo: sin
    // cerrarlo al pulsar fuera se quedaría puesto sobre la pantalla.
    testWidgets('pulsar fuera lo cierra', (tester) async {
      await _pump(
        tester,
        suggestions: ['reciente'],
        filterSuggestions: false,
        showsSuggestionsWhenEmpty: true,
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text('reciente'), findsOneWidget);

      await tester.tapAt(const Offset(600, 580));
      await tester.pumpAndSettle();

      expect(find.text('reciente'), findsNothing);
    });

    // El fallo que esto protege: pulsar una sugerencia le quita el foco al
    // campo, y cerrar el desplegable ahí lo quitaba de en medio entre el botón
    // abajo y el botón arriba. La pulsación acababa en el aire y elegir una
    // sugerencia no hacía absolutamente nada.
    testWidgets('pulsar una sugerencia la elige', (tester) async {
      final chosen = <String>[];

      await _pump(
        tester,
        suggestions: ['reciente'],
        filterSuggestions: false,
        showsSuggestionsWhenEmpty: true,
        onSelected: chosen.add,
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await tester.tap(find.text('reciente'));
      await tester.pumpAndSettle();

      expect(chosen, ['reciente']);
    });

    testWidgets('y escribiendo, también', (tester) async {
      final chosen = <String>[];

      await _pump(
        tester,
        suggestions: ['uno', 'dos'],
        onSelected: chosen.add,
      );

      await tester.enterText(find.byType(TextField), 'un');
      await tester.pumpAndSettle();

      await tester.tap(find.text('uno'));
      await tester.pumpAndSettle();

      expect(chosen, ['uno']);
    });
  });
}
