import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';

/// Los fernies metidos en un modelo, con su reparto y su número de clase.
class GetFerniesOfModelUseCase
    extends UseCase<DataState<List<ModelFernieEntity>>, int> {
  final ModelRepository _repository;

  GetFerniesOfModelUseCase(this._repository);

  @override
  Future<DataState<List<ModelFernieEntity>>> call({int? params}) {
    return _repository.getFerniesOfModel(params!);
  }
}
