// La lista de etiquetas de la pantalla de gestión.
//
// Dos cosas que no se ven leyendo el widget y que rompen datos si fallan:
//
// - **De quién cuelga cada una.** «Poner al lado de» significa colgar de la
//   misma madre, así que si el recorrido del árbol se equivoca, la etiqueta
//   acaba en otra rama.
// - **Qué no se puede soltar.** Una etiqueta no puede colgar de una de sus
//   propias hijas: la rama entera se perdería de vista.
//
// Y el filtro, que es lo que hace manejable una lista de doscientas.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/presentation/widgets/tag_list.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TagEntity _tag(
  int id,
  String name, {
  List<TagEntity> children = const [],
  bool isPerson = false,
}) =>
    TagEntity(
      id: id,
      name: name,
      children: children,
      isPerson: isPerson,
    );

/// Un árbol de tres niveles:
///
///   Paisajes ── Montaña ── Nieve
///   Retratos
final _tree = [
  _tag(1, 'Paisajes', children: [
    _tag(2, 'Montaña', children: [_tag(3, 'Nieve')]),
  ]),
  _tag(4, 'Retratos'),
];

/// Lo que se ha soltado sobre qué y qué se ha elegido.
typedef Dropped = ({TagEntity dragged, TagEntity target, TagDropMode mode});

Future<void> _pump(
  WidgetTester tester, {
  List<TagEntity>? tags,
  List<Dropped>? drops,
  // Explícito y no por el ajuste: sin localizador de servicios el widget se
  // quedaría con el valor de fábrica, y entonces cada prueba diría que comprueba
  // una cosa mientras comprueba la otra.
  bool showsBranchOnFilter = false,
  bool showsPeople = false,
  VoidCallback? onSwitchList,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    // En español a propósito: lo que se comprueba abajo son los rótulos del
    // menú, y sin decir idioma la aplicación de pruebas sale en inglés.
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SizedBox(
        width: 300,
        height: 600,
        child: TagList(
          tags: tags ?? _tree,
          showsBranchOnFilter: showsBranchOnFilter,
          showsPeople: showsPeople,
          onSwitchList: onSwitchList,
          onSelected: (_) {},
          onDropped: (dragged, target, mode) => drops
              ?.add((dragged: dragged, target: target, mode: mode)),
        ),
      ),
    ),
  ));
}

void main() {
  group('de quién cuelga', () {
    test('una raíz no cuelga de nadie', () {
      expect(TagList.parentOf(_tree, 1), isNull);
      expect(TagList.parentOf(_tree, 4), isNull);
    });

    test('una hija cuelga de la suya', () {
      expect(TagList.parentOf(_tree, 2)?.name, 'Paisajes');
    });

    test('una nieta cuelga de la de en medio, no de la raíz', () {
      expect(TagList.parentOf(_tree, 3)?.name, 'Montaña');
    });

    test('la que no está no cuelga de nada', () {
      expect(TagList.parentOf(_tree, 99), isNull);
    });
  });

  group('qué lleva dentro', () {
    test('una hija, sí', () {
      expect(TagList.contains(_tree.first, 2), isTrue);
    });

    test('una nieta también: a cualquier profundidad', () {
      expect(TagList.contains(_tree.first, 3), isTrue);
    });

    test('ella misma no cuenta como suya', () {
      // Soltar una sobre sí misma se descarta aparte; esto responde sólo por lo
      // que cuelga de ella.
      expect(TagList.contains(_tree.first, 1), isFalse);
    });

    test('una de otra rama, no', () {
      expect(TagList.contains(_tree.first, 4), isFalse);
    });
  });

  group('al soltar una sobre otra', () {
    /// Arrastra [from] encima de [to] y suelta.
    Future<void> dragOnto(WidgetTester tester, String from, String to) async {
      final origen = tester.getCenter(find.text(from));
      final destino = tester.getCenter(find.text(to));

      final pointer = await tester.startGesture(origen);
      await tester.pump(const Duration(milliseconds: 200));

      // Por pasos y no de un salto: los reconocedores de arrastre miran cómo se
      // mueve el puntero, y con un solo salto no llegan a engancharse.
      for (var step = 1; step <= 8; step++) {
        await pointer.moveTo(Offset.lerp(origen, destino, step / 8)!);
        await tester.pump(const Duration(milliseconds: 16));
      }

      await pointer.up();
      await tester.pumpAndSettle();
    }

    testWidgets('se ofrecen las dos cosas que se pueden hacer', (tester) async {
      await _pump(tester, drops: []);
      await dragOnto(tester, 'Retratos', 'Paisajes');

      expect(find.textContaining('Paisajes'), findsWidgets);
      expect(find.textContaining('Colgar de'), findsOneWidget);
      expect(find.textContaining('Relacionar con'), findsOneWidget);
    });

    testWidgets('colgar dice colgar', (tester) async {
      final drops = <Dropped>[];
      await _pump(tester, drops: drops);

      await dragOnto(tester, 'Retratos', 'Paisajes');
      await tester.tap(find.textContaining('Colgar de'));
      await tester.pumpAndSettle();

      expect(drops, hasLength(1));
      expect(drops.single.dragged.name, 'Retratos');
      expect(drops.single.target.name, 'Paisajes');
      expect(drops.single.mode, TagDropMode.child);
    });

    testWidgets('relacionar dice relacionar, no colgar', (tester) async {
      // Relacionar no toca el árbol: las dos se quedan donde estaban. Confundir
      // las dos opciones movería etiquetas de rama sin que nadie lo pidiera.
      final drops = <Dropped>[];
      await _pump(tester, drops: drops);

      await dragOnto(tester, 'Retratos', 'Paisajes');
      await tester.tap(find.textContaining('Relacionar con'));
      await tester.pumpAndSettle();

      expect(drops.single.mode, TagDropMode.related);
    });

    testWidgets('sobre sí misma no se ofrece nada', (tester) async {
      final drops = <Dropped>[];
      await _pump(tester, drops: drops);

      await dragOnto(tester, 'Retratos', 'Retratos');

      expect(find.textContaining('Colgar de'), findsNothing);
      expect(drops, isEmpty);
    });

    testWidgets('sobre una hija suya tampoco', (tester) async {
      // Colgar una etiqueta de una de sus propias hijas dejaría la rama entera
      // fuera del árbol.
      final drops = <Dropped>[];
      await _pump(tester, drops: drops);

      await dragOnto(tester, 'Paisajes', 'Nieve');

      expect(find.textContaining('Colgar de'), findsNothing);
      expect(drops, isEmpty);
    });
  });

  group('el filtro', () {
    testWidgets('sin escribir nada salen todas', (tester) async {
      await _pump(tester);

      for (final name in ['Paisajes', 'Montaña', 'Nieve', 'Retratos']) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
    });

    testWidgets('escribiendo se queda lo que encaja', (tester) async {
      await _pump(tester);

      await tester.enterText(find.byType(TextField), 'nie');
      await tester.pumpAndSettle();

      expect(find.text('Nieve'), findsOneWidget);
      expect(find.text('Paisajes'), findsNothing);
      expect(find.text('Retratos'), findsNothing);
    });

    testWidgets('no distingue mayúsculas y busca por cualquier parte',
        (tester) async {
      // Con doscientas etiquetas, acordarse de cómo empieza una es justo lo que
      // no pasa.
      await _pump(tester);

      await tester.enterText(find.byType(TextField), 'TAÑ');
      await tester.pumpAndSettle();

      expect(find.text('Montaña'), findsOneWidget);
    });

    testWidgets('borrar lo escrito devuelve la lista entera', (tester) async {
      await _pump(tester);

      await tester.enterText(find.byType(TextField), 'nie');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      expect(find.text('Paisajes'), findsOneWidget);
    });
  });

  // Con el ajuste puesto, lo que encaja llega con lo que cuelga de ello. El
  // motivo por el que antes se aplanaba —sangrar filas cuyas madres no se ven
  // dibuja un árbol que no existe— desaparece: la madre de cada fila sangrada
  // es la coincidencia de la que cuelga.
  group('el filtro con la rama', () {
    testWidgets('la madre trae a las hijas y a las nietas', (tester) async {
      await _pump(tester, showsBranchOnFilter: true);

      await tester.enterText(find.byType(TextField), 'paisa');
      await tester.pumpAndSettle();

      expect(find.text('Paisajes'), findsOneWidget);
      expect(find.text('Montaña'), findsOneWidget);
      expect(find.text('Nieve'), findsOneWidget);
      expect(find.text('Retratos'), findsNothing);
    });

    testWidgets('sin él, sólo lo que encaja', (tester) async {
      await _pump(tester);

      await tester.enterText(find.byType(TextField), 'paisa');
      await tester.pumpAndSettle();

      expect(find.text('Paisajes'), findsOneWidget);
      expect(find.text('Montaña'), findsNothing);
    });

    // Si encajan madre e hija, la hija saldría dos veces: una colgando de su
    // madre y otra por su cuenta. Como las madres van antes en el recorrido, la
    // primera vez sale en su sitio.
    testWidgets('una hija que también encaja no sale dos veces',
        (tester) async {
      await _pump(
        tester,
        showsBranchOnFilter: true,
        tags: [
          _tag(1, 'Nieve', children: [_tag(2, 'Nieve polvo')]),
        ],
      );

      await tester.enterText(find.byType(TextField), 'nieve');
      await tester.pumpAndSettle();

      expect(find.text('Nieve'), findsOneWidget);
      expect(find.text('Nieve polvo'), findsOneWidget);
    });

    testWidgets('la rama sale sangrada respecto a lo que encaja',
        (tester) async {
      await _pump(tester, showsBranchOnFilter: true);

      await tester.enterText(find.byType(TextField), 'monta');
      await tester.pumpAndSettle();

      // «Montaña» está a un nivel del árbol, pero al ser la coincidencia arranca
      // en la raíz: la sangría se cuenta desde ella y no desde el árbol entero.
      final match = tester.getTopLeft(find.text('Montaña'));
      final child = tester.getTopLeft(find.text('Nieve'));

      expect(child.dx, greaterThan(match.dx));
    });
  });

  // Las personas y las demás etiquetas comparten árbol y se listan aparte. Lo
  // que no puede pasar es que una se pierda por estar en la rama de la otra
  // clase.
  group('el reparto entre etiquetas y personas', () {
    final mixed = [
      _tag(1, 'Miraculous', children: [
        _tag(2, 'Marinette', isPerson: true, children: [
          _tag(3, 'Trajes'),
        ]),
      ]),
      _tag(4, 'Retratos'),
    ];

    testWidgets('la lista de etiquetas no enseña a las personas',
        (tester) async {
      await _pump(tester, tags: mixed);

      expect(find.text('Miraculous'), findsOneWidget);
      expect(find.text('Retratos'), findsOneWidget);
      expect(find.text('Marinette'), findsNothing);
    });

    // Una etiqueta normal colgada de una persona no se pierde: sube al sitio que
    // deja la persona.
    testWidgets('lo que cuelga de una persona sigue en la de etiquetas',
        (tester) async {
      await _pump(tester, tags: mixed);

      expect(find.text('Trajes'), findsOneWidget);
    });

    testWidgets('la lista de personas sólo enseña a las personas',
        (tester) async {
      await _pump(tester, tags: mixed, showsPeople: true);

      expect(find.text('Marinette'), findsOneWidget);
      expect(find.text('Miraculous'), findsNothing);
      expect(find.text('Trajes'), findsNothing);
    });

    test('una persona bajo una etiqueta normal queda en la raíz', () {
      final people = TagList.ofKind(mixed, people: true);

      expect(people.map((tag) => tag.name), ['Marinette']);
      expect(people.single.children, isEmpty);
    });

    test('y al revés: la normal bajo la persona también', () {
      final tags = TagList.ofKind(mixed, people: false);
      final rows = TagList.flatten(tags);

      expect(
        rows.map((row) => (row.tag.name, row.depth)),
        [('Miraculous', 0), ('Trajes', 1), ('Retratos', 0)],
      );
    });

    testWidgets('el botón de la cabecera lleva a la otra lista', (tester) async {
      var switched = 0;

      await _pump(tester, tags: mixed, onSwitchList: () => switched++);

      await tester.tap(find.byTooltip('Ir a las personas'));
      await tester.pump();

      expect(switched, 1);
    });

    testWidgets('sin a dónde ir, no hay botón', (tester) async {
      await _pump(tester, tags: mixed);

      expect(find.byTooltip('Ir a las personas'), findsNothing);
    });
  });
}
