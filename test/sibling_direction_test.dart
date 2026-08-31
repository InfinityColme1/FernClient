// Quién arrastra a quién entre dos etiquetas relacionadas.
//
// Ser hermanas dice **que van juntas**; la dirección dice qué pasa al poner
// una. Hasta ahora era siempre en los dos sentidos y no se podía elegir: para
// «un personaje y su serie» está bien —la serie va con el personaje— pero al
// revés no, porque poner la serie no debería poner a uno de sus personajes en
// concreto.
//
// Lo que se guarda son **las excepciones**, y ésa es la decisión que hay que
// sostener aquí: la lista vacía significa «arrastra a todas», así que todo lo
// que ya está en la base —que no tiene el campo— sigue comportándose
// exactamente como se venía comportando, sin migrar ni tocar una sola fila.

import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/services/sibling_direction.dart';
import 'package:flutter_test/flutter_test.dart';

TagEntity _tag(int id, String name, {List<int> muted = const []}) =>
    TagEntity(id: id, name: name, children: const [], mutedSiblings: muted);

/// La dirección entre «ladybug» (1) y «Marinette» (2), diciendo a quién silencia
/// cada una.
SiblingDirection between({
  List<int> ladybugMutes = const [],
  List<int> marinetteMutes = const [],
}) =>
    siblingDirectionBetween(
      tag: _tag(1, 'ladybug', muted: ladybugMutes),
      sibling: _tag(2, 'Marinette', muted: marinetteMutes),
    );

void main() {
  group('cómo se lee', () {
    // Lo que hay en la base hoy: ninguna silencia a nadie.
    test('sin nada silenciado, las dos se ponen', () {
      expect(between(), SiblingDirection.both);
    });

    test('silenciando la hermana, sólo la etiqueta la pone', () {
      expect(
        between(marinetteMutes: [1]),
        SiblingDirection.forward,
      );
    });

    test('silenciando la etiqueta, sólo la hermana la pone', () {
      expect(
        between(ladybugMutes: [2]),
        SiblingDirection.backward,
      );
    });

    test('silenciando las dos, ninguna pone a la otra', () {
      expect(
        between(ladybugMutes: [2], marinetteMutes: [1]),
        SiblingDirection.none,
      );
    });

    // Cada pareja va por su cuenta: silenciar a una tercera no dice nada de
    // ésta.
    test('lo que se silencie de otras no cuenta', () {
      expect(between(ladybugMutes: [9], marinetteMutes: [9]),
          SiblingDirection.both);
    });
  });

  group('qué arrastra cada dirección', () {
    test('en los dos sentidos, las dos', () {
      expect(pullsSibling(SiblingDirection.both), isTrue);
      expect(isPulledBySibling(SiblingDirection.both), isTrue);
    });

    test('de ida, sólo la etiqueta', () {
      expect(pullsSibling(SiblingDirection.forward), isTrue);
      expect(isPulledBySibling(SiblingDirection.forward), isFalse);
    });

    test('de vuelta, sólo la hermana', () {
      expect(pullsSibling(SiblingDirection.backward), isFalse);
      expect(isPulledBySibling(SiblingDirection.backward), isTrue);
    });

    // La relación se queda: sigue saliendo en el árbol y en la cuenta de la
    // ficha. Sirve para dejar escrito que dos etiquetas van juntas sin que eso
    // obligue a nada, que no es lo mismo que no relacionarlas.
    test('sin dirección, ninguna', () {
      expect(pullsSibling(SiblingDirection.none), isFalse);
      expect(isPulledBySibling(SiblingDirection.none), isFalse);
    });
  });

  group('qué se guarda', () {
    test('lo de fábrica no guarda nada', () {
      expect(mutedFor({2: SiblingDirection.both}), isEmpty);
    });

    test('de ida, la etiqueta no silencia a nadie', () {
      expect(mutedFor({2: SiblingDirection.forward}), isEmpty);
      expect(siblingMutes(SiblingDirection.forward), isTrue);
    });

    test('de vuelta, la etiqueta silencia a la hermana', () {
      expect(mutedFor({2: SiblingDirection.backward}), [2]);
      expect(siblingMutes(SiblingDirection.backward), isFalse);
    });

    test('sin dirección, las dos se silencian', () {
      expect(mutedFor({2: SiblingDirection.none}), [2]);
      expect(siblingMutes(SiblingDirection.none), isTrue);
    });

    test('con varias, sólo caen las que no arrastra', () {
      expect(
        mutedFor({
          2: SiblingDirection.both,
          3: SiblingDirection.backward,
          4: SiblingDirection.forward,
          5: SiblingDirection.none,
        }),
        unorderedEquals([3, 5]),
      );
    });

    // Se calcula la lista entera y no se va tocando entrada a entrada: así una
    // hermana que se quita del árbol no deja su silencio detrás esperando a que
    // alguien la vuelva a relacionar.
    test('sin hermanas no queda nada silenciado', () {
      expect(mutedFor(const {}), isEmpty);
    });
  });

  // La vuelta entera: se elige una dirección, se guarda, se vuelve a leer.
  group('ida y vuelta', () {
    for (final direction in SiblingDirection.values) {
      test('$direction sobrevive a guardarla', () {
        final ladybugMutes = mutedFor({2: direction});
        // La entrada que le toca a la hermana en **su** lista.
        final marinetteMutes =
            siblingMutes(direction) ? const <int>[1] : const <int>[];

        expect(
          between(
            ladybugMutes: ladybugMutes,
            marinetteMutes: marinetteMutes,
          ),
          direction,
        );
      });
    }
  });
}
