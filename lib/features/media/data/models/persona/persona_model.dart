import 'package:Fern/features/media/domain/entities/persona/persona_entity.dart';
import 'package:isar/isar.dart';

import '../tag_model.dart';

part 'persona_model.g.dart';

@collection
@Name("Personas")
class PersonaModel {

  Id id = Isar.autoIncrement;

  late String name;

  String ? picturePath;

  final tags = IsarLinks<TagModel>();

  PersonaModel({
    required this.id,
    required this.name,
    this.picturePath,
  });

  PersonaEntity toEntity() {
    return PersonaEntity(
        id: id,
        name: name,
        picturePath: picturePath,
    );
  }

  factory PersonaModel.fromEntity(PersonaEntity entity) {
    return PersonaModel(
        id: entity.id,
        name: entity.name,
        picturePath: entity.picturePath,
    );
  }
}