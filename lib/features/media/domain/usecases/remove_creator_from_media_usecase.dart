import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Creador que hay que quitar y contenidos a los que hay que quitárselo.
class RemoveCreatorFromMediaParams {
  final int creatorId;
  final List<int> mediaIds;

  const RemoveCreatorFromMediaParams({
    required this.creatorId,
    required this.mediaIds,
  });
}

/// Deshace la asignación de un creador a unos contenidos, que pasan al creador
/// desconocido: ni el creador ni los contenidos se borran.
class RemoveCreatorFromMediaUseCase
    extends UseCase<DataState, RemoveCreatorFromMediaParams> {
  final LocalMediaRepository _repository;

  RemoveCreatorFromMediaUseCase(this._repository);

  @override
  Future<DataState> call({RemoveCreatorFromMediaParams? params}) {
    return _repository.removeCreatorFromMedia(params!.creatorId, params.mediaIds);
  }
}
