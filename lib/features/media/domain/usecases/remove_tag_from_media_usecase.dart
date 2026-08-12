import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Etiqueta que hay que quitar y contenidos a los que hay que quitársela.
class RemoveTagFromMediaParams {
  final int tagId;
  final List<int> mediaIds;

  const RemoveTagFromMediaParams({required this.tagId, required this.mediaIds});
}

/// Deshace la asignación de una etiqueta a unos contenidos, sin borrar ni la
/// etiqueta ni los contenidos.
class RemoveTagFromMediaUseCase
    extends UseCase<DataState, RemoveTagFromMediaParams> {
  final LocalMediaRepository _repository;

  RemoveTagFromMediaUseCase(this._repository);

  @override
  Future<DataState> call({RemoveTagFromMediaParams? params}) {
    return _repository.removeTagFromMedia(params!.tagId, params.mediaIds);
  }
}
