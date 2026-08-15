import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:isar/isar.dart';

import 'media/media_model.dart';

part 'tag_model.g.dart';

@collection
@Name("Tags")
class TagModel {

  Id id = Isar.autoIncrement;

  late String name;

  String ? picturePath;

  /// Direcciones de las que sale contenido que lleva esta etiqueta, ya
  /// normalizadas. Es lo que mira el etiquetado automático al importar.
  List<String> sourceUrls = const [];

  final children = IsarLinks<TagModel>();
  
  @Backlink(to: 'tags')
  final personas = IsarLinks<PersonaModel>();

  @Backlink(to: 'tags')
  final media = IsarLinks<MediaModel>();

  
  TagModel({
    required this.id,
    required this.name,
    this.picturePath,
    this.sourceUrls = const [],
  });

  TagEntity toEntity() {
    return TagEntity(
      id: id,
      name: name,
      picturePath: picturePath,
      sourceUrls: sourceUrls,
      children: children.map((tag) {return tag.toEntity();}).toList(),
    );
  }

  /// Una etiqueta recién creada llega con [unsavedId]; en ese caso se deja que
  /// Isar le asigne el identificador, o todas se escribirían sobre la misma
  /// fila.
  factory TagModel.fromEntity(TagEntity entity) {
    return TagModel(
      id: entity.id == unsavedId ? Isar.autoIncrement : entity.id,
      picturePath: entity.picturePath,
      name: entity.name,
      sourceUrls: entity.sourceUrls,
    );
  }
}