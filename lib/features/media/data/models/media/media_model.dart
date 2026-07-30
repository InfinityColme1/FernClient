import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:isar/isar.dart';

import '../persona/creator_model.dart';
import '../tag_model.dart';

part 'media_model.g.dart';

@collection
@Name("Media")
class MediaModel {

  Id? id = Isar.autoIncrement;

  late String path;

  late DateTime downloaded;

  late bool isFavorite;

  final creator = IsarLink<CreatorModel>();

  final tags = IsarLinks<TagModel>();

  final source = IsarLink<TagModel>();

  MediaModel({this.id, required this.path});


  MediaEntity toEntity() {
    return MediaEntity(
      id: id!,
      path: path,
      downloaded: downloaded,
      isFavorite: isFavorite,
      creator: creator.value!.toEntity(),
      tags: tags.map((tag) {return tag.toEntity();}).toList(),
      source: source.value!.toEntity(),
    );
  }

  factory MediaModel.fromEntity(MediaEntity entity) {
    final model = MediaModel(
        id: entity.id,
        path: entity.path
    );
    model.downloaded = entity.downloaded;
    model.isFavorite = entity.isFavorite;
    // Note: Links should be handled in the repository/mapper context
    // because they require fetching or creating related models in Isar.
    return model;
  }
}
