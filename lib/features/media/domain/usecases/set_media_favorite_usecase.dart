import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Pone o quita la marca de favorito de un contenido: es lo que hace el
/// corazón del visor, y se escribe en el momento.
class SetMediaFavoriteUseCase
    extends UseCase<DataState, ({int id, bool isFavorite})> {
  final LocalMediaRepository _repository;

  SetMediaFavoriteUseCase(this._repository);

  @override
  Future<DataState> call({({int id, bool isFavorite})? params}) {
    if (params == null) return Future.value(DataSuccess(null));

    return _repository.setMediaFavorite(params.id, isFavorite: params.isFavorite);
  }
}
