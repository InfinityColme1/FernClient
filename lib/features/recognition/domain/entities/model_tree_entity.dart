import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:equatable/equatable.dart';

/// Un modelo colocado en el árbol.
///
/// El nodo y el modelo son cosas distintas: el modelo existe aunque no esté en
/// el árbol —y entonces no se ejecuta nunca—, y el nodo es el sitio que ocupa.
class ModelTreeNodeEntity extends Equatable {
  final int id;
  final RecognitionModelEntity model;

  /// Dónde se pinta: la fila es la profundidad y la columna el sitio a lo ancho
  /// de esa fila. Es sólo dibujo; quién ejecuta a quién lo dicen las aristas.
  ///
  /// La columna es **fraccionaria**: no es un hueco de una rejilla, es un sitio.
  /// Con columnas enteras, un padre con dos hijos no puede ponerse en medio de
  /// los dos, que es justo lo que hace que un árbol se lea de un vistazo.
  final int row;
  final double column;

  const ModelTreeNodeEntity({
    required this.id,
    required this.model,
    this.row = 0,
    this.column = 0,
  });

  /// Si este nodo puede llegar a reconocer algo.
  ///
  /// Sin pesos no hay nada que ejecutar. No bloquea el reconocimiento entero: se
  /// salta y se avisa, que es distinto de fallar.
  bool get isRunnable => model.isUsable;

  ModelTreeNodeEntity copyWith({
    RecognitionModelEntity? model,
    int? row,
    double? column,
  }) {
    return ModelTreeNodeEntity(
      id: id,
      model: model ?? this.model,
      row: row ?? this.row,
      column: column ?? this.column,
    );
  }

  @override
  List<Object?> get props => [id, model, row, column];
}

/// Qué dispara a qué.
///
/// La condición es **una clase concreta del padre**, no «que el padre haya
/// detectado algo»: sin eso, todos los modelos especializados se ejecutarían
/// ante cualquier detección, que es el triple de trabajo para nada.
class ModelTreeEdgeEntity extends Equatable {
  final int id;
  final int parentNodeId;
  final int childNodeId;

  /// El fernie del padre que dispara al hijo, o `null` para «cualquier cosa que
  /// detecte el padre».
  ///
  /// El `null` es el respaldo de cuando se acaba de crear la arista y todavía no
  /// se ha elegido con qué: sirve para algo, pero es lo que hay que afinar.
  final int? conditionFernieId;

  const ModelTreeEdgeEntity({
    required this.id,
    required this.parentNodeId,
    required this.childNodeId,
    this.conditionFernieId,
  });

  ModelTreeEdgeEntity copyWith({int? conditionFernieId, bool clearCondition = false}) {
    return ModelTreeEdgeEntity(
      id: id,
      parentNodeId: parentNodeId,
      childNodeId: childNodeId,
      conditionFernieId:
          clearCondition ? null : (conditionFernieId ?? this.conditionFernieId),
    );
  }

  @override
  List<Object?> get props => [id, parentNodeId, childNodeId, conditionFernieId];
}

/// El árbol entero, ya resuelto en memoria.
///
/// Se pinta como un árbol pero **es un grafo dirigido sin ciclos**: un nodo
/// puede tener varios padres, y entonces se ejecuta una sola vez aunque los dos
/// lo disparen. Lo que no puede es tener ciclos, porque el recorrido no
/// terminaría.
///
/// Hay uno solo por instalación. No hay varios árboles ni perfiles: nadie ha
/// pedido eso y multiplicaría el estado sin dar nada.
class ModelTreeEntity extends Equatable {
  final List<ModelTreeNodeEntity> nodes;
  final List<ModelTreeEdgeEntity> edges;

  const ModelTreeEntity({this.nodes = const [], this.edges = const []});

  static const empty = ModelTreeEntity();

  /// Los que arrancan el recorrido: los que no cuelgan de nadie.
  ///
  /// Se calcula en vez de guardarse: una marca `isRoot` en la fila se
  /// desincroniza en cuanto alguien borra una arista sin acordarse de tocarla, y
  /// entonces un nodo deja de ejecutarse sin que nada lo explique.
  List<ModelTreeNodeEntity> get roots {
    final withParents = edges.map((edge) => edge.childNodeId).toSet();

    return nodes.where((node) => !withParents.contains(node.id)).toList();
  }

  ModelTreeNodeEntity? nodeById(int id) {
    for (final node in nodes) {
      if (node.id == id) return node;
    }

    return null;
  }

  /// El nodo donde está este modelo, si está.
  ///
  /// Un modelo aparece **una sola vez**: repetirlo no aporta nada y complica la
  /// ejecución.
  ModelTreeNodeEntity? nodeOfModel(int modelId) {
    for (final node in nodes) {
      if (node.model.id == modelId) return node;
    }

    return null;
  }

  List<ModelTreeEdgeEntity> edgesFrom(int nodeId) =>
      edges.where((edge) => edge.parentNodeId == nodeId).toList();

  List<ModelTreeEdgeEntity> edgesInto(int nodeId) =>
      edges.where((edge) => edge.childNodeId == nodeId).toList();

  /// Si [candidate] está por encima de [nodeId] siguiendo las aristas.
  ///
  /// Es lo que impide los ciclos: colgar un nodo de uno de sus propios
  /// descendientes deja un recorrido que no termina. Se comprueba **antes** de
  /// crear la arista, no después.
  ///
  /// Va con su propio conjunto de visitados porque el grafo puede tener rombos
  /// —dos caminos hasta el mismo nodo— y sin él se recorrería dos veces cada
  /// uno; con muchos, exponencialmente.
  bool isAncestorOf({required int candidate, required int nodeId}) {
    final pending = <int>[nodeId];
    final seen = <int>{};

    while (pending.isNotEmpty) {
      final current = pending.removeLast();
      if (!seen.add(current)) continue;

      for (final edge in edgesInto(current)) {
        if (edge.parentNodeId == candidate) return true;

        pending.add(edge.parentNodeId);
      }
    }

    return false;
  }

  /// Si se puede colgar [childNodeId] de [parentNodeId].
  ///
  /// Ni de sí mismo, ni de un descendiente suyo, ni dos veces del mismo padre.
  bool canConnect({required int parentNodeId, required int childNodeId}) {
    if (parentNodeId == childNodeId) return false;
    if (nodeById(parentNodeId) == null || nodeById(childNodeId) == null) {
      return false;
    }

    final isRepeated = edges.any((edge) =>
        edge.parentNodeId == parentNodeId && edge.childNodeId == childNodeId);
    if (isRepeated) return false;

    return !isAncestorOf(candidate: childNodeId, nodeId: parentNodeId);
  }

  @override
  List<Object?> get props => [nodes, edges];
}
