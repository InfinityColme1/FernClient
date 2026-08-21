// Lo que impide que el arbol se muerda la cola.
//
// Un ciclo no da un error: da un recorrido que **no termina**. El reconocimiento
// se queda dando vueltas ejecutando los mismos modelos, cada uno tarda lo suyo, y
// desde fuera lo que se ve es que la aplicacion se ha colgado. Por eso se
// comprueba **antes** de crear la arista y no despues.
//
// El caso que se escapa siempre es el largo: nadie cuelga un nodo de si mismo por
// accidente, pero colgar el general de un especializado que ya cuelga de el, tres
// niveles mas abajo, es facilisimo con el raton.

import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
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

/// Una cadena 1 → 2 → 3 → ... del largo que se pida.
ModelTreeEntity _chain(int length) {
  return ModelTreeEntity(
    nodes: [for (var id = 1; id <= length; id++) _node(id)],
    edges: [for (var id = 1; id < length; id++) _edge(id, id, id + 1)],
  );
}

void main() {
  group('los ancestros', () {
    test('el padre directo lo es', () {
      final tree = _chain(2);

      expect(tree.isAncestorOf(candidate: 1, nodeId: 2), isTrue);
    });

    test('el bisabuelo tambien', () {
      final tree = _chain(4);

      // Es el que se escapa: nadie cuelga un nodo de si mismo por accidente.
      expect(tree.isAncestorOf(candidate: 1, nodeId: 4), isTrue);
    });

    test('el hijo no es ancestro de su padre', () {
      final tree = _chain(2);

      expect(tree.isAncestorOf(candidate: 2, nodeId: 1), isFalse);
    });

    test('uno de otra rama no lo es', () {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2), _node(3)],
        edges: [_edge(1, 1, 2)],
      );

      expect(tree.isAncestorOf(candidate: 3, nodeId: 2), isFalse);
    });

    test('un nodo no es ancestro de si mismo', () {
      expect(_chain(3).isAncestorOf(candidate: 2, nodeId: 2), isFalse);
    });

    test('con dos caminos hasta el mismo nodo, se recorre una vez', () {
      //   1
      //  / \
      // 2   3
      //  \ /
      //   4
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2), _node(3), _node(4)],
        edges: [
          _edge(1, 1, 2),
          _edge(2, 1, 3),
          _edge(3, 2, 4),
          _edge(4, 3, 4),
        ],
      );

      // Sin llevar la cuenta de lo visto, un grafo con muchos rombos se recorre
      // exponencialmente: no se cuelga por el ciclo, se cuelga por contarlo.
      expect(tree.isAncestorOf(candidate: 1, nodeId: 4), isTrue);
    });
  });

  group('conectar', () {
    test('de padre a hijo nuevo se puede', () {
      final tree = ModelTreeEntity(nodes: [_node(1), _node(2)]);

      expect(tree.canConnect(parentNodeId: 1, childNodeId: 2), isTrue);
    });

    test('a si mismo no', () {
      final tree = ModelTreeEntity(nodes: [_node(1)]);

      expect(tree.canConnect(parentNodeId: 1, childNodeId: 1), isFalse);
    });

    test('de un nodo a su propio padre no', () {
      final tree = _chain(2);

      expect(tree.canConnect(parentNodeId: 2, childNodeId: 1), isFalse);
    });

    test('de un nodo a un ancestro lejano tampoco', () {
      final tree = _chain(5);

      // Colgar el general de un especializado que ya cuelga de el, cuatro
      // niveles mas abajo, es facilisimo con el raton.
      expect(tree.canConnect(parentNodeId: 5, childNodeId: 1), isFalse);
    });

    test('la misma arista dos veces no', () {
      final tree = _chain(2);

      // Ejecutar el hijo dos veces por la misma razon no aporta nada.
      expect(tree.canConnect(parentNodeId: 1, childNodeId: 2), isFalse);
    });

    test('un segundo padre si: es un grafo, no un arbol estricto', () {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2), _node(3)],
        edges: [_edge(1, 1, 3)],
      );

      expect(tree.canConnect(parentNodeId: 2, childNodeId: 3), isTrue);
    });

    test('a un nodo que no esta en el arbol, no', () {
      final tree = ModelTreeEntity(nodes: [_node(1)]);

      expect(tree.canConnect(parentNodeId: 1, childNodeId: 99), isFalse);
      expect(tree.canConnect(parentNodeId: 99, childNodeId: 1), isFalse);
    });

    test('cerrar un rombo por abajo se puede: no es un ciclo', () {
      //   1        1
      //  / \  →   / \
      // 2   3    2   3
      //           \ /
      //            ...
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2), _node(3), _node(4)],
        edges: [_edge(1, 1, 2), _edge(2, 1, 3), _edge(3, 2, 4)],
      );

      expect(tree.canConnect(parentNodeId: 3, childNodeId: 4), isTrue);
    });
  });

  group('un modelo esta una sola vez', () {
    test('se encuentra por su modelo', () {
      final tree = ModelTreeEntity(nodes: [_node(1), _node(2)]);

      expect(tree.nodeOfModel(2)?.id, 2);
      expect(tree.nodeOfModel(99), isNull);
    });
  });
}
