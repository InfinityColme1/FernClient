import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:isar/isar.dart';

part 'creator_model.g.dart';

@collection
@Name("Creators")
class CreatorModel {

  Id id = Isar.autoIncrement;

  late String name;

  String ? picturePath;

  List<String> ? socialProfiles;

  /// Direcciones vinculadas con el creador, ya normalizadas: lo que se importe
  /// de debajo de alguna de ellas nace con este creador puesto.
  List<String> sourceUrls = const [];

  CreatorModel({
    required this.id,
    required this.name,
    this.picturePath,
    this.socialProfiles,
    this.sourceUrls = const []
  });

  CreatorEntity toEntity() {
    return CreatorEntity(
        id: id,
        name: name,
        picturePath: picturePath,
        socialProfiles: socialProfiles,
        sourceUrls: sourceUrls
    );
  }

  /// Un creador recién creado llega con [unsavedId]; en ese caso se deja que
  /// Isar le asigne el identificador, o todos se escribirían sobre la misma
  /// fila.
  factory CreatorModel.fromEntity(CreatorEntity entity) {
    return CreatorModel(
        id: entity.id == unsavedId ? Isar.autoIncrement : entity.id,
        name: entity.name,
        picturePath: entity.picturePath,
        socialProfiles: entity.socialProfiles,
        sourceUrls: entity.sourceUrls
    );
  }
}
