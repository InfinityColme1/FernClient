// El recorrido del arbol de modelos.
//
// Es lo que de verdad importa de la fase: **la poda es el sentido del arbol**.
// Reconocer con todos los modelos siempre es caro y ruidoso; encadenarlos sirve
// para que los especializados solo corran cuando el general ha visto lo suyo. Un
// recorrido que abre ramas de mas hace exactamente el trabajo que el arbol
// existia para ahorrar, y no se nota: sale bien, solo que tarda el triple.
//
// Y uno que abre de menos es peor: el contenido se queda sin reconocer y no hay
// nada que lo explique.
//
// Se prueba sin motor y sin base de datos: al recorrido se le dice que contesta
// cada nodo.

import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/services/model_tree_traversal.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un nodo con su modelo, entrenado salvo que se diga lo contrario.
ModelTreeNodeEntity _node(
  int id, {
  bool isTrained = true,
  double threshold = 0.5,
}) {
  return ModelTreeNodeEntity(
    id: id,
    model: RecognitionModelEntity(
      id: id,
      name: 'Modelo $id',
      weightsPath: isTrained ? 'C:/runs/$id/best.pt' : null,
      confidenceThreshold: threshold,
      createdAt: DateTime(2026),
    ),
  );
}

ModelTreeEdgeEntity _edge(int id, int parent, int child, {int? onFernie}) {
  return ModelTreeEdgeEntity(
    id: id,
    parentNodeId: parent,
    childNodeId: child,
    conditionFernieId: onFernie,
  );
}

TreeDetection _seen(int fernieId, [double confidence = 0.9]) =>
    TreeDetection(fernieId: fernieId, confidence: confidence);

/// Un motor de mentira: contesta lo que se le diga por nodo, y apunta a quien le
/// han preguntado.
class _Engine {
  final Map<int, List<TreeDetection>> answers;
  final asked = <int>[];

  _Engine(this.answers);

  Future<List<TreeDetection>> call(ModelTreeNodeEntity node) async {
    asked.add(node.id);

    return answers[node.id] ?? const [];
  }
}

void main() {
  group('la poda', () {
    test('un hijo con condicion se ejecuta solo si el padre vio esa clase',
        () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2), _node(3)],
        edges: [
          _edge(1, 1, 2, onFernie: 10),
          _edge(2, 1, 3, onFernie: 20),
        ],
      );

      final engine = _Engine({
        1: [_seen(10)],
      });

      final run = await runModelTree(tree: tree, predict: engine.call);

      // El de la clase 20 no se ejecuta: es el triple de trabajo para nada.
      expect(run.executed, [1, 2]);
      expect(engine.asked, [1, 2]);
    });

    test('un padre que no ve nada no abre ninguna rama', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2)],
        edges: [_edge(1, 1, 2, onFernie: 10)],
      );

      final run = await runModelTree(tree: tree, predict: _Engine({}).call);

      expect(run.executed, [1]);
    });

    test('sin condicion, cualquier deteccion abre la rama', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2)],
        edges: [_edge(1, 1, 2)],
      );

      final engine = _Engine({
        1: [_seen(99)],
      });

      final run = await runModelTree(tree: tree, predict: engine.call);

      // Es el respaldo de una arista recien creada: sirve para algo, aunque sea
      // lo que hay que afinar.
      expect(run.executed, [1, 2]);
    });

    test('sin condicion y sin detecciones, tampoco', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2)],
        edges: [_edge(1, 1, 2)],
      );

      final run = await runModelTree(tree: tree, predict: _Engine({}).call);

      expect(run.executed, [1]);
    });

    test('la poda arrastra a los nietos', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2), _node(3)],
        edges: [
          _edge(1, 1, 2, onFernie: 10),
          _edge(2, 2, 3, onFernie: 20),
        ],
      );

      final run = await runModelTree(tree: tree, predict: _Engine({}).call);

      expect(run.executed, [1]);
    });
  });

  group('el liston de confianza', () {
    test('una deteccion floja no abre la rama', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1, threshold: 0.8), _node(2)],
        edges: [_edge(1, 1, 2, onFernie: 10)],
      );

      final engine = _Engine({
        1: [_seen(10, 0.4)],
      });

      final run = await runModelTree(tree: tree, predict: engine.call);

      expect(run.executed, [1]);
    });

    test('justo en el liston si abre', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1, threshold: 0.8), _node(2)],
        edges: [_edge(1, 1, 2, onFernie: 10)],
      );

      final engine = _Engine({
        1: [_seen(10, 0.8)],
      });

      final run = await runModelTree(tree: tree, predict: engine.call);

      expect(run.executed, [1, 2]);
    });

    test('manda el liston del padre, no el del hijo', () async {
      // La decision es «¿el padre esta seguro de lo que ha visto?». El hijo
      // todavia no ha opinado, asi que su liston no pinta nada aqui.
      final tree = ModelTreeEntity(
        nodes: [_node(1, threshold: 0.3), _node(2, threshold: 0.95)],
        edges: [_edge(1, 1, 2, onFernie: 10)],
      );

      final engine = _Engine({
        1: [_seen(10, 0.5)],
      });

      final run = await runModelTree(tree: tree, predict: engine.call);

      expect(run.executed, [1, 2]);
    });

    test('la deteccion buena abre aunque haya otras flojas', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1, threshold: 0.6), _node(2)],
        edges: [_edge(1, 1, 2, onFernie: 10)],
      );

      final engine = _Engine({
        1: [_seen(10, 0.2), _seen(10, 0.9)],
      });

      final run = await runModelTree(tree: tree, predict: engine.call);

      expect(run.executed, [1, 2]);
    });
  });

  group('los nodos sin entrenar', () {
    test('se saltan y se cuentan', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1, isTrained: false)],
      );

      final engine = _Engine({});
      final run = await runModelTree(tree: tree, predict: engine.call);

      expect(run.skipped, [1]);
      expect(run.executed, isEmpty);
      expect(engine.asked, isEmpty);
    });

    test('no tumban las otras ramas', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1, isTrained: false), _node(2)],
      );

      final engine = _Engine({
        2: [_seen(7)],
      });

      final run = await runModelTree(tree: tree, predict: engine.call);

      // Un modelo a medias no puede dejar sin reconocer todo lo demas.
      expect(run.skipped, [1]);
      expect(run.executed, [2]);
      expect(run.detections, [_seen(7)]);
    });

    test('lo que cuelga de uno sin entrenar no se ejecuta', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1, isTrained: false), _node(2)],
        edges: [_edge(1, 1, 2, onFernie: 10)],
      );

      final run = await runModelTree(tree: tree, predict: _Engine({}).call);

      // No hay deteccion que pueda abrir esa rama: ejecutar al especializado
      // «por si acaso» seria correrlo sin el filtro que lo justifica.
      expect(run.executed, isEmpty);
    });
  });

  group('varios padres', () {
    test('un hijo con dos padres se ejecuta una sola vez', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2), _node(3)],
        edges: [
          _edge(1, 1, 3, onFernie: 10),
          _edge(2, 2, 3, onFernie: 20),
        ],
      );

      final engine = _Engine({
        1: [_seen(10)],
        2: [_seen(20)],
      });

      final run = await runModelTree(tree: tree, predict: engine.call);

      expect(run.executed, [1, 2, 3]);
      expect(engine.asked.where((id) => id == 3).length, 1);
    });

    test('basta con que uno de los dos lo dispare', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2), _node(3)],
        edges: [
          _edge(1, 1, 3, onFernie: 10),
          _edge(2, 2, 3, onFernie: 20),
        ],
      );

      final engine = _Engine({
        2: [_seen(20)],
      });

      final run = await runModelTree(tree: tree, predict: engine.call);

      expect(run.executed, containsAll([1, 2, 3]));
    });

    test('un rombo no ejecuta el fondo dos veces', () async {
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

      final engine = _Engine({
        1: [_seen(1)],
        2: [_seen(2)],
        3: [_seen(3)],
      });

      final run = await runModelTree(tree: tree, predict: engine.call);

      expect(run.executed, [1, 2, 3, 4]);
    });
  });

  group('el orden', () {
    test('va por niveles, no en profundidad', () async {
      //   1        4
      //   |        |
      //   2        5
      //   |
      //   3
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2), _node(3), _node(4), _node(5)],
        edges: [
          _edge(1, 1, 2),
          _edge(2, 2, 3),
          _edge(3, 4, 5),
        ],
      );

      final engine = _Engine({
        1: [_seen(1)],
        2: [_seen(2)],
        4: [_seen(4)],
      });

      final run = await runModelTree(tree: tree, predict: engine.call);

      // Los dos raices primero: es lo que permite lotear las predicciones de un
      // mismo nivel cuando esto se use de verdad.
      expect(run.executed, [1, 4, 2, 5, 3]);
    });
  });

  group('las raices', () {
    test('son las que no cuelgan de nadie', () {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2), _node(3)],
        edges: [_edge(1, 1, 2)],
      );

      expect(tree.roots.map((node) => node.id), [1, 3]);
    });

    test('un arbol vacio no ejecuta nada y no se queja', () async {
      final run = await runModelTree(
        tree: ModelTreeEntity.empty,
        predict: _Engine({}).call,
      );

      expect(run.executed, isEmpty);
      expect(run.detections, isEmpty);
    });

    test('una arista a un nodo que ya no esta no rompe el recorrido', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1)],
        edges: [_edge(1, 1, 99)],
      );

      final engine = _Engine({
        1: [_seen(10)],
      });

      final run = await runModelTree(tree: tree, predict: engine.call);

      expect(run.executed, [1]);
    });
  });

  group('lo detectado', () {
    test('se junta todo lo de todos los nodos', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2)],
        edges: [_edge(1, 1, 2)],
      );

      final engine = _Engine({
        1: [_seen(10)],
        2: [_seen(20), _seen(21)],
      });

      final run = await runModelTree(tree: tree, predict: engine.call);

      expect(run.detections, [_seen(10), _seen(20), _seen(21)]);
    });

    test('lo que no llega al liston se detecta igual, solo no abre rama',
        () async {
      // El liston decide **que se ejecuta despues**, no que se descarte lo
      // visto: quien decide si una sugerencia vale la pena es el usuario.
      final tree = ModelTreeEntity(
        nodes: [_node(1, threshold: 0.9), _node(2)],
        edges: [_edge(1, 1, 2, onFernie: 10)],
      );

      final engine = _Engine({
        1: [_seen(10, 0.3)],
      });

      final run = await runModelTree(tree: tree, predict: engine.call);

      expect(run.detections, [_seen(10, 0.3)]);
      expect(run.executed, [1]);
    });
  });

  group('en lote', () {
    /// El árbol con el que se comprueba todo: una raíz que abre un hijo sólo si
    /// ve el fernie 1, un nieto sin condición, y una segunda raíz suelta.
    final tree = ModelTreeEntity(
      nodes: [_node(1), _node(2), _node(3), _node(4)],
      edges: [
        _edge(1, 1, 2, onFernie: 1),
        _edge(2, 2, 3),
      ],
    );

    /// Lo que cada nodo ve en cada contenido.
    const respuestas = <int, Map<int, List<(int, double)>>>{
      // Abre la rama: ve el fernie 1.
      10: {
        1: [(1, 0.9)],
        2: [(7, 0.8)],
        3: [(8, 0.7)],
        4: [(9, 0.6)],
      },
      // No la abre: ve otra cosa.
      20: {
        1: [(5, 0.9)],
        2: [(7, 0.8)],
        3: [(8, 0.7)],
        4: [(9, 0.6)],
      },
      // La ve, pero por debajo del listón del padre.
      30: {
        1: [(1, 0.2)],
        2: [(7, 0.8)],
        3: [(8, 0.7)],
        4: [(9, 0.6)],
      },
      // No ve nada.
      40: <int, List<(int, double)>>{},
    };

    List<TreeDetection> answer(int media, int node) => [
          for (final pair in respuestas[media]?[node] ?? const <(int, double)>[])
            _seen(pair.$1, pair.$2),
        ];

    test('da exactamente lo mismo que ir de uno en uno', () async {
      final media = respuestas.keys.toList();

      final uno = <int, TreeRun>{};
      for (final id in media) {
        uno[id] = await runModelTree(
          tree: tree,
          predict: (node) async => answer(id, node.id),
        );
      }

      final lote = await runModelTreeBatched(
        tree: tree,
        mediaIds: media,
        predict: (node, ids) async => {
          for (final id in ids) id: answer(id, node.id),
        },
      );

      // La promesa entera del paso: mismos niveles, misma poda, mismas reglas.
      // Lo que cambia es el coste, no el resultado.
      expect(lote, uno);
    });

    test('un nodo se pide una vez por nivel, no una por contenido', () async {
      final llamadas = <int>[];

      await runModelTreeBatched(
        tree: tree,
        mediaIds: respuestas.keys.toList(),
        predict: (node, ids) async {
          llamadas.add(node.id);

          return {for (final id in ids) id: answer(id, node.id)};
        },
      );

      // Cuatro contenidos y cuatro nodos: de dieciséis llamadas a cuatro.
      expect(llamadas..sort(), [1, 2, 3, 4]);
    });

    test('al hijo sólo bajan los contenidos que abrieron su rama', () async {
      final bajaron = <int, List<int>>{};

      await runModelTreeBatched(
        tree: tree,
        mediaIds: respuestas.keys.toList(),
        predict: (node, ids) async {
          bajaron[node.id] = [...ids];

          return {for (final id in ids) id: answer(id, node.id)};
        },
      );

      // Es lo que hace que esto no sea una simplificación: sin ello, el lote
      // ejecutaría los especializados sobre todo el mundo.
      expect(bajaron[1], [10, 20, 30, 40]);
      expect(bajaron[2], [10]);
      expect(bajaron[3], [10]);
      expect(bajaron[4], [10, 20, 30, 40]);
    });

    test('un nodo sin contenidos que le toquen no se ejecuta', () async {
      final llamadas = <int>[];

      await runModelTreeBatched(
        tree: tree,
        // Ninguno abre la rama del 2.
        mediaIds: const [20, 30],
        predict: (node, ids) async {
          llamadas.add(node.id);

          return {for (final id in ids) id: answer(id, node.id)};
        },
      );

      expect(llamadas..sort(), [1, 4]);
    });

    test('el que no está entrenado se cuenta en cada contenido', () async {
      final roto = ModelTreeEntity(
        nodes: [_node(1, isTrained: false), _node(2)],
        edges: [_edge(1, 1, 2)],
      );

      final lote = await runModelTreeBatched(
        tree: roto,
        mediaIds: const [10, 20],
        predict: (node, ids) async => const {},
      );

      expect(lote[10]!.skipped, [1]);
      expect(lote[20]!.skipped, [1]);
      expect(lote[10]!.executed, isEmpty);
    });

    test('sin contenidos no se pregunta nada', () async {
      final llamadas = <int>[];

      final lote = await runModelTreeBatched(
        tree: tree,
        mediaIds: const [],
        predict: (node, ids) async {
          llamadas.add(node.id);

          return const {};
        },
      );

      expect(lote, isEmpty);
      expect(llamadas, isEmpty);
    });

    test('un nodo con dos padres se pide una sola vez', () async {
      // Dos raíces que llevan las dos al mismo hijo.
      final rombo = ModelTreeEntity(
        nodes: [_node(1), _node(4), _node(2)],
        edges: [_edge(1, 1, 2), _edge(2, 4, 2)],
      );

      final llamadas = <int>[];

      final lote = await runModelTreeBatched(
        tree: rombo,
        mediaIds: const [10],
        predict: (node, ids) async {
          llamadas.add(node.id);

          return {for (final id in ids) id: [_seen(1)]};
        },
      );

      // Ejecutarlo dos veces sería predecir dos veces lo mismo y guardar la
      // sugerencia por duplicado.
      expect(llamadas.where((one) => one == 2).length, 1);
      expect(lote[10]!.executed, [1, 4, 2]);
    });

    test('un contenido del que el motor no dice nada no rompe', () async {
      final lote = await runModelTreeBatched(
        tree: tree,
        mediaIds: const [10, 20],
        // Contesta sólo por uno: el otro simplemente no está en el mapa.
        predict: (node, ids) async => {10: answer(10, node.id)},
      );

      expect(lote[20]!.detections, isEmpty);
      expect(lote[20]!.executed, [1, 4]);
    });
  });
}
