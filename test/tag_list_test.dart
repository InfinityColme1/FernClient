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

TagEntity _tag(int id, String name, {List<TagEntity> children = const []}) =>
    TagEntity(id: id, name: name, children: children);

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
}
