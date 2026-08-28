import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_result_model.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/recognition_result_repository.dart';
import 'package:isar/isar.dart';

class RecognitionResultRepositoryImpl implements RecognitionResultRepository {
  final Isar _database;

  RecognitionResultRepositoryImpl({required Isar database})
      : _database = database;

  @override
  Future<DataState<List<RecognitionResultEntity>>> getForMedia(
    int mediaId,
  ) async {
    try {
      final rows = await _database.recognitionResultModels
          .filter()
          .mediaIdEqualTo(mediaId)
          .findAll();

      // De más seguro a menos: quien abre esto viene a decir que sí o que no, y
      // lo que más probablemente sea correcto es lo primero que quiere ver.
      rows.sort((a, b) => b.confidence.compareTo(a.confidence));

      return DataSuccess([for (final row in rows) row.toEntity()]);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<int>> replaceSuggestions({
    required int mediaId,
    required List<RecognitionResultEntity> results,
    bool returnToReview = false,
  }) async {
    try {
      final previous = await _database.recognitionResultModels
          .filter()
          .mediaIdEqualTo(mediaId)
          .statusEqualTo(SuggestionStatus.suggested)
          .findAll();

      final rows = [
        for (final result in results)
          RecognitionResultModel.fromEntity(result)..mediaId = mediaId,
      ];

      await _database.writeTxn(() async {
        // Sólo lo que estaba sin mirar. Lo aceptado y lo rechazado se queda: es
        // la única medida del acierto real de un modelo, y borrarlo haría que se
        // volviera a preguntar por algo que el usuario ya contestó.
        await _database.recognitionResultModels
            .deleteAll([for (final row in previous) row.id]);

        await _database.recognitionResultModels.putAll(rows);

        await _markMedia(
          mediaId,
          hasPending: rows.isNotEmpty,
          looked: true,
          // Sólo si ha salido algo: reconocer un contenido y no encontrarle nada
          // no es motivo para sacarlo de la biblioteca.
          returnToReview: returnToReview && rows.isNotEmpty,
        );
      });

      return DataSuccess(rows.length);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<RecognitionResultEntity>> setStatus({
    required int id,
    required SuggestionStatus status,
  }) async {
    try {
      final row = await _database.recognitionResultModels.get(id);
      if (row == null) {
        return DataException(Exception('La sugerencia $id no existe'));
      }

      await _database.writeTxn(() async {
        row.status = status;
        await _database.recognitionResultModels.put(row);

        // La marca del contenido se recalcula aquí y no se apaga sin más: puede
        // quedar otra sugerencia sin mirar, y apagarla la escondería del filtro
        // de la pantalla de importación para siempre.
        await _markMedia(row.mediaId, hasPending: await _hasPending(row.mediaId));
      });

      return DataSuccess(row.toEntity());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<int>> purgeRejectedBefore(DateTime before) async {
    try {
      final old = await _database.recognitionResultModels
          .filter()
          .statusEqualTo(SuggestionStatus.rejected)
          .createdAtLessThan(before)
          .findAll();

      if (old.isEmpty) return const DataSuccess(0);

      await _database.writeTxn(
        () => _database.recognitionResultModels
            .deleteAll([for (final row in old) row.id]),
      );

      return DataSuccess(old.length);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Si al contenido le queda algo por mirar.
  Future<bool> _hasPending(int mediaId) async {
    final pending = await _database.recognitionResultModels
        .filter()
        .mediaIdEqualTo(mediaId)
        .statusEqualTo(SuggestionStatus.suggested)
        .count();

    return pending > 0;
  }

  /// Deja el sumario diciendo lo mismo que las filas.
  ///
  /// Va **dentro** de la transacción de quien llama: si la marca y las filas se
  /// separan, la pantalla de importación filtra por una cosa y enseña otra, y no
  /// hay forma de que el usuario entienda por qué.
  ///
  /// [looked] distingue haber pasado los modelos por el contenido de haber
  /// contestado a lo que dijeron: la fecha es de lo primero. Contestar no vuelve
  /// a mirar nada, y moverla ahí haría que «reconocido hace un momento» dijera
  /// algo que no ha pasado.
  Future<void> _markMedia(
    int mediaId, {
    required bool hasPending,
    bool looked = false,
    bool returnToReview = false,
  }) async {
    final summary = await _database.mediaSummaryModels.get(mediaId);
    if (summary == null) return;

    summary.hasPendingSuggestions = hasPending;
    if (looked) summary.recognizedAt = DateTime.now();

    // Deja de ser definitivo y vuelve a la pantalla de importación. El filtro de
    // «definitivo» es global, así que con esto desaparece también de la
    // búsqueda y de todas las rejillas sin tocar nada más.
    if (returnToReview) summary.isImported = false;

    await _database.mediaSummaryModels.put(summary);
  }
}
