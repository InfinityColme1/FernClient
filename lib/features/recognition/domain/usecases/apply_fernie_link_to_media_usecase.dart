import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';

/// Qué fernie se ha marcado y en qué contenidos.
class ApplyFernieLinkParams {
  final FernieEntity fernie;
  final List<int> mediaIds;

  const ApplyFernieLinkParams({required this.fernie, required this.mediaIds});
}

/// Qué ha llegado a ponerse.
typedef FernieLinkApplied = ({int tagged, int credited});

/// Le pone al contenido lo que el fernie enlaza, al marcarle una región.
///
/// Un fernie es «esto que sale aquí», y marcarlo en un contenido es decir que
/// sale ahí. Si además enlaza una etiqueta, ponérsela es la consecuencia
/// evidente — y hasta ahora no pasaba: marcar una región escribía la región y
/// nada más, así que había que ir a poner la etiqueta a mano justo después de
/// haber dicho de qué se trataba.
///
/// **La etiqueta se suma; el creador sólo si falta.** Una etiqueta más nunca
/// estorba y la jerarquía la expande sola. El creador es uno solo: pisar el que
/// alguien puso a mano sería que marcar una región cambiara un dato que nadie ha
/// pedido cambiar. Por eso sólo entra donde no hay ninguno o donde está el
/// «desconocido», que es el de reserva.
class ApplyFernieLinkToMediaUseCase
    extends UseCase<DataState<FernieLinkApplied>, ApplyFernieLinkParams> {
  final LocalMediaRepository _repository;

  ApplyFernieLinkToMediaUseCase(this._repository);

  @override
  Future<DataState<FernieLinkApplied>> call({
    ApplyFernieLinkParams? params,
  }) async {
    final fernie = params!.fernie;
    final mediaIds = params.mediaIds;

    if (mediaIds.isEmpty) return const DataSuccess((tagged: 0, credited: 0));

    try {
      var tagged = 0;
      var credited = 0;

      for (final mediaId in mediaIds) {
        if (fernie.linkedTagId case final tagId?) {
          final result = await _repository.addTagsToMedia(mediaId, [tagId]);

          if (result is DataSuccess) tagged++;
        }

        if (fernie.linkedCreatorId case final creatorId?) {
          final result = await _repository.setMediaCreator(
            mediaId,
            creatorId,
            onlyIfMissing: true,
          );

          if (result.data == true) credited++;
        }
      }

      return DataSuccess((tagged: tagged, credited: credited));
    } on Exception catch (error) {
      return DataException(error);
    }
  }
}
