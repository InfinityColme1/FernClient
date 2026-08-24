import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Qué contenido se marca y cómo.
class SetMediaNsfwParams {
  final List<int> mediaIds;
  final bool isNsfw;

  const SetMediaNsfwParams({required this.mediaIds, required this.isNsfw});

  /// Para marcar uno solo, que es el caso del visor y del menú de la rejilla.
  SetMediaNsfwParams.one(int mediaId, {required this.isNsfw})
      : mediaIds = [mediaId];
}

/// Marca o desmarca contenido como NSFW.
///
/// Es la marca **propia** del contenido, la que se pone sobre él y no la que
/// hereda de sus etiquetas. Las dos suman y ninguna pisa a la otra: un contenido
/// desmarcado a mano sigue escondido si lleva una etiqueta marcada, y uno
/// marcado a mano sigue marcado aunque su etiqueta deje de estarlo.
///
/// Devuelve a cuántos ha cambiado de verdad. No son todos los que se piden: en
/// una selección donde la mitad ya estaba marcada, el número que se enseña tiene
/// que ser el de los que se han movido, no el de los que se han mirado.
class SetMediaNsfwUseCase extends UseCase<DataState<int>, SetMediaNsfwParams> {
  final LocalMediaRepository _repository;

  SetMediaNsfwUseCase(this._repository);

  @override
  Future<DataState<int>> call({SetMediaNsfwParams? params}) {
    if (params == null) {
      return Future.value(
        DataException(Exception('No se dijo qué contenido marcar')),
      );
    }

    return _repository.setMediaNsfw(params.mediaIds, isNsfw: params.isNsfw);
  }
}
