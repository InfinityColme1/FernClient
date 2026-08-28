import 'dart:io';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/duplicates/data/models/duplicate_group_model.dart';
import 'package:Fern/features/duplicates/data/services/perceptual_hash.dart';
import 'package:Fern/features/duplicates/domain/repositories/duplicate_repository.dart';
import 'package:Fern/features/duplicates/domain/services/duplicate_grouping.dart';
import 'package:Fern/features/duplicates/domain/services/group_reconciliation.dart';
import 'package:Fern/features/duplicates/domain/services/hashing_plan.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:isar/isar.dart';

class DuplicateRepositoryImpl implements DuplicateRepository {
  final Isar _database;

  /// Cuándo se tocó por última vez el fichero de una ruta.
  ///
  /// Va por parámetro para poder probar el repositorio sin crear ficheros: lo
  /// que se comprueba de él es qué guarda y qué respeta, no si sabe leer el
  /// disco.
  final DateTime? Function(String path) _modifiedAt;

  /// Qué se puede enseñar ahora mismo.
  ///
  /// Lo pregunta la lista de grupos. Comparar dos copias es abrirlas, así que un
  /// grupo formado por contenido que el filtro esconde no es una decisión que se
  /// pueda tomar: se enseñaría «2 copias, distancia 4» sobre algo que no se
  /// puede ver, que además de inútil cuenta que ese contenido existe.
  ///
  /// De fábrica no esconde nada, como en el repositorio de contenido: quien lo
  /// monte sin decir nada obtiene el comportamiento de siempre.
  final ContentVisibility _visibility;

  DuplicateRepositoryImpl({
    required Isar database,
    DateTime? Function(String path)? modifiedAt,
    ContentVisibility visibility = const ContentVisibility(),
  })  : _database = database,
        _modifiedAt = modifiedAt ?? _lastModified,
        _visibility = visibility;

  @override
  Future<DataState<List<HashableMedia>>> getHashable() async {
    try {
      // Sin lo que está en la papelera: lo que ya se ha tirado no puede ser el
      // duplicado de nada, y decodificarlo sería trabajo para nada.
      final rows = await _database.mediaSummaryModels
          .filter()
          .isDeletedEqualTo(false)
          .findAll();

      return DataSuccess([
        for (final row in rows)
          HashableMedia(
            mediaId: row.id,
            path: row.path,
            hashedAt: row.hashedAt,
            fileModifiedAt: _modifiedAt(row.path),
          ),
      ]);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<bool>> saveHashes(
    int mediaId,
    PerceptualHashes hashes,
  ) async {
    try {
      final summary = await _database.mediaSummaryModels.get(mediaId);
      if (summary == null) {
        return DataException(Exception('El contenido $mediaId no existe'));
      }

      summary
        ..perceptualHash = hashes.dHash
        ..dctHash = hashes.pHash
        ..hashedAt = DateTime.now();

      await _database.writeTxn(
        () => _database.mediaSummaryModels.put(summary),
      );

      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<int>> clearHashes() async {
    try {
      final hashed = await _database.mediaSummaryModels
          .filter()
          .hashedAtIsNotNull()
          .findAll();

      if (hashed.isEmpty) return const DataSuccess(0);

      for (final summary in hashed) {
        summary
          ..perceptualHash = null
          ..dctHash = null
          ..hashedAt = null;
      }

      // De una vez: diez mil escrituras sueltas son diez mil transacciones, y
      // esto se pulsa esperando que termine.
      await _database.writeTxn(
        () => _database.mediaSummaryModels.putAll(hashed),
      );

      return DataSuccess(hashed.length);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<List<HashedMedia>>> getHashed() async {
    try {
      final rows = await _database.mediaSummaryModels
          .filter()
          .isDeletedEqualTo(false)
          .perceptualHashIsNotNull()
          .findAll();

      return DataSuccess([
        for (final row in rows)
          if (row.dctHash != null)
            HashedMedia(
              mediaId: row.id,
              dHash: row.perceptualHash!,
              pHash: row.dctHash!,
            ),
      ]);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<List<KnownGroup>>> getKnownGroups() async {
    try {
      final rows = await _database.duplicateGroupModels.where().findAll();

      return DataSuccess([for (final row in rows) row.toKnown()]);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<int>> saveGroups(
    List<ReconciledGroup> groups, {
    bool retireUnseen = false,
  }) async {
    try {
      var fresh = 0;

      await _database.writeTxn(() async {
        if (retireUnseen) await _retireUnseen(groups);

        // Cuáles de estas copias siguen vivas: es lo que dice si una decisión
        // ya tomada sigue describiendo lo que hay.
        //
        // Vivas y no «comparables»: que el filtro NSFW las esconda ahora mismo
        // no cambia si el grupo sigue teniendo sentido. Mirarlo aquí haría que
        // quitar el filtro reabriera grupos ya resueltos.
        final alive = await _aliveAmong({
          for (final one in groups) ...one.group.mediaIds,
        });

        for (final one in groups) {
          final signature = signatureOf(one.group.mediaIds);

          final existing = await _database.duplicateGroupModels
              .filter()
              .signatureEqualTo(signature)
              .findFirst();

          // Lo que el usuario ya contestó se queda como estaba: guardar un
          // escaneo no puede resucitar un grupo que alguien descartó, que es lo
          // único que evita que el mismo falso positivo vuelva cada mes.
          if (existing != null) {
            existing.maxDistance = one.group.maxDistance;

            // Salvo que la respuesta ya no venga a cuento: ver [_reopens].
            if (_reopens(existing, one.group.mediaIds, alive)) {
              existing
                ..isResolved = false
                ..foundAt = DateTime.now();

              fresh++;
            }

            await _database.duplicateGroupModels.put(existing);
            continue;
          }

          await _database.duplicateGroupModels.put(
            DuplicateGroupModel()
              ..mediaIds = one.group.mediaIds
              ..signature = signature
              ..maxDistance = one.group.maxDistance
              ..foundAt = DateTime.now(),
          );

          fresh++;
        }
      });

      return DataSuccess(fresh);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Tira los grupos sin contestar que este escaneo ya no ha encontrado.
  ///
  /// Sólo los sin contestar: lo descartado y lo resuelto son decisiones del
  /// usuario y se guardan justamente para que no vuelvan a proponerse. Si se
  /// borraran aquí, el mismo falso positivo reaparecería en el escaneo
  /// siguiente, que es lo que toda esta parte existe para evitar.
  Future<void> _retireUnseen(List<ReconciledGroup> groups) async {
    final seen = {
      for (final one in groups) signatureOf(one.group.mediaIds),
    };

    final pending = await _database.duplicateGroupModels
        .filter()
        .isResolvedEqualTo(false)
        .isDismissedEqualTo(false)
        .findAll();

    final stale = [
      for (final group in pending)
        if (!seen.contains(group.signature)) group.id,
    ];

    if (stale.isNotEmpty) await _database.duplicateGroupModels.deleteAll(stale);
  }

  @override
  Future<DataState<List<DuplicateGroupSummary>>> getGroupsToReview() async {
    try {
      final rows = await _database.duplicateGroupModels
          .filter()
          .isResolvedEqualTo(false)
          .isDismissedEqualTo(false)
          .findAll();

      // Un grupo cuyas copias ya no se pueden comparar no es una decisión que se
      // pueda tomar: enseñarlo con el botón de conservar debajo lleva a mandar a
      // la papelera la única que quedaba.
      final comparable = await _comparableAmong({
        for (final row in rows) ...row.mediaIds,
      });

      rows.removeWhere(
        (row) => row.mediaIds.where(comparable.contains).length < 2,
      );

      // Lo idéntico primero, que es lo que se decide sin pensar; y a igual
      // distancia, lo encontrado antes.
      rows.sort((one, other) {
        final byDistance = one.maxDistance.compareTo(other.maxDistance);

        return byDistance != 0 ? byDistance : one.foundAt.compareTo(other.foundAt);
      });

      // El grupo sale **sólo con las copias que se pueden comparar**, no con
      // todas las que guarda. La pantalla dice cuántas hay antes de abrirlo, y
      // con la lista entera diría «3 copias» sobre un grupo que enseña dos:
      // contar lo que no se puede enseñar es contar que existe.
      //
      // Lo guardado no se toca: el grupo sigue siendo el que es, y en cuanto se
      // quita el filtro vuelve entero.
      return DataSuccess([
        for (final row in rows)
          DuplicateGroupSummary(
            id: row.id,
            mediaIds: [
              for (final mediaId in row.mediaIds)
                if (comparable.contains(mediaId)) mediaId,
            ],
            maxDistance: row.maxDistance,
            foundAt: row.foundAt,
          ),
      ]);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Si un grupo ya resuelto vuelve a ser una pregunta abierta.
  ///
  /// Resolver un grupo es quedarse con una copia y mandar las demás a la
  /// papelera, así que después queda una viva como mucho. Que vuelva a haber
  /// dos es que ha pasado algo por medio: se ha sacado una de la papelera, o se
  /// ha borrado el contenido de la biblioteca y se ha vuelto a importar. En los
  /// dos casos la respuesta de entonces ya no describe lo que hay ahora, y
  /// callársela deja dos copias iguales dentro para siempre.
  ///
  /// Hace falta porque el identificador de un contenido es el hash de su ruta:
  /// el mismo fichero importado otra vez en el mismo sitio vuelve con el mismo
  /// identificador, y con él el grupo vuelve a coincidir letra por letra con
  /// uno que se contestó cuando dentro había otras copias.
  ///
  /// Lo descartado —«no son duplicados»— no se reabre nunca: eso no es una
  /// decisión sobre estas copias, es un juicio sobre las imágenes, y volver a
  /// preguntarlo es justo lo que esta parte existe para evitar.
  bool _reopens(
    DuplicateGroupModel group,
    List<int> mediaIds,
    Set<int> alive,
  ) {
    if (!group.isResolved || group.isDismissed) return false;

    return mediaIds.where(alive.contains).length > 1;
  }

  /// Cuáles de estos contenidos siguen en la biblioteca, en una sola consulta.
  Future<Set<int>> _aliveAmong(Set<int> mediaIds) async {
    if (mediaIds.isEmpty) return const {};

    final rows = await _database.mediaSummaryModels
        .filter()
        .isDeletedEqualTo(false)
        .anyOf(mediaIds, (query, id) => query.idEqualTo(id))
        .findAll();

    return {for (final row in rows) row.id};
  }

  /// Cuáles de estos contenidos se pueden comparar, en una sola consulta.
  ///
  /// Vivos y visibles. Lo segundo se pregunta por `hidesDetails` y no por
  /// `hidesMedia`: con el filtro puesto y el contenido **tapado**, la celda
  /// aparece en la rejilla pero abrirla sigue pidiendo la contraseña, y comparar
  /// dos copias es abrirlas.
  Future<Set<int>> _comparableAmong(Set<int> mediaIds) async {
    if (mediaIds.isEmpty) return const {};

    final rows = await _database.mediaSummaryModels
        .filter()
        .isDeletedEqualTo(false)
        .anyOf(mediaIds, (query, id) => query.idEqualTo(id))
        .findAll();

    return {
      for (final row in rows)
        if (!_visibility.hidesDetails(row.id)) row.id,
    };
  }

  @override
  Future<DataState<bool>> markResolved(int groupId) =>
      _mark(groupId, (group) => group.isResolved = true);

  @override
  Future<DataState<bool>> markDismissed(int groupId) =>
      _mark(groupId, (group) => group.isDismissed = true);

  Future<DataState<bool>> _mark(
    int groupId,
    void Function(DuplicateGroupModel) change,
  ) async {
    try {
      final group = await _database.duplicateGroupModels.get(groupId);
      if (group == null) {
        return DataException(Exception('El grupo $groupId no existe'));
      }

      change(group);

      await _database.writeTxn(
        () => _database.duplicateGroupModels.put(group),
      );

      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataException(e);
    }
  }
}

/// Cuándo se tocó el fichero, o `null` si no está o no se puede leer.
DateTime? _lastModified(String path) {
  try {
    final file = File(path);

    return file.existsSync() ? file.statSync().modified : null;
  } on Object {
    return null;
  }
}
