import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Marca de favorito de varios contenidos a la vez: es lo que hace el corazón de
/// la rejilla sobre lo que esté seleccionado.
class SetMediaListFavoriteUseCase
    extends UseCase<DataState, ({List<int> ids, bool isFavorite})> {
  final LocalMediaRepository _repository;

  SetMediaListFavoriteUseCase(this._repository);

  @override
  Future<DataState> call({({List<int> ids, bool isFavorite})? params}) {
    if (params == null) return Future.value(DataSuccess(null));

    return _repository.setMediaListFavorite(
      params.ids,
      isFavorite: params.isFavorite,
    );
  }
}
