// El buscador de las etiquetas del menú lateral.
//
// Con un árbol de cierto tamaño, el menú es una lista larguísima justo donde más
// se usa: arrastrar contenido hasta una etiqueta obligaba a arrastrar y
// desplazar a la vez. Plegar ramas ayudó; buscar es la otra mitad.
//
// Lo que hay que sostener:
//
// - **Es el mismo aplanado que la pantalla de gestión.** Las dos listas enseñan
//   el mismo árbol; con dos filtros distintos, cualquier arreglo en uno dejaría
//   al otro comportándose de otra manera.
// - **Plegado no hay buscador.** La fila entera es un icono: no hay ancho para un
//   campo de texto, igual que no lo hay para los rótulos ni los chevrones.
// - **La sección no desaparece al no encontrar nada.** El campo es lo que
//   explica por qué está vacía, y quitarlo con el último resultado dejaría al
//   usuario sin forma de deshacer su propia búsqueda.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/widgets/collapsing_navigation_drawer_widget.dart';
import 'package:Fern/core/widgets/sidebar_item.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/presentation/widgets/tag_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

SidebarItem _item(String title) => SidebarItem(
      id: title,
      title: title,
      icon: Symbols.sell,
      onTap: () {},
    );

TagEntity _tag(int id, String name, {List<TagEntity> children = const []}) =>
    TagEntity(id: id, name: name, children: children);

/// Paisajes ── Montaña ── Nieve
/// Retratos
final _tree = [
  _tag(1, 'Paisajes', children: [
    _tag(2, 'Montaña', children: [_tag(3, 'Nieve')]),
  ]),
  _tag(4, 'Retratos'),
];

List<String> _names(List<TagRow> rows) => [for (final row in rows) row.tag.name];

Future<void> _pump(
  WidgetTester tester,
  List<SidebarSection> sections, {
  bool isCollapsed = false,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Row(
        children: [
          CollapsingNavigationDrawer(
            sections: sections,
            isCollapsed: isCollapsed,
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
  await tester.pumpAndSettle();
}

void main() {
  group('dónde sale el buscador', () {
    testWidgets('debajo del rótulo de su sección', (tester) async {
      await _pump(tester, [
        SidebarSection(title: 'Gallery', items: [_item('Media')]),
        SidebarSection(
          title: 'Tags',
          header: FernFilterField(hintText: 'Buscar...', onChanged: (_) {}),
          items: [_item('Paisajes')],
        ),
      ]);

      expect(find.byType(FernFilterField), findsOneWidget);
      expect(
        tester.getTopLeft(find.byType(FernFilterField)).dy,
        greaterThan(tester.getTopLeft(find.text('Tags')).dy),
      );
      expect(
        tester.getTopLeft(find.byType(FernFilterField)).dy,
        lessThan(tester.getTopLeft(find.text('Paisajes')).dy),
      );
    });

    // Plegado la fila entera es un icono: no hay ancho que darle a un campo de
    // texto, igual que no lo hay para los rótulos.
    testWidgets('y con el menú plegado no sale', (tester) async {
      await _pump(
        tester,
        [
          SidebarSection(
            title: 'Tags',
            header: FernFilterField(hintText: 'Buscar...', onChanged: (_) {}),
            items: [_item('Paisajes')],
          ),
        ],
        isCollapsed: true,
      );

      expect(find.byType(FernFilterField), findsNothing);
    });

    // Sin el campo, una búsqueda sin resultados se lleva por delante la sección
    // entera y con ella la única forma de deshacerla.
    testWidgets('sin resultados, el campo se queda', (tester) async {
      await _pump(tester, [
        SidebarSection(
          title: 'Tags',
          header: FernFilterField(hintText: 'Buscar...', onChanged: (_) {}),
          items: const [],
        ),
      ]);

      expect(find.byType(FernFilterField), findsOneWidget);
    });

    // El campo desaparece **en cuanto el menú empieza a estrecharse**, no al
    // final: un campo de texto en un menú de 70 px desbordaría a mitad de la
    // animación, que es justo donde nadie mira.
    testWidgets('plegar el menú no desborda por el camino', (tester) async {
      final sections = [
        SidebarSection(
          title: 'Tags',
          header: FernFilterField(hintText: 'Buscar...', onChanged: (_) {}),
          items: [_item('Paisajes')],
        ),
      ];

      await _pump(tester, sections);
      await _pump(tester, sections, isCollapsed: true);

      for (var frame = 0; frame < 10; frame++) {
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('una sección sin buscador sigue como estaba', (tester) async {
      await _pump(tester, [
        SidebarSection(title: 'Tags', items: const []),
      ]);

      expect(find.text('Tags'), findsNothing);
    });
  });

  // El aplanado que comparten el menú y la pantalla de gestión. Es lo que hace
  // que las dos listas se comporten igual, así que se mide aparte de las dos.
  group('lo que se ve al buscar', () {
    test('sin nada escrito, el árbol entero', () {
      expect(
        _names(TagList.rowsOf(_tree)),
        ['Paisajes', 'Montaña', 'Nieve', 'Retratos'],
      );
    });

    test('lo que encaja viene con su rama', () {
      expect(
        _names(TagList.rowsOf(_tree, query: 'monta')),
        ['Montaña', 'Nieve'],
      );
    });

    test('y arranca a ras, no con la sangría del árbol', () {
      final rows = TagList.rowsOf(_tree, query: 'monta');

      expect(rows.first.depth, 0);
      expect(rows.last.depth, 1);
    });

    test('sin distinguir mayúsculas', () {
      expect(_names(TagList.rowsOf(_tree, query: 'NIEVE')), ['Nieve']);
    });

    test('lo que no encaja nada no devuelve nada', () {
      expect(TagList.rowsOf(_tree, query: 'coche'), isEmpty);
    });

    // Buscando manda el filtro sobre lo plegado: encontrar una etiqueta y no
    // verla porque su madre está cerrada sería un buscador que miente.
    test('buscando manda sobre lo plegado', () {
      expect(
        _names(TagList.rowsOf(_tree, query: 'nieve', collapsed: {1, 2})),
        ['Nieve'],
      );
    });

    test('pero con el campo vacío vuelve a mandar lo plegado', () {
      expect(
        _names(TagList.rowsOf(_tree, collapsed: {2})),
        ['Paisajes', 'Montaña', 'Retratos'],
      );
    });

    // Una hija que también encaja saldría dos veces: una colgando de su madre y
    // otra por su cuenta.
    test('una coincidencia dentro de otra no se repite', () {
      final tree = [
        _tag(1, 'Rombo', children: [_tag(2, 'Rombo simple')]),
      ];

      expect(_names(TagList.rowsOf(tree, query: 'rombo')),
          ['Rombo', 'Rombo simple']);
    });

    test('con la rama apagada, lo que encaja sale suelto', () {
      expect(
        _names(TagList.rowsOf(_tree, query: 'monta', showsBranch: false)),
        ['Montaña'],
      );
    });
  });
}
