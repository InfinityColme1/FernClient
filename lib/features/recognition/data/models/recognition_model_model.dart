import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/data/models/model_fernie_model.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:isar/isar.dart';

part 'recognition_model_model.g.dart';

/// Un modelo de reconocimiento tal y como se guarda.
///
/// Los hiperparámetros viven aquí desplegados y no como un JSON: son cinco
/// números que la pantalla de detalle enseña y deja tocar uno a uno, y un JSON
/// obligaría a desmontarlo y volverlo a montar en cada pulsación.
///
/// Las métricas del último entrenamiento sí van en crudo: son del sidecar,
/// cambian con la versión de ultralytics, y darles columnas propias obligaría a
/// migrar la base de datos cada vez que añadan una.
@collection
@Name("RecognitionModels")
class RecognitionModelModel {
  Id id = Isar.autoIncrement;

  late String name;

  /// Avatar, en la carpeta que gestiona `AvatarStorageService`.
  String? picturePath;

  @Enumerated(EnumType.name)
  ModelFunction function = ModelFunction.boolean;

  @Enumerated(EnumType.name)
  TrainingPreset preset = TrainingPreset.balanced;

  String backbone = RecognitionModelEntity.defaultBackbone;
  int epochs = RecognitionModelEntity.defaultEpochs;
  int imgsz = RecognitionModelEntity.defaultImageSize;
  int batch = RecognitionModelEntity.autoBatch;

  String? weightsPath;

  double confidenceThreshold = RecognitionModelEntity.defaultConfidenceThreshold;

  DateTime? lastTrainedAt;
  String? lastMetrics;
  String? lastError;

  /// Marcado mientras hay un entrenamiento en curso.
  ///
  /// Se limpia al arrancar la aplicación: si el equipo se apagó a media faena,
  /// esta marca se habría quedado puesta para siempre y el modelo no se dejaría
  /// entrenar nunca más.
  bool isTraining = false;

  bool isImportedWeights = false;

  /// El modelo está marcado como no apto.
  ///
  /// Sólo afecta a lo que se ve: el árbol lo sigue ejecutando y el
  /// entrenamiento lo sigue tocando, porque quien lee para trabajar lo hace por
  /// el repositorio y no por los casos de uso, que son los que filtran.
  bool isNsfw = false;

  DateTime createdAt = DateTime.now();

  @Backlink(to: 'model')
  final fernies = IsarLinks<ModelFernieModel>();

  RecognitionModelModel();

  /// [fernieCount] y [regionCount] los cuenta el repositorio: no son columnas,
  /// salen de contar lo enlazado.
  RecognitionModelEntity toEntity({
    int fernieCount = 0,
    int regionCount = 0,
  }) {
    return RecognitionModelEntity(
      id: id,
      name: name,
      picturePath: picturePath,
      function: function,
      preset: preset,
      backbone: backbone,
      epochs: epochs,
      imgsz: imgsz,
      batch: batch,
      weightsPath: weightsPath,
      confidenceThreshold: confidenceThreshold,
      lastTrainedAt: lastTrainedAt,
      lastMetrics: lastMetrics,
      lastError: lastError,
      isTraining: isTraining,
      isImportedWeights: isImportedWeights,
      isNsfw: isNsfw,
      createdAt: createdAt,
      fernieCount: fernieCount,
      regionCount: regionCount,
    );
  }

  /// Un modelo recién creado llega con [unsavedId]; en ese caso se deja que Isar
  /// le asigne el identificador, o todos se escribirían sobre la misma fila.
  factory RecognitionModelModel.fromEntity(RecognitionModelEntity entity) {
    return RecognitionModelModel()
      ..id = entity.id == unsavedId ? Isar.autoIncrement : entity.id
      ..name = entity.name
      ..picturePath = entity.picturePath
      ..function = entity.function
      ..preset = entity.preset
      ..backbone = entity.backbone
      ..epochs = entity.epochs
      ..imgsz = entity.imgsz
      ..batch = entity.batch
      ..weightsPath = entity.weightsPath
      ..confidenceThreshold = entity.confidenceThreshold
      ..lastTrainedAt = entity.lastTrainedAt
      ..lastMetrics = entity.lastMetrics
      ..lastError = entity.lastError
      ..isTraining = entity.isTraining
      ..isImportedWeights = entity.isImportedWeights
      ..isNsfw = entity.isNsfw
      ..createdAt = entity.createdAt;
  }
}
