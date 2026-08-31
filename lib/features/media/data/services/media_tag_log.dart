import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/models/media_tag_log_model.dart';
import 'package:Fern/features/media/domain/entities/tag_log_entry_entity.dart';
import 'package:isar/isar.dart';

/// El registro de por qué un contenido tiene lo que tiene puesto.
///
/// La aplicación etiqueta sola por varios caminos —la dirección de la que se
/// bajó, la etiqueta que traía la plataforma, lo que arrastran la rama y las
/// hermanas, lo que propone un modelo, lo que enlaza un fernie— y desde fuera
/// todo se ve igual: una etiqueta más en el panel. Cuando aparece una que nadie
/// esperaba no había forma de saber de dónde salió, y por lo tanto tampoco qué
/// corregir para que no vuelva a pasar.
///
/// **Se escribe dentro de la escritura de quien lo llama.** Isar no anida
/// transacciones, y sobre todo: apuntar que algo se puso tiene que irse al
/// suelo con lo que lo puso si aquello falla. Un registro que diga que se puso
/// una etiqueta que no está es peor que no tener registro.
class MediaTagLog {
  final Isar _database;

  /// Cuántas líneas se conservan por contenido.
  ///
  /// Con tope, como el parte de reconocimiento: reconocer la biblioteca entera
  /// varias veces deja decenas de líneas por contenido, y de un registro así
  /// nadie lee más que el final. Se cae lo más viejo.
  final int limit;

  MediaTagLog(this._database, {this.limit = mediaTagLogLimit});

  /// Apunta [entries], **dentro de una escritura ya abierta**.
  ///
  /// Llamarlo fuera de una es un error de programación y Isar lo dice; no se
  /// abre una aquí para no partir en dos lo que tiene que ser una sola cosa.
  Future<void> writeInside(List<TagLogEntryEntity> entries) async {
    if (entries.isEmpty) return;

    await _database.mediaTagLogModels.putAll(
      [for (final entry in entries) MediaTagLogModel.of(entry)],
    );

    for (final mediaId in {for (final entry in entries) entry.mediaId}) {
      await _prune(mediaId);
    }
  }

  /// Lo apuntado de un contenido, de lo más nuevo a lo más viejo.
  Future<List<TagLogEntryEntity>> of(int mediaId) async {
    final rows = await _database.mediaTagLogModels
        .filter()
        .mediaIdEqualTo(mediaId)
        .findAll();

    rows.sort((a, b) => b.at.compareTo(a.at));

    return [for (final row in rows) row.toEntity()];
  }

  /// Si de este contenido hay algo apuntado.
  ///
  /// Es lo que distingue «no se le ha puesto nada» de «esto es anterior al
  /// registro»: sin la diferencia, todo lo que ya había en la biblioteca diría
  /// que nadie le puso nunca nada.
  Future<bool> has(int mediaId) async =>
      await _database.mediaTagLogModels
          .filter()
          .mediaIdEqualTo(mediaId)
          .count() >
      0;

  Future<void> _prune(int mediaId) async {
    // Se cuenta antes de traer nada: esto corre dentro de la escritura de cada
    // alta de contenido, y en una importación de mil eso son mil consultas. La
    // cuenta no trae filas; el caso normal —muy por debajo del tope— se queda
    // ahí.
    final total = await _database.mediaTagLogModels
        .filter()
        .mediaIdEqualTo(mediaId)
        .count();

    if (total <= limit) return;

    final rows = await _database.mediaTagLogModels
        .filter()
        .mediaIdEqualTo(mediaId)
        .findAll();

    if (rows.length <= limit) return;

    rows.sort((a, b) => a.at.compareTo(b.at));

    await _database.mediaTagLogModels.deleteAll(
      [for (final row in rows.take(rows.length - limit)) row.id],
    );
  }
}
