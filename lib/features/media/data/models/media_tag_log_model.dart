import 'package:Fern/features/media/domain/entities/tag_log_entry_entity.dart';
import 'package:isar/isar.dart';

part 'media_tag_log_model.g.dart';

/// Una línea del registro de etiquetado de un contenido.
///
/// Colección nueva, así que es aditiva: basta con darla de alta para que Isar la
/// cree, y lo que ya hay en la base no se toca. El contenido anterior a esto no
/// tiene registro y no se le inventa ninguno — lo que se puede deducir mirando
/// sus datos se calcula al vuelo y se enseña dicho como lo que es.
///
/// El nombre de lo que se puso se guarda **aquí**, y no se busca al leer: la
/// etiqueta se puede renombrar o borrar después, y un registro que dijera «se
/// puso la etiqueta 47» no serviría para lo único que existe, que es entender lo
/// que pasó.
@collection
@Name("MediaTagLogs")
class MediaTagLogModel {
  Id id = Isar.autoIncrement;

  /// De qué contenido es la línea. Indexado porque es como se lee siempre: el
  /// registro de uno, no el de todos.
  @Index()
  late int mediaId;

  late DateTime at;

  /// Por qué se puso.
  ///
  /// Por nombre y no por posición: añadir un motivo entre dos existentes
  /// renumeraría todo lo guardado y el registro pasaría a contar otra cosa.
  @Enumerated(EnumType.name)
  late TagLogReason reason;

  int? tagId;
  int? creatorId;

  /// Cómo se llamaba en ese momento.
  late String label;

  /// El porqué concreto, cuando lo hay: la dirección que casó, o de qué otra
  /// etiqueta viene lo heredado.
  String? detail;

  MediaTagLogModel();

  TagLogEntryEntity toEntity() => TagLogEntryEntity(
        mediaId: mediaId,
        reason: reason,
        tagId: tagId,
        creatorId: creatorId,
        label: label,
        detail: detail,
        at: at,
      );

  static MediaTagLogModel of(TagLogEntryEntity entry) => MediaTagLogModel()
    ..mediaId = entry.mediaId
    ..at = entry.at
    ..reason = entry.reason
    ..tagId = entry.tagId
    ..creatorId = entry.creatorId
    ..label = entry.label
    ..detail = entry.detail;
}
