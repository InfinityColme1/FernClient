import 'package:Fern/core/constants/app_constants.dart';
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

  String? description;

  final creator = IsarLink<CreatorModel>();

  final tags = IsarLinks<TagModel>();

  final source = IsarLink<TagModel>();

  MediaModel({this.id, required this.path});


  /// [isImported] vive en el sumario, así que se pasa desde el repositorio.
  ///
  /// Los enlaces son perezosos en Isar: hay que haberlos cargado antes de
  /// llamar a este método, y aun así el creador puede faltar en filas
  /// antiguas, de ahí el `unknownCreator` de reserva.
  MediaEntity toEntity({bool isImported = false}) {
    return MediaEntity(
      id: id!,
      path: path,
      isImported: isImported,
      downloaded: downloaded,
      isFavorite: isFavorite,
      description: description,
      creator: creator.value?.toEntity() ?? unknownCreator,
      tags: tags.map((tag) => tag.toEntity()).toList(),
      source: source.value?.toEntity(),
    );
  }

  factory MediaModel.fromEntity(MediaEntity entity) {
    final model = MediaModel(
        id: entity.id,
        path: entity.path
    );
    model.downloaded = entity.downloaded;
    model.isFavorite = entity.isFavorite;
    model.description = entity.description;
    // Note: Links should be handled in the repository/mapper context
    // because they require fetching or creating related models in Isar.
    return model;
  }
}
