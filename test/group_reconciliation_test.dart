// Cruzar lo que acaba de encontrar el escaneo con lo que ya se sabía.
//
// Sin esto, cada escaneo automático vuelve a poner delante los mismos falsos
// positivos que el usuario ya descartó. Y entonces el aviso del menú deja de
// significar algo: la primera vez se mira, la tercera se ignora, y con ella se
// ignoran también los grupos que sí valían la pena.

import 'package:Fern/features/duplicates/domain/services/duplicate_grouping.dart';
import 'package:Fern/features/duplicates/domain/services/group_reconciliation.dart';
import 'package:flutter_test/flutter_test.dart';

DuplicateGroup _group(List<int> ids, {int distance = 0}) =>
    DuplicateGroup(mediaIds: ids, maxDistance: distance);

void main() {
  group('lo que se propone', () {
    test('un grupo que no se había visto', () {
      final result = reconcileGroups([_group([1, 2])], const []);

      expect(result.single.outcome, GroupOutcome.fresh);
      expect(result.single.needsReview, isTrue);
    });

    test('uno que ya se conocía y sigue sin mirar', () {
      final result = reconcileGroups(
        [_group([1, 2])],
        [const KnownGroup(mediaIds: [1, 2])],
      );

      // Se conoce, así que no vuelve a contar como novedad: el aviso avisa de lo
      // nuevo, no de lo que lleva ahí desde el mes pasado.
      expect(result.single.outcome, GroupOutcome.known);
      expect(result.single.needsReview, isFalse);
    });
  });

  group('lo que el usuario ya contestó', () {
    test('lo descartado no vuelve', () {
      final result = reconcileGroups(
        [_group([1, 2])],
        [const KnownGroup(mediaIds: [1, 2], isDismissed: true)],
      );

      expect(result.single.outcome, GroupOutcome.dismissed);
      expect(result.single.needsReview, isFalse);
    });

    test('lo resuelto tampoco', () {
      final result = reconcileGroups(
        [_group([1, 2])],
        [const KnownGroup(mediaIds: [1, 2], isResolved: true)],
      );

      expect(result.single.outcome, GroupOutcome.resolved);
    });

    test('el descarte manda sobre el resuelto', () {
      final result = reconcileGroups(
        [_group([1, 2])],
        [const KnownGroup(mediaIds: [1, 2], isResolved: true, isDismissed: true)],
      );

      expect(result.single.outcome, GroupOutcome.dismissed);
    });
  });

  group('cómo se reconoce un grupo', () {
    test('por sus contenidos, en cualquier orden', () {
      final result = reconcileGroups(
        [_group([1, 2, 3])],
        [const KnownGroup(mediaIds: [3, 1, 2], isDismissed: true)],
      );

      expect(result.single.outcome, GroupOutcome.dismissed);
    });

    test('no por su distancia', () {
      // Recalcular los hashes puede mover la distancia sin que el grupo sea otro.
      final result = reconcileGroups(
        [_group([1, 2], distance: 5)],
        [const KnownGroup(mediaIds: [1, 2], isDismissed: true)],
      );

      expect(result.single.outcome, GroupOutcome.dismissed);
    });

    test('con una copia más es otro grupo', () {
      final result = reconcileGroups(
        [_group([1, 2, 3])],
        [const KnownGroup(mediaIds: [1, 2], isDismissed: true)],
      );

      // El usuario dijo que aquellos dos no eran el mismo, no que este tercero
      // no lo fuera: hay algo nuevo que preguntar.
      expect(result.single.outcome, GroupOutcome.fresh);
    });

    test('con una copia menos también', () {
      final result = reconcileGroups(
        [_group([1, 2])],
        [const KnownGroup(mediaIds: [1, 2, 3], isDismissed: true)],
      );

      expect(result.single.outcome, GroupOutcome.fresh);
    });
  });

  group('varios a la vez', () {
    test('cada uno con lo suyo', () {
      final result = reconcileGroups(
        [
          _group([1, 2]),
          _group([3, 4]),
          _group([5, 6]),
        ],
        [
          const KnownGroup(mediaIds: [3, 4], isDismissed: true),
          const KnownGroup(mediaIds: [5, 6]),
        ],
      );

      expect(
        [for (final one in result) one.outcome],
        [GroupOutcome.fresh, GroupOutcome.dismissed, GroupOutcome.known],
      );
    });

    test('se devuelven todos, no sólo los que hay que revisar', () {
      // Los descartados también se guardan: hay que poder enseñarlos si alguien
      // quiere revisar lo que dijo que no era.
      final result = reconcileGroups(
        [_group([1, 2])],
        [const KnownGroup(mediaIds: [1, 2], isDismissed: true)],
      );

      expect(result, hasLength(1));
    });

    test('sin nada encontrado, nada', () {
      expect(reconcileGroups(const [], const []), isEmpty);
    });

    test('lo que se sabía y ya no aparece no se inventa', () {
      final result = reconcileGroups(
        const [],
        [const KnownGroup(mediaIds: [1, 2])],
      );

      // Una de las copias se borró: el grupo dejó de existir y no hay nada que
      // proponer.
      expect(result, isEmpty);
    });
  });
}
