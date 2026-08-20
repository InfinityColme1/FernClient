import 'package:equatable/equatable.dart';

/// Un rectángulo marcado sobre un contenido concreto y asignado a un fernie.
///
/// Las coordenadas van **normalizadas** (0..1) y con el origen en la esquina
/// superior izquierda: así la región sigue valiendo aunque el fichero se
/// reescale, se abra en otra ventana o se mire con zoom. La conversión al
/// formato que espera ultralytics (centro + tamaño) se hace al generar el
/// conjunto de datos, en un solo sitio.
class FernieRegionEntity extends Equatable {
  final int id;

  /// Contenido sobre el que está marcada, con el identificador que tiene en la
  /// biblioteca (el mismo de `MediaSummaryEntity`).
  final int mediaId;

  /// Fernie al que pertenece. Es [unsavedId] mientras la región todavía no se
  /// ha guardado y no se sabe a cuál va a ir.
  final int fernieId;

  final double x;
  final double y;
  final double w;
  final double h;

  /// Milisegundo del fotograma en vídeo y GIF. `null` en imágenes estáticas.
  final int? frameMs;

  final DateTime createdAt;

  FernieRegionEntity({
    required this.id,
    required this.mediaId,
    required this.fernieId,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.frameMs,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Qué parte del contenido ocupa la región, de 0 a 1.
  ///
  /// Lo mira el aviso de "región muy pequeña": por debajo de un porcentaje
  /// mínimo el recorte no le dice gran cosa al entrenamiento.
  double get area => w * h;

  FernieRegionEntity copyWith({
    int? id,
    int? mediaId,
    int? fernieId,
    double? x,
    double? y,
    double? w,
    double? h,
    int? frameMs,
  }) {
    return FernieRegionEntity(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      fernieId: fernieId ?? this.fernieId,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      frameMs: frameMs ?? this.frameMs,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, mediaId, fernieId, x, y, w, h, frameMs];
}
