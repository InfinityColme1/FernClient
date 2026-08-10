import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:isar/isar.dart';
import 'media_model.dart';

part 'media_summary_model.g.dart';

@collection
@Name("MediaSummaries")
class MediaSummaryModel {
  Id id = Isar.autoIncrement; // Usaremos el hash aquí

  @Index(unique: true, replace: true)
  late String path;

  bool isImported = false; // Nuevo campo para diferenciar

  final details = IsarLink<MediaModel>();

  MediaSummaryModel();

  MediaSummaryEntity toEntity() {
    return MediaSummaryEntity(
        id: id,
        path: path,
        isImported: isImported
    );
  }

  factory MediaSummaryModel.fromEntity(MediaSummaryEntity entity) {
    final model = MediaSummaryModel()
      ..id = entity.id
      ..path = entity.path
      ..isImported = entity.isImported;
    return model;
  }
}