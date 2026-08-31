import 'package:Fern/features/media/data/models/blocked_import_model.dart';
import 'package:isar/isar.dart';

/// Qué piezas de una fuente remota no hay que volver a ofrecer, en memoria.
///
/// **La consulta tiene que ser síncrona.** Se pregunta una vez por cada pieza de
/// cada importación, antes de descargar nada; una consulta a Isar por cada una
/// convertiría importar mil cosas en mil consultas para no hacer nada mil veces.
/// Se carga al arrancar y se mantiene al día al bloquear y desbloquear, como
/// hace `NsfwIndex`.
class BlockedImports {
  /// Sin base de datos no se bloquea nada y no se puede bloquear.
  ///
  /// Es lo que necesitan las pruebas que montan el repositorio remoto sin
  /// abrirla: importar no tiene por qué saber de esto para funcionar, y
  /// obligarlas a abrir una base entera para preguntar por algo que está vacío
  /// sería pedir mucho a cambio de nada.
  final Isar? _database;

  Set<int> _blocked = const {};

  BlockedImports({Isar? database}) : _database = database;

  Isar get _open =>
      _database ?? (throw StateError('BlockedImports sin base de datos'));

  /// Si esta pieza está bloqueada. Es la pregunta del recorrido de la fuente.
  bool blocks(String source, String remoteId) =>
      _blocked.contains(BlockedImportModel.idOf(source, remoteId));

  bool get isEmpty => _blocked.isEmpty;

  int _skipped = 0;

  /// Cuántas piezas se ha saltado la importación en curso.
  ///
  /// Se cuenta para poder decirlo al terminar. Sin ese recuento, una
  /// importación que no trae nada porque estaba todo bloqueado se ve igual que
  /// una que no encontró nada nuevo, y eso es justo lo que hace dudar de si el
  /// bloqueo está haciendo algo.
  int get skipped => _skipped;

  void noteSkipped() => _skipped++;

  void resetSkipped() => _skipped = 0;

  /// Vuelve a leerlo todo. Lo llama el arranque, antes de importar nada.
  Future<void> rebuild() async {
    if (_database == null) return;

    final rows = await _open.blockedImportModels.where().findAll();

    _blocked = {for (final row in rows) row.id};
  }

  /// Lo bloqueado, de lo más reciente a lo más antiguo.
  ///
  /// Se lee de la base y no de la memoria: aquí hace falta lo que se enseña —de
  /// dónde era, qué era y cuándo se bloqueó—, y eso no cabe en un conjunto de
  /// identificadores.
  Future<List<BlockedImportModel>> all() async {
    if (_database == null) return const [];

    final rows = await _open.blockedImportModels.where().findAll();

    return rows..sort((a, b) => b.at.compareTo(a.at));
  }

  /// Apunta que esta pieza no se quiere.
  ///
  /// Bloquear dos veces lo mismo no deja dos filas: el identificador sale de la
  /// fuente y la pieza, así que la segunda escribe encima de la primera.
  Future<void> block({
    required String source,
    required String remoteId,
    String? description,
    String? sourceUrl,
  }) async {
    if (remoteId.isEmpty) return;

    final row = BlockedImportModel()
      ..id = BlockedImportModel.idOf(source, remoteId)
      ..source = source
      ..remoteId = remoteId
      ..description = description
      ..sourceUrl = sourceUrl
      ..at = DateTime.now();

    await _open.writeTxn(() => _open.blockedImportModels.put(row));

    _blocked = {..._blocked, row.id};
  }

  Future<void> unblock(int id) async {
    await _open.writeTxn(() => _open.blockedImportModels.delete(id));

    _blocked = {
      for (final each in _blocked)
        if (each != id) each,
    };
  }

  /// Se olvida de todo: lo bloqueado vuelve a ofrecerse.
  Future<void> clear() async {
    await _open.writeTxn(() => _open.blockedImportModels.clear());

    _blocked = const {};
  }
}
