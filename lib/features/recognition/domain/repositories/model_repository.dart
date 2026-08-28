import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';

/// Los modelos de reconocimiento y los fernies que cada uno aprende.
abstract class ModelRepository {
  Future<DataState<List<RecognitionModelEntity>>> getModels();

  Future<DataState<RecognitionModelEntity>> getModel(int id);

  /// Crea o actualiza. Devuelve el modelo tal y como ha quedado, con el
  /// identificador puesto si era nuevo y con la función ya degradada si no hay
  /// entre qué clasificar.
  Future<DataState<RecognitionModelEntity>> saveModel(
    RecognitionModelEntity model,
  );

  /// Borra el modelo y con él sus fernies asignados. **No borra los fernies**:
  /// son suyos, no del modelo, y siguen valiendo para otros.
  Future<DataState<bool>> deleteModel(int id);

  /// Marca o desmarca el modelo como no apto.
  ///
  /// Va aparte de [saveModel] porque se escribe al tocar el interruptor, sin
  /// esperar al botón de guardar: dejarla a medias —marcada en pantalla, sin
  /// marcar en la base de datos— sería la peor forma de contarlo.
  ///
  /// **No cambia nada de lo que el modelo hace.** Se sigue entrenando y el
  /// árbol lo sigue ejecutando; lo único que cambia es que deja de verse.
  Future<DataState<bool>> setModelNsfw(int id, {required bool isNsfw});

  // ---------------------------------------------------------------------------
  // Fernies del modelo
  // ---------------------------------------------------------------------------

  Future<DataState<List<ModelFernieEntity>>> getFerniesOfModel(int modelId);

  /// Mete un fernie en el modelo, con el reparto de fábrica y el siguiente
  /// número de clase libre.
  ///
  /// Meter uno que ya estaba no hace nada: un fernie no puede ser dos clases del
  /// mismo modelo.
  Future<DataState<ModelFernieEntity>> assignFernie({
    required int modelId,
    required int fernieId,
  });

  /// Saca un fernie del modelo. Su número de clase **queda libre pero no se
  /// reutiliza ni se reindexa**: los pesos entrenados lo conocían por ese
  /// número.
  Future<DataState<bool>> removeFernie(int assignmentId);

  Future<DataState<ModelFernieEntity>> updateSplit({
    required int assignmentId,
    required DatasetSplit split,
  });

  // ---------------------------------------------------------------------------
  // Entrenamiento
  // ---------------------------------------------------------------------------

  /// Marca o desmarca que el modelo se está entrenando.
  Future<DataState<bool>> setTraining({
    required int modelId,
    required bool isTraining,
  });

  /// Deja constancia de cómo acabó el último entrenamiento.
  ///
  /// Con [error] se guarda el fallo y se conservan los pesos viejos, si los
  /// había: un entrenamiento roto no invalida el que funcionaba.
  Future<DataState<RecognitionModelEntity>> saveTrainingResult({
    required int modelId,
    String? weightsPath,
    String? metrics,
    String? error,
  });

  /// Limpia las marcas de entrenamiento que se hayan quedado colgadas.
  ///
  /// Se llama al arrancar: si el equipo se apagó a media faena, esos modelos se
  /// habrían quedado marcados para siempre y no se dejarían entrenar nunca más.
  /// Devuelve cuántos ha desatascado.
  Future<DataState<int>> clearStaleTrainingFlags();
}
