// Dónde cae cada etiqueta en el árbol de relaciones.
//
// Es la parte del diálogo que se puede equivocar sin que se note al mirarlo: una
// hermana en la fila de abajo parece una hija, y con todas a un lado la etiqueta
// que se está editando deja de estar en el centro, que es donde se la busca.

import 'package:Fern/features/media/domain/services/tag_relations_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TagRelationSlot slotOf(List<TagRelationSlot> slots, int tagId) =>
      slots.firstWhere((slot) => slot.tagId == tagId);

  group('la etiqueta que se edita', () {
    test('va en el centro', () {
      final slots = tagRelationsLayout(tagId: 1);

      expect(slots, hasLength(1));
      expect(slots.single.column, 0);
      expect(slots.single.row, selfRow);
    });

    test('sigue en el centro con madre y hermanas', () {
      final slots = tagRelationsLayout(
        tagId: 1,
        parentId: 9,
        siblingIds: [2, 3, 4],
      );

      expect(slotOf(slots, 1).column, 0);
      expect(slotOf(slots, 1).row, selfRow);
    });
  });

  group('la madre', () {
    test('va encima', () {
      final slots = tagRelationsLayout(tagId: 1, parentId: 9);

      expect(slotOf(slots, 9).row, parentRow);
      expect(slotOf(slots, 9).column, 0);
    });

    test('sin madre no hay hueco que pintar', () {
      final slots = tagRelationsLayout(tagId: 1, siblingIds: [2]);

      expect(slots.map((slot) => slot.row), everyElement(selfRow));
    });
  });

  group('las hermanas', () {
    // La misma fila que la etiqueta: una hermana no cuelga de nadie, y ponerla
    // más abajo la haría parecer una hija.
    test('van a los lados, nunca debajo', () {
      final slots = tagRelationsLayout(tagId: 1, siblingIds: [2, 3, 4, 5]);

      for (final id in [2, 3, 4, 5]) {
        expect(slotOf(slots, id).row, selfRow, reason: 'la $id no está al lado');
        expect(slotOf(slots, id).column, isNot(0));
      }
    });

    test('se reparten alternando a los dos lados', () {
      final slots = tagRelationsLayout(tagId: 1, siblingIds: [2, 3, 4, 5]);

      expect(slotOf(slots, 2).column, 1);
      expect(slotOf(slots, 3).column, -1);
      expect(slotOf(slots, 4).column, 2);
      expect(slotOf(slots, 5).column, -2);
    });

    test('con una sola, a la derecha', () {
      final slots = tagRelationsLayout(tagId: 1, siblingIds: [2]);

      expect(slotOf(slots, 2).column, 1);
    });

    // Sin esto, dos hermanas podrían caer en el mismo sitio y una taparía a la
    // otra sin que nada fallara.
    test('ninguna se pisa con otra', () {
      final slots = tagRelationsLayout(
        tagId: 1,
        parentId: 9,
        siblingIds: [2, 3, 4, 5, 6, 7],
      );

      final places = {for (final slot in slots) (slot.column, slot.row)};

      expect(places, hasLength(slots.length));
    });
  });

  group('lo que ocupa', () {
    test('sin hermanas, una sola columna', () {
      final columns = tagRelationsColumns(tagRelationsLayout(tagId: 1));

      expect(columns.first, 0);
      expect(columns.count, 1);
    });

    test('con hermanas a los dos lados, cuenta las dos mitades', () {
      final columns = tagRelationsColumns(
        tagRelationsLayout(tagId: 1, siblingIds: [2, 3]),
      );

      // De la −1 a la +1.
      expect(columns.first, -1);
      expect(columns.count, 3);
    });

    test('con una sola hermana no reserva sitio a la izquierda', () {
      final columns = tagRelationsColumns(
        tagRelationsLayout(tagId: 1, siblingIds: [2]),
      );

      expect(columns.first, 0);
      expect(columns.count, 2);
    });
  });
}
