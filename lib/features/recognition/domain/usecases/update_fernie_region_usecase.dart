import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Cambia el rectángulo de una región ya guardada, o la reasigna a otro fernie.
class UpdateFernieRegionUseCase
    extends UseCase<DataState<FernieRegionEntity>, FernieRegionEntity> {
  final FernieRepository _repository;

  UpdateFernieRegionUseCase(this._repository);

  @override
  Future<DataState<FernieRegionEntity>> call({FernieRegionEntity? params}) {
    return _repository.updateRegion(params!);
  }
}
