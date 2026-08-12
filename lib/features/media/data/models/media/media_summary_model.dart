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

  /// Contenido marcado para borrar: sigue en la base de datos, pero sólo se ve
  /// en la pantalla de eliminados hasta que se restablezca o se fuerce el
  /// borrado definitivo.
  bool isDeleted = false;

  /// Cuándo se marcó para borrar, que es lo que decide cuándo caduca: pasada la
  /// semana de gracia, la papelera se vacía sola. `null` en lo que no está
  /// marcado.
  DateTime? deletedAt;

  final details = IsarLink<MediaModel>();

  MediaSummaryModel();

  MediaSummaryEntity toEntity() {
    return MediaSummaryEntity(
        id: id,
        path: path,
        isImported: isImported,
        isDeleted: isDeleted,
        deletedAt: deletedAt
    );
  }

  factory MediaSummaryModel.fromEntity(MediaSummaryEntity entity) {
    final model = MediaSummaryModel()
      ..id = entity.id
      ..path = entity.path
      ..isImported = entity.isImported
      ..isDeleted = entity.isDeleted
      ..deletedAt = entity.deletedAt;
    return model;
  }
}