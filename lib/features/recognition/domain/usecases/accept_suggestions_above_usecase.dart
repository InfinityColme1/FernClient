import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/entities/tag_log_entry_entity.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/media_suggestion_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/answer_suggestions_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_media_suggestions_usecase.dart';
import 'package:flutter/foundation.dart';

/// Qué se acepta de golpe.
class AcceptAboveParams {
  final List<int> mediaIds;

  /// A partir de qué confianza se acepta sin mirar.
  final double threshold;

  const AcceptAboveParams({required this.mediaIds, required this.threshold});
}

/// Cuánto se aceptó y sobre cuántos contenidos.
class BulkAcceptResult {
  final int accepted;
  final int mediaTouched;

  const BulkAcceptResult({required this.accepted, required this.mediaTouched});
}

/// Acepta de una vez todo lo propuesto por encima de un listón.
///
/// Es lo que hace usable revisar trescientos contenidos: lo que el modelo ha
/// visto con mucha seguridad casi siempre es correcto, y hacer clic trescientas
/// veces para decir que sí a lo evidente es lo que hace que nadie revise nada.
///
/// **Aquí sí se escribe en el acto.** En el panel del visor aceptar espera al
/// «Guardar» porque la etiqueta va con el resto de cambios sin guardar de ese
/// contenido; aquí no hay ningún contenido abierto ni ningún «Guardar» que
/// pudiera confirmarlo, así que esperar sería perderlo.
///
/// **Y no da el contenido por definitivo.** Aceptar etiquetas y dar por revisado
/// son dos cosas, y en la pantalla de importación hay un botón de confirmar
/// justo al lado: hacerle su trabajo sería quitarle al usuario la decisión de
/// cuándo algo está listo.
class AcceptSuggestionsAboveUseCase
    extends UseCase<DataState<BulkAcceptResult>, AcceptAboveParams> {
  final GetMediaSuggestionsUseCase _getSuggestions;
  final AnswerSuggestionsUseCase _answer;
  final LocalMediaRepository _library;

  AcceptSuggestionsAboveUseCase({
    required GetMediaSuggestionsUseCase getSuggestions,
    required AnswerSuggestionsUseCase answer,
    required LocalMediaRepository library,
  })  : _getSuggestions = getSuggestions,
        _answer = answer,
        _library = library;

  @override
  Future<DataState<BulkAcceptResult>> call({AcceptAboveParams? params}) async {
    var accepted = 0;
    var touched = 0;

    for (final mediaId in params!.mediaIds) {
      final found = await _getSuggestions(params: mediaId);
      if (found is! DataSuccess || found.data == null) continue;

      final chosen = [
        for (final one in found.data!)
          if (one.confidence >= params.threshold &&
              one.proposes != FernieLinkKind.none)
            one,
      ];

      if (chosen.isEmpty) continue;

      // Un contenido que falle no para el lote: son decisiones independientes y
      // el usuario ya las ha tomado todas de una vez.
      final written = await _apply(mediaId, chosen);
      if (!written) continue;

      final answered = await _answer(params: AnswerSuggestionsParams(
        ids: [for (final one in chosen) one.id],
        status: SuggestionStatus.accepted,
      ));

      accepted += answered is DataSuccess ? answered.data ?? 0 : 0;
      touched++;
    }

    return DataSuccess(
      BulkAcceptResult(accepted: accepted, mediaTouched: touched),
    );
  }

  /// Pone en el contenido lo que proponían estas sugerencias.
  ///
  /// Las etiquetas van todas de una escritura; el creador es uno, así que si dos
  /// modelos proponen dos distintos manda **el más seguro**, que es el primero
  /// de la lista.
  Future<bool> _apply(int mediaId, List<MediaSuggestionEntity> chosen) async {
    try {
      final tagIds = <int>{
        for (final one in chosen)
          if (one.tag case final tag?) tag.id,
      };

      if (tagIds.isNotEmpty) {
        final result = await _library.addTagsToMedia(
          mediaId,
          tagIds.toList(),
          reason: TagLogReason.recognition,
        );
        if (result is! DataSuccess) return false;
      }

      final creator = chosen
          .where((one) => one.creator != null)
          .fold<MediaSuggestionEntity?>(
            null,
            (best, one) =>
                best == null || one.confidence > best.confidence ? one : best,
          );

      if (creator?.creator case final chosenCreator?) {
        await _library.setMediaCreator(
          mediaId,
          chosenCreator.id,
          reason: TagLogReason.recognition,
        );
      }

      return true;
    } on Object catch (error) {
      debugPrint('No se pudo aceptar en $mediaId: $error');

      return false;
    }
  }
}
