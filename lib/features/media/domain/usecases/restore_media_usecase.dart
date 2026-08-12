import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Quita la marca de borrado de la selección de la pantalla de eliminados.
class RestoreMediaUseCase extends UseCase<DataState, List<int>> {
  final LocalMediaRepository _repository;

  RestoreMediaUseCase(this._repository);

  @override
  Future<DataState> call({List<int>? params}) {
    return _repository.restoreMediaList(params ?? const []);
  }
}
