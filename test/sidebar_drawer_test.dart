// Comprueba cómo pinta el menú lateral las secciones y la jerarquía de
// etiquetas.
//
// Monta el menú por su cuenta, sin la aplicación: los botones se le pasan ya
// hechos, así que no hacen falta ni la base de datos ni los blocs.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/widgets/collapsing_navigation_drawer_widget.dart';
import 'package:Fern/core/widgets/sidebar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

SidebarItem _item(String title, {int depth = 0}) => SidebarItem(
      id: title,
      title: title,
      icon: Symbols.sell,
      depth: depth,
      onTap: () {},
    );

Future<void> _pumpDrawer(
  WidgetTester tester,
  List<SidebarSection> sections,
) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Row(
        children: [
          CollapsingNavigationDrawer(
            sections: sections,
            textStyle: const TextStyle(fontSize: 14),
            iconSize: 24,
            backgroundColor: Colors.white,
            selectedColor: Colors.purple,
            textSelectedColor: Colors.black,
            unselectedColor: Colors.white,
            textUnselectedColor: Colors.grey,
          ),
        ],
      ),
    ),
  ));
}

/// Dónde empieza el título de un botón: es lo que se ve como sangría.
double _left(WidgetTester tester, String title) =>
    tester.getTopLeft(find.text(title)).dx;

void main() {
  testWidgets('cada sección lleva su rótulo y un separador en medio', (tester) async {
    await _pumpDrawer(tester, [
      SidebarSection(title: 'Gallery', items: [_item('Media')]),
      SidebarSection(title: 'Tags', items: [_item('Tag1')]),
    ]);

    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Tags'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('la sangría crece hasta el tercer nivel y ahí se queda', (tester) async {
    await _pumpDrawer(tester, [
      SidebarSection(title: 'Tags', items: [
        _item('Tag1'),
        _item('Subtag1', depth: 1),
        _item('Nieta', depth: 2),
        _item('Bisnieta', depth: 3),
      ]),
    ]);

    final root = _left(tester, 'Tag1');
    final child = _left(tester, 'Subtag1');
    final grandchild = _left(tester, 'Nieta');

    expect(child, root + sidebarDepthIndent);
    expect(grandchild, child + sidebarDepthIndent);

    // De ahí para abajo no se estrecha más el botón: la jerarquía se marca con
    // una flecha, que además desplaza el título dentro del propio botón.
    expect(find.byIcon(Symbols.subdirectory_arrow_right), findsOneWidget);
    expect(_left(tester, 'Bisnieta'), greaterThan(grandchild));
  });

  testWidgets('las etiquetas se pueden desplazar cuando no caben', (tester) async {
    await _pumpDrawer(tester, [
      SidebarSection(title: 'Gallery', items: [_item('Media')]),
      SidebarSection(
        title: 'Tags',
        items: [for (var i = 0; i < 60; i++) _item('Tag $i')],
      ),
    ]);

    expect(find.text('Tag 0'), findsOneWidget);
    expect(find.text('Tag 59'), findsNothing);

    await tester.scrollUntilVisible(find.text('Tag 59'), 200);

    expect(find.text('Tag 59'), findsOneWidget);
  });

  testWidgets('una sección sin botones enseña su mensaje', (tester) async {
    await _pumpDrawer(tester, [
      SidebarSection(title: 'Gallery', items: [_item('Media')]),
      const SidebarSection(
        title: 'Tags',
        items: [],
        emptyMessage: 'No tags yet',
      ),
    ]);

    expect(find.text('No tags yet'), findsOneWidget);
  });
}
