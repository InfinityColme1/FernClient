import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/model_fernie_model.dart';
import 'package:Fern/features/recognition/data/models/model_tree_edge_model.dart';
import 'package:Fern/features/recognition/data/models/model_tree_node_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';
import 'package:isar/isar.dart';

class ModelRepositoryImpl implements ModelRepository {
  final Isar _database;

  ModelRepositoryImpl({required Isar database}) : _database = database;

  // ---------------------------------------------------------------------------
  // Modelos
  // ---------------------------------------------------------------------------

  @override
  Future<DataState<List<RecognitionModelEntity>>> getModels() async {
    try {
      final models = await _database.recognitionModelModels
          .where()
          .sortByCreatedAt()
          .findAll();

      return DataSuccess([
        for (final model in models) await _toEntity(model),
      ]);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<RecognitionModelEntity>> getModel(int id) async {
    try {
      final model = await _database.recognitionModelModels.get(id);
      if (model == null) return DataException(Exception('Modelo $id no existe'));

      return DataSuccess(await _toEntity(model));
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<RecognitionModelEntity>> saveModel(
    RecognitionModelEntity model,
  ) async {
    try {
      final row = RecognitionModelModel.fromEntity(model);

      await _database.writeTxn(() async {
        final id = await _database.recognitionModelModels.put(row);
        row.id = id;
      });

      // Se relee en vez de devolver lo que se acaba de escribir: la función
      // efectiva depende de cuántos fernies tiene, y eso se cuenta aquí.
      return getModel(row.id);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<bool>> deleteModel(int id) async {
    try {
      await _database.writeTxn(() async {
        final assignments = await _database.modelFernieModels
            .filter()
            .model((query) => query.idEqualTo(id))
            .findAll();

        // Los fernies no se tocan: son suyos, no del modelo, y siguen valiendo
        // para otros. Lo que desaparece es que estuvieran metidos en éste.
        await _database.modelFernieModels
            .deleteAll([for (final row in assignments) row.id]);

        // Y su sitio en el árbol, si lo tenía. Va en **esta misma transacción**
        // y no en un paso aparte: un nodo apuntando a un modelo que ya no existe
        // no se puede pintar ni ejecutar, así que dejarlo a medias es dejar
        // basura que nadie va a reconocer meses después. Al leer el árbol se
        // filtraban, sí, pero eso es una consulta por fila muerta en cada
        // relectura.
        final node = await _database.modelTreeNodeModels
            .filter()
            .modelIdEqualTo(id)
            .findFirst();

        if (node != null) {
          final edges = await _database.modelTreeEdgeModels
              .filter()
              .parentNodeIdEqualTo(node.id)
              .or()
              .childNodeIdEqualTo(node.id)
              .findAll();

          // Los hijos que se queden sin padres pasan a ser raíces solos: ser
          // raíz es no tener aristas entrantes, y eso se calcula al leer.
          await _database.modelTreeEdgeModels
              .deleteAll([for (final edge in edges) edge.id]);

          await _database.modelTreeNodeModels.delete(node.id);
        }

        await _database.recognitionModelModels.delete(id);
      });

      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Fernies del modelo
  // ---------------------------------------------------------------------------

  @override
  Future<DataState<List<ModelFernieEntity>>> getFerniesOfModel(
    int modelId,
  ) async {
    try {
      return DataSuccess(await _assignmentsOf(modelId));
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<ModelFernieEntity>> assignFernie({
    required int modelId,
    required int fernieId,
  }) async {
    try {
      final model = await _database.recognitionModelModels.get(modelId);
      if (model == null) {
        return DataException(Exception('Modelo $modelId no existe'));
      }

      final fernie = await _database.fernieModels.get(fernieId);
      if (fernie == null) {
        return DataException(Exception('Fernie $fernieId no existe'));
      }

      final existing = await _database.modelFernieModels
          .filter()
          .model((query) => query.idEqualTo(modelId))
          .fernie((query) => query.idEqualTo(fernieId))
          .findFirst();

      // Ya estaba: un fernie no puede ser dos clases del mismo modelo.
      if (existing != null) return DataSuccess(await _toAssignment(existing));

      final row = ModelFernieModel()..classIndex = await _nextClassIndex(modelId);

      await _database.writeTxn(() async {
        await _database.modelFernieModels.put(row);
        row.model.value = model;
        row.fernie.value = fernie;
        await row.model.save();
        await row.fernie.save();
      });

      return DataSuccess(await _toAssignment(row));
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<bool>> removeFernie(int assignmentId) async {
    try {
      await _database.writeTxn(
        () => _database.modelFernieModels.delete(assignmentId),
      );

      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<ModelFernieEntity>> updateSplit({
    required int assignmentId,
    required DatasetSplit split,
  }) async {
    try {
      if (!split.isValid) {
        return DataException(
          Exception('El reparto tiene que sumar 100 y no llevar negativos'),
        );
      }

      final row = await _database.modelFernieModels.get(assignmentId);
      if (row == null) {
        return DataException(Exception('Asignación $assignmentId no existe'));
      }

      await _database.writeTxn(() async {
        row
          ..trainPercent = split.train
          ..valPercent = split.validation
          ..testPercent = split.test;

        await _database.modelFernieModels.put(row);
      });

      return DataSuccess(await _toAssignment(row));
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Entrenamiento
  // ---------------------------------------------------------------------------

  @override
  Future<DataState<bool>> setTraining({
    required int modelId,
    required bool isTraining,
  }) async {
    try {
      await _database.writeTxn(() async {
        final row = await _database.recognitionModelModels.get(modelId);
        if (row == null) return;

        row.isTraining = isTraining;

        // Volver a intentarlo borra el fallo anterior. Dejarlo puesto mientras
        // corre el nuevo deja la pantalla diciendo que se rompió justo cuando
        // se está entrenando otra vez, y el usuario no sabe si el mensaje es de
        // antes o de ahora.
        if (isTraining) row.lastError = null;

        await _database.recognitionModelModels.put(row);
      });

      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<RecognitionModelEntity>> saveTrainingResult({
    required int modelId,
    String? weightsPath,
    String? metrics,
    String? error,
  }) async {
    try {
      await _database.writeTxn(() async {
        final row = await _database.recognitionModelModels.get(modelId);
        if (row == null) return;

        row
          ..isTraining = false
          ..lastError = error;

        // Un entrenamiento roto no se lleva por delante el que funcionaba: los
        // pesos y las métricas viejos se quedan hasta que otro los sustituya.
        if (error == null) {
          row
            ..weightsPath = weightsPath ?? row.weightsPath
            ..lastMetrics = metrics ?? row.lastMetrics
            ..lastTrainedAt = DateTime.now()
            ..isImportedWeights = false;
        }

        await _database.recognitionModelModels.put(row);
      });

      return getModel(modelId);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<int>> clearStaleTrainingFlags() async {
    try {
      final stuck = await _database.recognitionModelModels
          .filter()
          .isTrainingEqualTo(true)
          .findAll();

      if (stuck.isEmpty) return const DataSuccess(0);

      await _database.writeTxn(() async {
        for (final row in stuck) {
          row.isTraining = false;
        }

        await _database.recognitionModelModels.putAll(stuck);
      });

      return DataSuccess(stuck.length);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Auxiliares
  // ---------------------------------------------------------------------------

  /// El siguiente número de clase libre.
  ///
  /// Es el mayor que haya más uno, **no** cuántos fernies hay: los números de
  /// los que se quitaron dejan huecos y esos huecos no se rellenan, porque los
  /// pesos entrenados los conocían por su número.
  Future<int> _nextClassIndex(int modelId) async {
    final rows = await _database.modelFernieModels
        .filter()
        .model((query) => query.idEqualTo(modelId))
        .findAll();

    var highest = -1;
    for (final row in rows) {
      if (row.classIndex > highest) highest = row.classIndex;
    }

    return highest + 1;
  }

  Future<List<ModelFernieEntity>> _assignmentsOf(int modelId) async {
    final rows = await _database.modelFernieModels
        .filter()
        .model((query) => query.idEqualTo(modelId))
        .findAll();

    rows.sort((a, b) => a.classIndex.compareTo(b.classIndex));

    return [for (final row in rows) await _toAssignment(row)];
  }

  Future<ModelFernieEntity> _toAssignment(ModelFernieModel row) async {
    await row.fernie.load();
    await row.model.load();

    final fernie = row.fernie.value;

    return ModelFernieEntity(
      id: row.id,
      modelId: row.model.value?.id ?? 0,
      fernie: fernie == null
          ? FernieEntity(id: 0, name: '')
          : fernie.toEntity(
              regionCount: await _regionCountOf(fernie),
              mediaCount: await _mediaCountOf(fernie),
            ),
      split: DatasetSplit(
        train: row.trainPercent,
        validation: row.valPercent,
        test: row.testPercent,
      ),
      classIndex: row.classIndex,
    );
  }

  Future<RecognitionModelEntity> _toEntity(RecognitionModelModel model) async {
    final assignments = await _assignmentsOf(model.id);

    var regions = 0;
    for (final assignment in assignments) {
      regions += assignment.fernie.regionCount;
    }

    return model.toEntity(
      fernieCount: assignments.length,
      regionCount: regions,
    );
  }

  Future<int> _regionCountOf(FernieModel fernie) async {
    await fernie.regions.load();
    return fernie.regions.length;
  }

  /// Sobre cuántos contenidos distintos está marcado.
  ///
  /// Hace falta además del número de regiones: cien regiones de un solo fichero
  /// enseñan el fondo, no el objeto, y de eso avisa la pantalla del modelo.
  Future<int> _mediaCountOf(FernieModel fernie) async {
    await fernie.regions.load();

    return {for (final region in fernie.regions) region.mediaId}.length;
  }
}
