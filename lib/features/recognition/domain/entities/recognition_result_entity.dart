import 'package:Fern/core/constants/app_constants.dart';
import 'package:equatable/equatable.dart';

/// En qué estado está una sugerencia.
///
/// Las tres importan y ninguna se puede tirar: `suggested` es lo que hay que
/// revisar, y las otras dos son **la única medida honesta** de si un modelo
/// sirve —cuántas de sus propuestas se aceptan y cuántas se rechazan—, que es lo
/// que la pantalla del modelo enseña como rendimiento real.
enum SuggestionStatus { suggested, accepted, rejected }

/// Lo que un modelo propone sobre un contenido.
///
/// Es una **propuesta**, no una etiqueta: hasta que el usuario la acepta no
/// cambia nada del contenido. Reconocer y etiquetar son dos cosas, y mezclarlas
/// haría que un modelo a medio entrenar ensuciara la biblioteca sin que nadie lo
/// hubiera mirado.
class RecognitionResultEntity extends Equatable {
  final int id;

  final int mediaId;
  final int modelId;
  final int fernieId;

  final double confidence;

  /// Dónde se vio, en coordenadas normalizadas. Sirve para dibujar la caja al
  /// revisar la sugerencia y como semilla para crear una región de un clic.
  ///
  /// Puede faltar: un modelo booleano dice que algo está, no dónde.
  final double? x;
  final double? y;
  final double? w;
  final double? h;

  /// En qué momento del vídeo se vio. `null` en imágenes.
  final int? frameMs;

  final SuggestionStatus status;
  final DateTime createdAt;

  const RecognitionResultEntity({
    this.id = unsavedId,
    required this.mediaId,
    required this.modelId,
    required this.fernieId,
    required this.confidence,
    this.x,
    this.y,
    this.w,
    this.h,
    this.frameMs,
    this.status = SuggestionStatus.suggested,
    required this.createdAt,
  });

  /// Si trae caja, y por tanto se puede pintar sobre el contenido.
  bool get hasBox => x != null && y != null && w != null && h != null;

  RecognitionResultEntity copyWith({
    int? id,
    SuggestionStatus? status,
  }) {
    return RecognitionResultEntity(
      id: id ?? this.id,
      mediaId: mediaId,
      modelId: modelId,
      fernieId: fernieId,
      confidence: confidence,
      x: x,
      y: y,
      w: w,
      h: h,
      frameMs: frameMs,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        mediaId,
        modelId,
        fernieId,
        confidence,
        x,
        y,
        w,
        h,
        frameMs,
        status,
        createdAt,
      ];
}
