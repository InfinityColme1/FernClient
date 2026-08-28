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

  /// El fernie está marcado como no apto.
  ///
  /// Es la misma marca que llevan las etiquetas y el contenido, y está por lo
  /// mismo: sin ella, lo que se hubiera marcado en la biblioteca volvía a verse
  /// aquí en cuanto alguien recortaba una región sobre ello.
  ///
  /// Lo que esconde es **al fernie**, no lo que el fernie sabe: marcado sigue
  /// entrenando y sigue proponiendo igual que antes, simplemente no se enseña.
  bool isNsfw = false;

  DateTime createdAt = DateTime.now();

  @Backlink(to: 'fernie')
  final regions = IsarLinks<FernieRegionModel>();

  FernieModel();

  /// Los cuatro recuentos los cuenta el repositorio: no están en la fila, salen
  /// de contar las regiones enlazadas. Los de «utilizable» necesitan además
  /// mirar si el contenido de cada región ya es definitivo, que es lo único que
  /// distingue una región que entrena de una que espera.
  FernieEntity toEntity({
    int regionCount = 0,
    int mediaCount = 0,
    int? usableRegionCount,
    int? usableMediaCount,
    String? linkedName,
  }) {
    return FernieEntity(
      id: id,
      name: name,
      picturePath: picturePath,
      linkedTagId: linkedTagId,
      linkedCreatorId: linkedCreatorId,
      linkedName: linkedName,
      isNsfw: isNsfw,
      createdAt: createdAt,
      regionCount: regionCount,
      mediaCount: mediaCount,
      usableRegionCount: usableRegionCount,
      usableMediaCount: usableMediaCount,
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
      ..isNsfw = entity.isNsfw
      ..createdAt = entity.createdAt;
  }
}
