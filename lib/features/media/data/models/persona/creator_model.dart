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

  CreatorModel({
    required this.id,
    required this.name,
    this.picturePath,
    this.socialProfiles
  });

  CreatorEntity toEntity() {
    return CreatorEntity(
        id: id,
        name: name,
        picturePath: picturePath,
        socialProfiles: socialProfiles
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
        socialProfiles: entity.socialProfiles
    );
  }
}