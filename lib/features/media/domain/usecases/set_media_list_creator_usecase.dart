import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// A qué contenidos y qué creador.
class SetMediaListCreatorParams {
  final List<int> mediaIds;
  final int creatorId;

  const SetMediaListCreatorParams({
    required this.mediaIds,
    required this.creatorId,
  });
}

/// Le pone el mismo creador a toda una selección.
///
/// Es el trabajo que hacía imposible revisar una tanda: cien imágenes del mismo
/// artista se abrían de una en una para escribir cien veces el mismo nombre.
///
/// Pisa el que hubiera, y a propósito: quien marca cien contenidos y elige un
/// creador está diciendo de quién son. La excepción es lo automático
/// —`onlyIfMissing`—, que no puede pisar una decisión de nadie.
///
/// Devuelve a cuántos ha llegado a cambiárselo.
class SetMediaListCreatorUseCase
    extends UseCase<DataState<int>, SetMediaListCreatorParams> {
  final LocalMediaRepository _repository;

  SetMediaListCreatorUseCase(this._repository);

  @override
  Future<DataState<int>> call({SetMediaListCreatorParams? params}) {
    return _repository.setMediaListCreator(
      params!.mediaIds,
      params.creatorId,
    );
  }
}
