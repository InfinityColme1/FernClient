import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Borrado de varios contenidos a la vez, el de los botones de la cabecera de
/// importación sobre la selección de la rejilla.
class DeleteMediaListUseCase extends UseCase<DataState, List<int>> {
  final LocalMediaRepository _repository;

  DeleteMediaListUseCase(this._repository);

  @override
  Future<DataState> call({List<int>? params}) {
    return _repository.deleteMediaList(params ?? const []);
  }
}
