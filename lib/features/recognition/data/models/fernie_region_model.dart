import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:isar/isar.dart';

part 'fernie_region_model.g.dart';

/// Una región marcada, tal y como se guarda.
///
/// No se guarda ningún recorte en disco: con las coordenadas normalizadas y el
/// fichero original se puede recortar al vuelo para enseñarlo y montar el
/// conjunto de datos al entrenar. Guardar píxeles obligaría además a
/// sincronizar los borrados, y a YOLO le hace falta la imagen entera con su caja
/// dentro, no el recorte.
///
/// El índice por [mediaId] no es opcional: abrir un contenido pregunta por sus
/// regiones, y eso pasa cada vez que se entra al visor.
@collection
@Name("FernieRegions")
class FernieRegionModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int mediaId;

  final fernie = IsarLink<FernieModel>();

  late double x;
  late double y;
  late double w;
  late double h;

  /// Milisegundo del fotograma en vídeo y GIF. `null` en imágenes estáticas.
  int? frameMs;

  DateTime createdAt = DateTime.now();

  FernieRegionModel();

  /// El fernie no se enlaza aquí: enlazar es una escritura y tiene que pasar
  /// dentro de la transacción que guarda la región.
  factory FernieRegionModel.fromEntity(FernieRegionEntity entity) {
    return FernieRegionModel()
      ..id = entity.id == unsavedId ? Isar.autoIncrement : entity.id
      ..mediaId = entity.mediaId
      ..x = entity.x
      ..y = entity.y
      ..w = entity.w
      ..h = entity.h
      ..frameMs = entity.frameMs
      ..createdAt = entity.createdAt;
  }

  FernieRegionEntity toEntity({int? fernieId}) {
    return FernieRegionEntity(
      id: id,
      mediaId: mediaId,
      fernieId: fernieId ?? fernie.value?.id ?? unsavedId,
      x: x,
      y: y,
      w: w,
      h: h,
      frameMs: frameMs,
      createdAt: createdAt,
    );
  }
}
