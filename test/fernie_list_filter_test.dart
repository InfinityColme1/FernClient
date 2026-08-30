// El filtro de la lista de fernies.
//
// Es el mismo que ya tienen las listas de etiquetas y de creadores, y existe por
// lo mismo: con cincuenta fernies, ir buscando uno a ojo por la lista es lo que
// se acaba haciendo. Lo que se comprueba es que se comporta igual que los otros
// dos —sin distinguir mayúsculas y por cualquier parte del nombre— y que quedarse
// sin resultados no rompe nada.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/presentation/widgets/fernie_list.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

FernieEntity _fernie(int id, String name) =>
    FernieEntity(id: id, name: name, createdAt: DateTime(2024));

final _fernies = [
  _fernie(1, 'Marinette'),
  _fernie(2, 'Adrien'),
  _fernie(3, 'Tikki'),
];

Future<void> _pump(WidgetTester tester, {List<FernieEntity>? fernies}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    // En español a propósito: sin decir idioma la aplicación de pruebas sale en
    // inglés y el rótulo de la cabecera no ser­ía el que se lee.
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SizedBox(
        width: 300,
        height: 600,
        child: FernieList(
          fernies: fernies ?? _fernies,
          onSelected: (_) {},
        ),
      ),
    ),
  ));
}

void main() {
  testWidgets('sin escribir nada salen todos', (tester) async {
    await _pump(tester);

    for (final name in ['Marinette', 'Adrien', 'Tikki']) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
  });

  testWidgets('escribiendo se queda lo que encaja', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'adri');
    await tester.pumpAndSettle();

    expect(find.text('Adrien'), findsOneWidget);
    expect(find.text('Marinette'), findsNothing);
    expect(find.text('Tikki'), findsNothing);
  });

  testWidgets('no distingue mayúsculas y busca por cualquier parte',
      (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'NETT');
    await tester.pumpAndSettle();

    expect(find.text('Marinette'), findsOneWidget);
  });

  testWidgets('sin coincidencias la lista se queda vacía y no falla',
      (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'no existe');
    await tester.pumpAndSettle();

    expect(find.text('Marinette'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('borrar lo escrito devuelve la lista entera', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'adri');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    expect(find.text('Marinette'), findsOneWidget);
  });

  // El fernie elegido puede quedarse fuera del filtro: la ficha de al lado es de
  // la pantalla, no de la lista, así que filtrar no puede dejarla vacía.
  testWidgets('filtrar no cambia lo elegido', (tester) async {
    FernieEntity? selected;

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 300,
          height: 600,
          child: FernieList(
            fernies: _fernies,
            selectedFernieId: 1,
            onSelected: (fernie) => selected = fernie,
          ),
        ),
      ),
    ));

    await tester.enterText(find.byType(TextField), 'tikki');
    await tester.pumpAndSettle();

    expect(selected, isNull);
  });
}
