// Plegar ramas del árbol de etiquetas.
//
// El menú lateral y la lista de gestión enseñaban **todas** las etiquetas,
// madres e hijas, siempre. Con un árbol de cierto tamaño eso es una lista
// larguísima, y estorba justo donde más se usa: arrastrar contenido hasta una
// etiqueta obliga a arrastrar y desplazar a la vez.
//
// Se guardan **las plegadas y no las desplegadas**, y ésa es la decisión que hay
// que sostener: el conjunto vacío significa «todo abierto», que es lo de antes.
// Con la lista al revés, una preferencia ausente escondería el árbol entero la
// primera vez que se instalara esta versión.

import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/services/collapsed_tags.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/presentation/widgets/tag_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

TagEntity _tag(int id, String name, {List<TagEntity> children = const []}) =>
    TagEntity(id: id, name: name, children: children);

/// miraculous ─┬─ marinette ─── ladybug
///             └─ adrien
/// parís
final _tree = [
  _tag(1, 'miraculous', children: [
    _tag(2, 'marinette', children: [_tag(3, 'ladybug')]),
    _tag(4, 'adrien'),
  ]),
  _tag(5, 'parís'),
];

List<String> _names(List<TagRow> rows) =>
    [for (final row in rows) row.tag.name];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesService preferences;
  late CollapsedTags collapsed;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = PreferencesService(await SharedPreferences.getInstance());
    collapsed = CollapsedTags(preferences: preferences);
  });

  group('el recorrido del árbol', () {
    // Es lo que pintaba antes de que esto existiera, y lo que tiene que seguir
    // pintando mientras nadie pliegue nada.
    test('sin nada plegado sale entero', () {
      expect(
        _names(TagList.flatten(_tree)),
        ['miraculous', 'marinette', 'ladybug', 'adrien', 'parís'],
      );
    });

    test('plegar una madre esconde sus hijas y sus nietas', () {
      expect(
        _names(TagList.flatten(_tree, collapsed: {1})),
        ['miraculous', 'parís'],
      );
    });

    // La madre no desaparece: es la fila desde la que se vuelve a abrir.
    test('la madre plegada se sigue viendo', () {
      expect(_names(TagList.flatten(_tree, collapsed: {2})), contains('marinette'));
    });

    test('plegar por en medio corta sólo de ahí para abajo', () {
      expect(
        _names(TagList.flatten(_tree, collapsed: {2})),
        ['miraculous', 'marinette', 'adrien', 'parís'],
      );
    });

    test('no toca a las demás ramas', () {
      expect(_names(TagList.flatten(_tree, collapsed: {1})), contains('parís'));
    });

    // Plegar una hoja no tiene nada que esconder, y no puede romper el
    // recorrido.
    test('plegar una sin hijas no cambia nada', () {
      expect(
        _names(TagList.flatten(_tree, collapsed: {3, 5})),
        _names(TagList.flatten(_tree)),
      );
    });

    test('la sangría se cuenta igual', () {
      final rows = TagList.flatten(_tree, collapsed: {2});

      expect(
        {for (final row in rows) row.tag.name: row.depth},
        {'miraculous': 0, 'marinette': 1, 'adrien': 1, 'parís': 0},
      );
    });
  });

  group('lo que se guarda', () {
    test('nada, mientras no se pliegue nada', () {
      expect(collapsed.ids, isEmpty);
      expect(preferences.collapsedTagIds(), isEmpty);
    });

    test('lo plegado sobrevive a reabrir', () async {
      await collapsed.collapse(1);

      final other = CollapsedTags(preferences: preferences);

      expect(other.isCollapsed(1), isTrue);
    });

    test('desplegar lo suelta', () async {
      await collapsed.collapse(1);
      await collapsed.expand(1);

      expect(CollapsedTags(preferences: preferences).ids, isEmpty);
    });

    test('el chevron alterna', () async {
      await collapsed.toggle(1);
      expect(collapsed.isCollapsed(1), isTrue);

      await collapsed.toggle(1);
      expect(collapsed.isCollapsed(1), isFalse);
    });

    test('avisa a quien lo mira', () async {
      var avisos = 0;
      collapsed.addListener(() => avisos++);

      await collapsed.collapse(1);
      await collapsed.expand(1);

      // Las dos listas que pintan el árbol lo escuchan: plegar desde una tiene
      // que verse en la otra sin salir y volver.
      expect(avisos, 2);
    });

    test('plegar dos veces lo mismo no avisa dos veces', () async {
      var avisos = 0;
      collapsed.addListener(() => avisos++);

      await collapsed.collapse(1);
      await collapsed.collapse(1);

      expect(avisos, 1);
    });
  });

  group('mientras se arrastra', () {
    test('posarse encima abre la rama', () {
      collapsed.collapse(1);

      collapsed.expandWhileDragging(1);

      expect(collapsed.isCollapsed(1), isFalse);
    });

    // Es una ayuda del gesto, no una decisión: guardarlo dejaría el árbol
    // abierto por haberlo cruzado con el ratón.
    test('lo que abre el arrastre no se guarda', () async {
      await collapsed.collapse(1);

      collapsed.expandWhileDragging(1);

      expect(preferences.collapsedTagIds(), {1});
    });

    test('y al soltar se vuelve a cerrar', () async {
      await collapsed.collapse(1);

      collapsed.expandWhileDragging(1);
      collapsed.releaseDragged();

      expect(collapsed.isCollapsed(1), isTrue);
    });

    // Lo que ya estaba abierto no se cierra al soltar: no lo abrió el arrastre.
    test('no cierra lo que ya estaba abierto', () {
      collapsed.expandWhileDragging(1);
      collapsed.releaseDragged();

      expect(collapsed.isCollapsed(1), isFalse);
    });
  });

  group('lo que no puede quedar escondido', () {
    // Crear una hija bajo una madre plegada, o mover una etiqueta a una rama
    // cerrada: sin abrir la rama, la fila marcada no está en pantalla y parece
    // que no se ha hecho nada.
    test('las madres de la elegida se saben cuáles son', () {
      expect(
        [for (final tag in TagList.ancestorsOf(_tree, 3)) tag.name],
        ['miraculous', 'marinette'],
      );
    });

    test('una raíz no tiene ninguna', () {
      expect(TagList.ancestorsOf(_tree, 5), isEmpty);
    });

    test('una que no está tampoco', () {
      expect(TagList.ancestorsOf(_tree, 99), isEmpty);
    });
  });

  // Vaciar la base se lleva las etiquetas, así que lo plegado apuntaría a
  // identificadores que ya no existen.
  test('vaciarlo lo suelta todo', () async {
    await collapsed.collapse(1);
    await collapsed.collapse(2);

    await collapsed.clear();

    expect(collapsed.ids, isEmpty);
    expect(CollapsedTags(preferences: preferences).ids, isEmpty);
  });
}
