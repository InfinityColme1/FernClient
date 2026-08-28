import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/data/models/model_tree_edge_model.dart';
import 'package:Fern/features/recognition/data/models/model_tree_node_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';
import 'package:Fern/features/recognition/domain/repositories/model_tree_repository.dart';
import 'package:isar/isar.dart';

class ModelTreeRepositoryImpl implements ModelTreeRepository {
  final Isar _database;

  /// De donde salen los modelos que hay detrás de cada nodo.
  ///
  /// Se pide al repositorio de modelos en vez de leer la fila a pelo porque un
  /// modelo es más que su fila: lleva contados sus fernies y sus regiones, y la
  /// tarjeta del nodo los enseña.
  final ModelRepository _models;

  ModelTreeRepositoryImpl({
    required Isar database,
    required ModelRepository models,
  })  : _database = database,
        _models = models;

  @override
  Future<DataState<ModelTreeEntity>> getTree() async {
    try {
      return DataSuccess(await _readTree());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<ModelTreeNodeEntity>> addModel({
    required int modelId,
    int row = 0,
    int column = 0,
  }) async {
    try {
      // Un modelo aparece una sola vez: si ya está, se devuelve donde está en
      // lugar de duplicarlo. Meterlo dos veces no aporta nada y complicaría la
      // ejecución.
      final existing = await _database.modelTreeNodeModels
          .filter()
          .modelIdEqualTo(modelId)
          .findFirst();

      if (existing != null) {
        final entity = await _nodeToEntity(existing);

        return entity == null
            ? DataException(Exception('El modelo $modelId ya no existe'))
            : DataSuccess(entity);
      }

      final model = await _database.recognitionModelModels.get(modelId);
      if (model == null) {
        return DataException(Exception('El modelo $modelId no existe'));
      }

      final node = ModelTreeNodeModel()
        ..modelId = modelId
        ..row = row
        ..column = column;

      await _database.writeTxn(() async {
        node.id = await _database.modelTreeNodeModels.put(node);

        node.model.value = model;
        await node.model.save();
      });

      final entity = await _nodeToEntity(node);

      return entity == null
          ? DataException(Exception('El modelo $modelId no existe'))
          : DataSuccess(entity);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<bool>> removeNode(int nodeId) async {
    try {
      // Las aristas de los dos lados. Las que entraban se van con el nodo, y las
      // que salían dejan a sus hijos sin ese padre: los que se queden sin
      // ninguno pasan a ser raíces, que es lo que se calcula solo al leer.
      final edges = await _database.modelTreeEdgeModels
          .filter()
          .parentNodeIdEqualTo(nodeId)
          .or()
          .childNodeIdEqualTo(nodeId)
          .findAll();

      await _database.writeTxn(() async {
        await _database.modelTreeEdgeModels
            .deleteAll([for (final edge in edges) edge.id]);

        // El modelo no se toca: sigue existiendo, sólo que fuera del árbol.
        await _database.modelTreeNodeModels.delete(nodeId);
      });

      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<bool>> moveNode({
    required int nodeId,
    required int row,
    required int column,
  }) async {
    try {
      final node = await _database.modelTreeNodeModels.get(nodeId);
      if (node == null) {
        return DataException(Exception('El nodo $nodeId no existe'));
      }

      await _database.writeTxn(() async {
        node
          ..row = row
          ..column = column;

        await _database.modelTreeNodeModels.put(node);
      });

      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<ModelTreeEdgeEntity>> connect({
    required int parentNodeId,
    required int childNodeId,
    int? conditionFernieId,
  }) async {
    try {
      // Se comprueba **antes** de escribir. Un ciclo no da un error: da un
      // recorrido que no termina, y desde fuera eso parece que la aplicación se
      // ha colgado.
      final tree = await _readTree();

      if (!tree.canConnect(
        parentNodeId: parentNodeId,
        childNodeId: childNodeId,
      )) {
        return DataException(
          Exception('No se puede colgar $childNodeId de $parentNodeId'),
        );
      }

      final edge = ModelTreeEdgeModel()
        ..parentNodeId = parentNodeId
        ..childNodeId = childNodeId
        ..conditionFernieId = conditionFernieId;

      await _database.writeTxn(() async {
        edge.id = await _database.modelTreeEdgeModels.put(edge);
      });

      return DataSuccess(_edgeToEntity(edge));
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<bool>> disconnect(int edgeId) async {
    try {
      await _database.writeTxn(
        () => _database.modelTreeEdgeModels.delete(edgeId),
      );

      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<ModelTreeEdgeEntity>> reparent({
    required int parentNodeId,
    required int childNodeId,
  }) async {
    try {
      final tree = await _readTree();

      // Se mira sobre el árbol **tal y como está**, con los padres viejos
      // todavía puestos. Vale igual: que el nuevo padre sea o no descendiente
      // del hijo no depende de quién cuelgue por encima del hijo.
      if (!tree.canConnect(
        parentNodeId: parentNodeId,
        childNodeId: childNodeId,
      )) {
        return DataException(
          Exception('No se puede colgar $childNodeId de $parentNodeId'),
        );
      }

      final old = await _database.modelTreeEdgeModels
          .filter()
          .childNodeIdEqualTo(childNodeId)
          .findAll();

      final edge = ModelTreeEdgeModel()
        ..parentNodeId = parentNodeId
        ..childNodeId = childNodeId;

      // Las dos cosas en la misma transacción: o cambia de padre o se queda como
      // estaba, nunca suelto a medio camino.
      await _database.writeTxn(() async {
        await _database.modelTreeEdgeModels
            .deleteAll([for (final one in old) one.id]);

        edge.id = await _database.modelTreeEdgeModels.put(edge);
      });

      return DataSuccess(_edgeToEntity(edge));
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<bool>> promoteToRoot(int nodeId) async {
    try {
      final edges = await _database.modelTreeEdgeModels
          .filter()
          .childNodeIdEqualTo(nodeId)
          .findAll();

      await _database.writeTxn(() async {
        await _database.modelTreeEdgeModels
            .deleteAll([for (final edge in edges) edge.id]);
      });

      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<ModelTreeEdgeEntity>> setEdgeCondition({
    required int edgeId,
    required int? conditionFernieId,
  }) async {
    try {
      final edge = await _database.modelTreeEdgeModels.get(edgeId);
      if (edge == null) {
        return DataException(Exception('La arista $edgeId no existe'));
      }

      await _database.writeTxn(() async {
        edge.conditionFernieId = conditionFernieId;
        await _database.modelTreeEdgeModels.put(edge);
      });

      return DataSuccess(_edgeToEntity(edge));
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Lectura
  // ---------------------------------------------------------------------------

  /// El árbol entero, con los nodos huérfanos ya fuera.
  ///
  /// Un nodo cuyo modelo se ha borrado no se enseña ni se ejecuta: la fila puede
  /// quedarse ahí —borrar un modelo no sabe del árbol— y un nodo sin modelo no
  /// es nada que pintar.
  Future<ModelTreeEntity> _readTree() async {
    final rows = await _database.modelTreeNodeModels.where().findAll();

    final nodes = <ModelTreeNodeEntity>[];
    for (final row in rows) {
      final node = await _nodeToEntity(row);
      if (node != null) nodes.add(node);
    }

    final alive = {for (final node in nodes) node.id};
    final edges = await _database.modelTreeEdgeModels.where().findAll();

    return ModelTreeEntity(
      nodes: nodes,
      edges: [
        for (final edge in edges)
          if (alive.contains(edge.parentNodeId) &&
              alive.contains(edge.childNodeId))
            _edgeToEntity(edge),
      ],
    );
  }

  Future<ModelTreeNodeEntity?> _nodeToEntity(ModelTreeNodeModel node) async {
    final model = await _models.getModel(node.modelId);
    if (model is! DataSuccess || model.data == null) return null;

    return ModelTreeNodeEntity(
      id: node.id,
      model: model.data!,
      row: node.row,
      // La fila guarda un entero: es la posición **puesta a mano**, que hoy no
      // usa nadie porque el árbol se coloca solo. La colocación la recalcula
      // `layoutModelTree` en cada lectura y la deja fraccionaria.
      column: node.column.toDouble(),
    );
  }

  ModelTreeEdgeEntity _edgeToEntity(ModelTreeEdgeModel edge) {
    return ModelTreeEdgeEntity(
      id: edge.id,
      parentNodeId: edge.parentNodeId,
      childNodeId: edge.childNodeId,
      conditionFernieId: edge.conditionFernieId,
    );
  }
}
