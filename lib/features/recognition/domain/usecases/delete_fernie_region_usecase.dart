import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Borra una región. El fernie se queda con las demás.
class DeleteFernieRegionUseCase extends UseCase<DataState<bool>, int> {
  final FernieRepository _repository;

  DeleteFernieRegionUseCase(this._repository);

  @override
  Future<DataState<bool>> call({int? params}) {
    return _repository.deleteRegion(params!);
  }
}
