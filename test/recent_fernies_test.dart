// El orden de los fernies en el menú que sale al marcar una región.
//
// Salían por orden de creación, con el recién creado el primero. Ese orden vale
// exactamente una vez: en cuanto hay tres fernies, el de arriba es el que menos
// se usa. Marcar es un gesto que se repite mucho y casi siempre sobre el mismo,
// así que lo que tiene que estar a mano es lo último que se usó.

import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/services/recent_fernies.dart';
import 'package:flutter_test/flutter_test.dart';

FernieEntity _fernie(int id) =>
    FernieEntity(id: id, name: 'fernie $id', createdAt: DateTime(2024));

List<int> _idsOf(List<FernieEntity> fernies) =>
    [for (final fernie in fernies) fernie.id];

void main() {
  final all = [_fernie(1), _fernie(2), _fernie(3), _fernie(4)];

  test('sin nada usado todavía, el orden de siempre', () {
    expect(_idsOf(ferniesByRecent(all, const [])), [1, 2, 3, 4]);
  });

  test('el último usado va el primero', () {
    expect(_idsOf(ferniesByRecent(all, const [3])), [3, 1, 2, 4]);
  });

  test('y los demás recientes detrás de él, en su orden', () {
    expect(_idsOf(ferniesByRecent(all, const [3, 1])), [3, 1, 2, 4]);
  });

  // Quien no se ha usado todavía no tiene por qué reordenarse.
  test('los que no se han usado se quedan como venían', () {
    expect(_idsOf(ferniesByRecent(all, const [4])), [4, 1, 2, 3]);
  });

  test('ninguno se pierde ni se repite', () {
    final ordered = ferniesByRecent(all, const [2, 4]);

    expect(ordered, hasLength(all.length));
    expect(_idsOf(ordered).toSet(), _idsOf(all).toSet());
  });

  // Un identificador guardado de un fernie borrado no encaja con ninguno.
  test('un reciente que ya no existe no estorba', () {
    expect(_idsOf(ferniesByRecent(all, const [99, 2])), [2, 1, 3, 4]);
  });

  test('con la lista vacía no hay nada que ordenar', () {
    expect(ferniesByRecent(const [], const [1]), isEmpty);
  });

  // Es lo que ve el menú al buscar: sólo unos pocos, y los recientes que no
  // estén entre ellos no tienen que aparecer de la nada.
  test('sobre un resultado de búsqueda, sólo recoloca lo que hay', () {
    final found = [_fernie(2), _fernie(3)];

    expect(_idsOf(ferniesByRecent(found, const [4, 3])), [3, 2]);
  });
}
