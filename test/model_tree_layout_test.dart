// Donde se pinta cada nodo del arbol.
//
// El usuario conecta, no coloca: ordenar tarjetas a mano con veinte modelos es el
// motivo por el que nadie vuelve a tocar una pantalla asi.
//
// Lo que hay que sostener son dos cosas. Que **ninguna flecha suba**: un hijo
// siempre por debajo de todos sus padres, porque un arbol con flechas hacia
// arriba deja de leerse como un arbol. Y que la colocacion sea **repetible**: si
// no, las tarjetas bailan de sitio en cada relectura y no hay forma de seguirlas
// con la vista.

import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/services/model_tree_layout.dart';
import 'package:flutter_test/flutter_test.dart';

ModelTreeNodeEntity _node(int id) {
  return ModelTreeNodeEntity(
    id: id,
    model: RecognitionModelEntity(
      id: id,
      name: 'Modelo $id',
      createdAt: DateTime(2026),
    ),
  );
}

ModelTreeEdgeEntity _edge(int id, int parent, int child) =>
    ModelTreeEdgeEntity(id: id, parentNodeId: parent, childNodeId: child);

/// Un arbol con los nodos que se pidan y las aristas dadas como pares.
ModelTreeEntity _tree(List<int> ids, List<List<int>> links) {
  return ModelTreeEntity(
    nodes: [for (final id in ids) _node(id)],
    edges: [
      for (var i = 0; i < links.length; i++) _edge(i + 1, links[i][0], links[i][1]),
    ],
  );
}

/// La fila de cada nodo, por su identificador.
Map<int, int> _rows(ModelTreeEntity tree) =>
    {for (final node in tree.nodes) node.id: node.row};

Map<int, double> _columns(ModelTreeEntity tree) =>
    {for (final node in tree.nodes) node.id: node.column};

/// El orden en que quedan los nodos de una fila, de izquierda a derecha.
List<int> _orderOfRow(ModelTreeEntity tree, int row) {
  final nodes = tree.nodes.where((node) => node.row == row).toList()
    ..sort((a, b) => a.column.compareTo(b.column));

  return [for (final node in nodes) node.id];
}

void main() {
  group('las filas', () {
    test('las raices van arriba del todo', () {
      final laid = layoutModelTree(_tree([1, 2], []));

      expect(_rows(laid), {1: 0, 2: 0});
    });

    test('cada hijo, una fila por debajo', () {
      final laid = layoutModelTree(_tree([1, 2, 3], [
        [1, 2],
        [2, 3],
      ]));

      expect(_rows(laid), {1: 0, 2: 1, 3: 2});
    });

    test('con dos padres manda el camino mas largo', () {
      //  1 ──────┐
      //  └─ 2 ─ 3 ─ 4
      final laid = layoutModelTree(_tree([1, 2, 3, 4], [
        [1, 2],
        [2, 3],
        [3, 4],
        [1, 4],
      ]));

      // Poner el 4 en la fila 1 —que es lo que diria el camino corto— haria que
      // la flecha desde el 3 subiera.
      expect(_rows(laid)[4], 3);
    });

    test('ninguna flecha sube nunca', () {
      final tree = _tree([1, 2, 3, 4, 5, 6], [
        [1, 3],
        [2, 3],
        [3, 4],
        [1, 5],
        [5, 6],
        [4, 6],
      ]);

      final laid = layoutModelTree(tree);
      final rows = _rows(laid);

      for (final edge in laid.edges) {
        expect(
          rows[edge.childNodeId]!,
          greaterThan(rows[edge.parentNodeId]!),
          reason: 'la arista ${edge.parentNodeId}→${edge.childNodeId} sube',
        );
      }
    });

    test('el orden de las aristas no cambia el resultado', () {
      final forwards = layoutModelTree(_tree([1, 2, 3], [
        [1, 2],
        [2, 3],
      ]));

      final backwards = layoutModelTree(_tree([1, 2, 3], [
        [2, 3],
        [1, 2],
      ]));

      // La primera pasada del calculo depende del orden; repetirlo hasta que
      // nadie se mueve es lo que lo quita.
      expect(_rows(forwards), _rows(backwards));
    });
  });

  group('las columnas', () {
    test('los de una misma fila van en columnas seguidas', () {
      final laid = layoutModelTree(_tree([1, 2, 3], []));

      expect(_columns(laid).values.toList()..sort(), [0, 1, 2]);
    });

    test('un hijo se pone debajo de por donde le llegan las flechas', () {
      //  1   2   3      (fila 0)
      //          └─ 4   (fila 1)
      final laid = layoutModelTree(_tree([1, 2, 3, 4], [
        [3, 4],
      ]));

      final columns = _columns(laid);

      // Debajo del 3, no en el hueco de la izquierda de su fila: el sitio no es
      // un hueco de rejilla, es donde le llegan las flechas.
      expect(columns[4], closeTo(columns[3]!, 0.01));
      expect(_rows(laid)[4], 1);
    });

    test('con dos hijos, el del padre de la derecha va a la derecha', () {
      //  1       2
      //  └─ 3    └─ 4
      final laid = layoutModelTree(_tree([1, 2, 3, 4], [
        [1, 3],
        [2, 4],
      ]));

      final columns = _columns(laid);

      // Al reves se cruzarian las dos aristas sin ninguna necesidad.
      expect(columns[3]! < columns[4]!, isTrue);
    });

    test('un hijo de dos padres queda entre los dos', () {
      //  1   2   3
      //  └───────┘  →  el 4 cuelga del 1 y del 3; el 5 cuelga del 2
      final laid = layoutModelTree(_tree([1, 2, 3, 4, 5], [
        [1, 4],
        [3, 4],
        [2, 5],
      ]));

      final columns = _columns(laid);
      final left = columns[1]! < columns[3]! ? columns[1]! : columns[3]!;
      final right = columns[1]! < columns[3]! ? columns[3]! : columns[1]!;

      expect(columns[4]!, greaterThanOrEqualTo(left));
      expect(columns[4]!, lessThanOrEqualTo(right));
      expect(_orderOfRow(laid, 1), [4, 5]);
    });
  });

  group('los padres, centrados sobre sus hijos', () {
    test('un padre de dos hijos queda en medio de los dos', () {
      final laid = layoutModelTree(_tree([1, 2, 3], [
        [1, 2],
        [1, 3],
      ]));

      final columns = _columns(laid);
      final children = [columns[2]!, columns[3]!];

      // Es lo que hace que un arbol se lea de un vistazo. Con columnas enteras
      // esto no se puede: el padre acabaria encima de uno de los dos.
      expect(columns[1], closeTo((children[0] + children[1]) / 2, 0.01));
    });

    test('un padre de tres hijos queda sobre el de en medio', () {
      final laid = layoutModelTree(_tree([1, 2, 3, 4], [
        [1, 2],
        [1, 3],
        [1, 4],
      ]));

      final columns = _columns(laid);
      final middle = [columns[2]!, columns[3]!, columns[4]!]..sort();

      expect(columns[1], closeTo(middle[1], 0.01));
    });

    test('dos padres con sus hijos no se pisan', () {
      //  1        2
      //  ├─ 3     ├─ 5
      //  └─ 4     └─ 6
      final laid = layoutModelTree(_tree([1, 2, 3, 4, 5, 6], [
        [1, 3],
        [1, 4],
        [2, 5],
        [2, 6],
      ]));

      final columns = _columns(laid);

      // Cada padre sobre los suyos, y las dos familias separadas.
      expect(columns[1], closeTo((columns[3]! + columns[4]!) / 2, 0.01));
      expect(columns[2], closeTo((columns[5]! + columns[6]!) / 2, 0.01));
      expect(columns[1]! < columns[2]!, isTrue);
    });

    test('los nodos de una fila nunca se solapan', () {
      final laid = layoutModelTree(_tree([1, 2, 3, 4, 5, 6, 7], [
        [1, 3],
        [1, 4],
        [2, 5],
        [3, 6],
        [3, 7],
      ]));

      for (var row = 0; row <= 2; row++) {
        final inRow = laid.nodes.where((node) => node.row == row).toList()
          ..sort((a, b) => a.column.compareTo(b.column));

        for (var index = 1; index < inRow.length; index++) {
          expect(
            inRow[index].column - inRow[index - 1].column,
            greaterThanOrEqualTo(0.999),
            reason: 'se pisan en la fila $row',
          );
        }
      }
    });

    test('la columna mas a la izquierda queda en cero', () {
      final laid = layoutModelTree(_tree([1, 2, 3], [
        [1, 2],
        [1, 3],
      ]));

      // Los sitios salen de promedios y pueden quedar en negativo; el lienzo se
      // dibuja desde el origen.
      final min = _columns(laid).values.reduce((a, b) => a < b ? a : b);
      expect(min, 0);
    });

    test('el orden dentro de la fila se respeta', () {
      final laid = layoutModelTree(_tree([1, 2, 3, 4], [
        [1, 3],
        [2, 4],
      ]));

      expect(_orderOfRow(laid, 1), [3, 4]);
    });
  });

  group('que sea repetible', () {
    test('colocar dos veces da lo mismo', () {
      final tree = _tree([1, 2, 3, 4, 5], [
        [1, 3],
        [2, 3],
        [3, 4],
        [2, 5],
      ]);

      final once = layoutModelTree(tree);
      final twice = layoutModelTree(tree);

      expect(_rows(once), _rows(twice));
      expect(_columns(once), _columns(twice));
    });

    test('volver a colocar lo ya colocado no lo mueve', () {
      final tree = _tree([1, 2, 3], [
        [1, 2],
        [1, 3],
      ]);

      final once = layoutModelTree(tree);
      final again = layoutModelTree(once);

      expect(_rows(again), _rows(once));
      expect(_columns(again), _columns(once));
    });
  });

  group('casos raros', () {
    test('un arbol vacio se queda vacio', () {
      expect(layoutModelTree(ModelTreeEntity.empty).nodes, isEmpty);
    });

    test('una arista a un nodo que no esta no rompe nada', () {
      final laid = layoutModelTree(_tree([1], [
        [1, 99],
      ]));

      expect(_rows(laid), {1: 0});
    });

    test('un ciclo que se hubiera colado no cuelga la pantalla', () {
      // El repositorio no deja crearlos, pero una base de datos tocada a mano
      // no puede dejar la pantalla dando vueltas para siempre.
      final laid = layoutModelTree(_tree([1, 2], [
        [1, 2],
        [2, 1],
      ]));

      expect(laid.nodes, hasLength(2));
    });

    test('las aristas se devuelven tal cual', () {
      final tree = _tree([1, 2], [
        [1, 2],
      ]);

      expect(layoutModelTree(tree).edges, tree.edges);
    });
  });
}
