import 'package:equatable/equatable.dart';

/// Qué pregunta responde un modelo.
///
/// Los dos son detección con YOLO: lo que cambia es cuántas cosas distintas
/// aprende a distinguir y, con ello, el preset con el que se entrena y cómo se
/// lee su salida.
enum ModelFunction {
  /// ¿Está esta característica en el contenido? Con varios fernies contesta lo
  /// mismo para cada uno, por separado.
  boolean(id: 'boolean'),

  /// ¿Cuál de estas características está, y dónde?
  classification(id: 'classification');

  const ModelFunction({required this.id});

  final String id;

  static ModelFunction fromId(String? id) => ModelFunction.values.firstWhere(
        (function) => function.id == id,
        orElse: () => ModelFunction.boolean,
      );
}

/// Con cuánto esmero se entrena.
///
/// Es lo que le ahorra al usuario tener que saber qué es un backbone. Cada uno
/// rellena los hiperparámetros; tocar cualquiera de ellos a mano pasa el preset
/// a [custom], que no rellena nada porque ya lo ha rellenado el usuario.
enum TrainingPreset {
  fast(id: 'fast'),
  balanced(id: 'balanced'),
  accurate(id: 'accurate'),
  custom(id: 'custom');

  const TrainingPreset({required this.id});

  final String id;

  static TrainingPreset fromId(String? id) => TrainingPreset.values.firstWhere(
        (preset) => preset.id == id,
        orElse: () => TrainingPreset.balanced,
      );
}

/// En qué punto está un modelo, que es lo que dice su tarjeta de un vistazo.
enum ModelTrainingStatus {
  /// Nunca se ha entrenado: no hay pesos con los que reconocer nada.
  untrained,

  /// Entrenándose ahora mismo.
  training,

  /// Entrenado y listo para usarse.
  ready,

  /// El último entrenamiento se rompió. Sigue habiendo pesos viejos si alguna
  /// vez llegó a terminar uno.
  failed,
}

/// Un modelo de reconocimiento tal y como lo ve la interfaz.
///
/// Es un nombre, una cara, una función y un puñado de fernies. Lo demás
/// —backbone, épocas, tamaño de imagen— son los mandos del entrenamiento, que
/// el preset rellena solo y casi nadie tiene por qué tocar.
class RecognitionModelEntity extends Equatable {
  final int id;
  final String name;
  final String? picturePath;

  final ModelFunction function;
  final TrainingPreset preset;

  /// Los mandos del entrenamiento, ya resueltos. Se rellenan desde el preset y
  /// el usuario puede sobrescribirlos.
  final String backbone;
  final int epochs;
  final int imgsz;

  /// `-1` deja que ultralytics elija según la memoria que haya libre.
  final int batch;

  /// Ruta del `.pt` entrenado, o `null` mientras no se haya entrenado nunca.
  final String? weightsPath;

  /// A partir de qué confianza se da por buena una detección.
  final double confidenceThreshold;

  final DateTime? lastTrainedAt;

  /// Las métricas del último entrenamiento, tal y como las devolvió el sidecar.
  ///
  /// Se guardan **en crudo** a propósito: son suyas, cambian con la versión de
  /// ultralytics, y desmontarlas en columnas obligaría a migrar la base de datos
  /// cada vez que añadan una.
  final String? lastMetrics;

  /// Qué se rompió en el último entrenamiento, o `null` si terminó bien.
  ///
  /// Se guarda porque la cola de trabajos se vacía y la pantalla del modelo
  /// tiene que poder decir qué pasó al día siguiente.
  final String? lastError;

  /// Hay un entrenamiento en marcha. Impide arrancar otro del mismo modelo.
  final bool isTraining;

  /// Los pesos vienen de fuera en vez de haberse entrenado aquí.
  final bool isImportedWeights;

  final DateTime createdAt;

  /// Cuántos fernies tiene asignados y cuántas regiones suman entre todos.
  ///
  /// Los cuenta el repositorio: no son columnas, salen de contar lo enlazado.
  final int fernieCount;
  final int regionCount;

  const RecognitionModelEntity({
    required this.id,
    required this.name,
    this.picturePath,
    this.function = ModelFunction.boolean,
    this.preset = TrainingPreset.balanced,
    this.backbone = defaultBackbone,
    this.epochs = defaultEpochs,
    this.imgsz = defaultImageSize,
    this.batch = autoBatch,
    this.weightsPath,
    this.confidenceThreshold = defaultConfidenceThreshold,
    this.lastTrainedAt,
    this.lastMetrics,
    this.lastError,
    this.isTraining = false,
    this.isImportedWeights = false,
    required this.createdAt,
    this.fernieCount = 0,
    this.regionCount = 0,
  });

  /// Los valores de fábrica de un modelo recién creado. Van aquí y no sueltos
  /// por ahí porque son los mismos que rellena el preset equilibrado.
  static const defaultBackbone = 'yolo11n.pt';
  static const defaultEpochs = 100;
  static const defaultImageSize = 640;
  static const autoBatch = -1;
  static const defaultConfidenceThreshold = 0.35;

  /// La función con la que de verdad se va a entrenar.
  ///
  /// **Clasificar entre una sola opción no es clasificar.** Un modelo
  /// clasificatorio con un fernie o ninguno se comporta como booleano: contesta
  /// si esa característica está. La interfaz lo avisa en vez de callarlo, y el
  /// repositorio lo deja escrito al guardar, para que lo que se ve y lo que se
  /// entrena sean lo mismo.
  ModelFunction get effectiveFunction =>
      function == ModelFunction.classification && fernieCount < 2
          ? ModelFunction.boolean
          : function;

  /// Si lo que se ve en pantalla no es lo que el usuario eligió, porque no hay
  /// entre qué clasificar.
  bool get isDegraded => effectiveFunction != function;

  ModelTrainingStatus get status {
    if (isTraining) return ModelTrainingStatus.training;
    if (lastError != null) return ModelTrainingStatus.failed;

    return weightsPath == null
        ? ModelTrainingStatus.untrained
        : ModelTrainingStatus.ready;
  }

  /// Si tiene pesos con los que reconocer algo.
  bool get isUsable => weightsPath != null;

  RecognitionModelEntity copyWith({
    int? id,
    String? name,
    String? picturePath,
    ModelFunction? function,
    TrainingPreset? preset,
    String? backbone,
    int? epochs,
    int? imgsz,
    int? batch,
    String? weightsPath,
    double? confidenceThreshold,
    DateTime? lastTrainedAt,
    String? lastMetrics,
    bool? isTraining,
    bool? isImportedWeights,
    int? fernieCount,
    int? regionCount,
    // El error del último entrenamiento no se arrastra con el `??` de siempre:
    // limpiarlo (porque el siguiente ha ido bien) es tan normal como ponerlo, y
    // con aquél no habría forma de dejarlo en nada.
    String? lastError,
    // Las métricas sí se arrastran con `??`, porque casi siempre lo que se toca
    // es otra cosa. Pero unos pesos traídos de fuera **no tienen** métricas, y
    // dejar las del entrenamiento anterior diría que ese `.pt` acierta un 0,83
    // sin que nadie lo haya medido.
    bool clearMetrics = false,
  }) {
    return RecognitionModelEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      picturePath: picturePath ?? this.picturePath,
      function: function ?? this.function,
      preset: preset ?? this.preset,
      backbone: backbone ?? this.backbone,
      epochs: epochs ?? this.epochs,
      imgsz: imgsz ?? this.imgsz,
      batch: batch ?? this.batch,
      weightsPath: weightsPath ?? this.weightsPath,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      lastTrainedAt: lastTrainedAt ?? this.lastTrainedAt,
      lastMetrics: clearMetrics ? null : (lastMetrics ?? this.lastMetrics),
      lastError: lastError,
      isTraining: isTraining ?? this.isTraining,
      isImportedWeights: isImportedWeights ?? this.isImportedWeights,
      createdAt: createdAt,
      fernieCount: fernieCount ?? this.fernieCount,
      regionCount: regionCount ?? this.regionCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        picturePath,
        function,
        preset,
        backbone,
        epochs,
        imgsz,
        batch,
        weightsPath,
        confidenceThreshold,
        lastTrainedAt,
        lastMetrics,
        lastError,
        isTraining,
        isImportedWeights,
        fernieCount,
        regionCount,
      ];
}
