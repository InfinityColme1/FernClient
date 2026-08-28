// El buscador que se vacía al elegir.
//
// Hay dos clases de buscador en la aplicación y se comportan al revés:
//
// - El que elige **una** cosa (el padre de una etiqueta, el enlace de un
//   fernie): lo escrito **es** el valor del campo, así que al elegir se queda
//   puesto. Vaciarlo sería deshacer lo que se acaba de elegir.
// - El que elige **varias seguidas** (las etiquetas de un contenido): lo elegido
//   ya se ve en otro sitio, y dejar el nombre escrito obliga a borrarlo a mano
//   antes de buscar la siguiente.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/inputs/fern_search_input.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final chosen = <String>[];
  final typed = <String>[];

  setUp(() {
    chosen.clear();
    typed.clear();
  });

  Future<void> pump(WidgetTester tester, {required bool clearOnSelected}) {
    return tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: FernSearchInput(
          label: 'etiqueta',
          suggestions: const ['marinette', 'miraculous'],
          clearOnSelected: clearOnSelected,
          onSelected: chosen.add,
          onChanged: typed.add,
        ),
      ),
    ));
  }

  /// Escribe algo y pulsa la sugerencia que aparece.
  Future<void> chooseSuggestion(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    await tester.pumpAndSettle();

    await tester.tap(find.text('marinette').last);
    await tester.pumpAndSettle();
  }

  String fieldText() =>
      (find.byType(TextField).evaluate().single.widget as TextField)
          .controller!
          .text;

  testWidgets('vaciándose, el campo queda listo para la siguiente búsqueda',
      (tester) async {
    await pump(tester, clearOnSelected: true);
    await chooseSuggestion(tester, 'mari');

    // Se ha avisado de lo elegido —el nombre entero, no lo tecleado— y el campo
    // se ha quedado vacío.
    expect(chosen, ['marinette']);
    expect(fieldText(), isEmpty);

    // Y quien escucha se entera de que ya no hay nada escrito: es lo que apaga
    // las sugerencias de la búsqueda anterior.
    expect(typed.last, isEmpty);
  });

  testWidgets('sin vaciarse, lo elegido se queda escrito', (tester) async {
    await pump(tester, clearOnSelected: false);
    await chooseSuggestion(tester, 'mari');

    expect(chosen, ['marinette']);
    expect(fieldText(), 'marinette');
  });
}
