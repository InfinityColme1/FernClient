import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:isar/isar.dart';

part 'fernie_model.g.dart';

/// Un fernie tal y como se guarda.
///
/// La etiqueta y el creador enlazados se guardan como identificador suelto y no
/// como `IsarLink`: el enlace es opcional y excluyente, y así listar los fernies
/// no arrastra la etiqueta entera de cada uno. Que la etiqueta enlazada
/// desaparezca deja el campo apuntando a nada, que es exactamente lo que se
/// quiere: el fernie sigue existiendo y sus regiones también, sólo deja de
/// proponer nada.
@collection
@Name("Fernies")
class FernieModel {
  Id id = Isar.autoIncrement;

  late String name;

  /// Avatar, en la carpeta que gestiona `AvatarStorageService`.
  String? picturePath;

  int? linkedTagId;

  int? linkedCreatorId;

  DateTime createdAt = DateTime.now();

  @Backlink(to: 'fernie')
  final regions = IsarLinks<FernieRegionModel>();

  FernieModel();

  /// [regionCount] y [mediaCount] los cuenta el repositorio: no están en la
  /// fila, salen de contar las regiones enlazadas.
  FernieEntity toEntity({
    int regionCount = 0,
    int mediaCount = 0,
    String? linkedName,
  }) {
    return FernieEntity(
      id: id,
      name: name,
      picturePath: picturePath,
      linkedTagId: linkedTagId,
      linkedCreatorId: linkedCreatorId,
      linkedName: linkedName,
      createdAt: createdAt,
      regionCount: regionCount,
      mediaCount: mediaCount,
    );
  }

  /// Un fernie recién creado llega con [unsavedId]; en ese caso se deja que Isar
  /// le asigne el identificador, o todos se escribirían sobre la misma fila.
  factory FernieModel.fromEntity(FernieEntity entity) {
    return FernieModel()
      ..id = entity.id == unsavedId ? Isar.autoIncrement : entity.id
      ..name = entity.name
      ..picturePath = entity.picturePath
      ..linkedTagId = entity.linkedTagId
      ..linkedCreatorId = entity.linkedCreatorId
      ..createdAt = entity.createdAt;
  }
}
