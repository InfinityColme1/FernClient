import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:isar/isar.dart';

part 'recognition_result_model.g.dart';

/// Lo que un modelo propone sobre un contenido, tal y como se guarda.
///
/// Es una **propuesta**, no una etiqueta: hasta que el usuario la acepta no
/// cambia nada del contenido. Por eso vive aquí y no en las etiquetas del
/// contenido, que es donde acaba sólo si se acepta.
///
/// El índice por [mediaId] no es opcional: abrir un contenido pregunta por sus
/// sugerencias, y eso pasa cada vez que se entra al visor o a la ficha.
@collection
@Name("RecognitionResults")
class RecognitionResultModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int mediaId;

  /// Quién lo propuso. Hace falta para el rendimiento real: cuántas de las
  /// propuestas de **ese** modelo se aceptan.
  @Index()
  late int modelId;

  late int fernieId;

  late double confidence;

  /// Dónde se vio, normalizado. Falta en los modelos booleanos, que dicen que
  /// algo está pero no dónde.
  double? x;
  double? y;
  double? w;
  double? h;

  /// En qué momento del vídeo. `null` en imágenes.
  int? frameMs;

  /// Sin revisar, aceptada o rechazada.
  ///
  /// Indexado porque la pantalla de importación filtra por «tiene sugerencias
  /// sin mirar», y eso es una consulta por este campo.
  @Index()
  @Enumerated(EnumType.name)
  SuggestionStatus status = SuggestionStatus.suggested;

  DateTime createdAt = DateTime.now();

  RecognitionResultModel();

  factory RecognitionResultModel.fromEntity(RecognitionResultEntity entity) {
    return RecognitionResultModel()
      ..id = entity.id == unsavedId ? Isar.autoIncrement : entity.id
      ..mediaId = entity.mediaId
      ..modelId = entity.modelId
      ..fernieId = entity.fernieId
      ..confidence = entity.confidence
      ..x = entity.x
      ..y = entity.y
      ..w = entity.w
      ..h = entity.h
      ..frameMs = entity.frameMs
      ..status = entity.status
      ..createdAt = entity.createdAt;
  }

  RecognitionResultEntity toEntity() {
    return RecognitionResultEntity(
      id: id,
      mediaId: mediaId,
      modelId: modelId,
      fernieId: fernieId,
      confidence: confidence,
      x: x,
      y: y,
      w: w,
      h: h,
      frameMs: frameMs,
      status: status,
      createdAt: createdAt,
    );
  }
}
