import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:isar/isar.dart';

import 'media_model.dart';

part 'media_summary_model.g.dart';

@collection
@Name("MediaSummaries")
class MediaSummaryModel {

  Id? id = Isar.autoIncrement;

  late String path;

  final details = IsarLink<MediaModel>();


  MediaSummaryModel({this.id, required this.path});

  MediaSummaryEntity toEntity() {
    return MediaSummaryEntity(id: id, path: path);
  }

  factory MediaSummaryModel.fromEntity(MediaSummaryEntity entity) {
    return MediaSummaryModel(
      path: entity.path
    );
  }
}