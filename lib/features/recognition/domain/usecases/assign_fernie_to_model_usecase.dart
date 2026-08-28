import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';

/// Lo que hace falta para meter un fernie en un modelo.
class AssignFernieParams {
  final int modelId;
  final int fernieId;

  const AssignFernieParams({required this.modelId, required this.fernieId});
}

/// Mete un fernie en un modelo, con el reparto de fábrica y el siguiente número
/// de clase libre.
class AssignFernieToModelUseCase
    extends UseCase<DataState<ModelFernieEntity>, AssignFernieParams> {
  final ModelRepository _repository;

  AssignFernieToModelUseCase(this._repository);

  @override
  Future<DataState<ModelFernieEntity>> call({AssignFernieParams? params}) {
    return _repository.assignFernie(
      modelId: params!.modelId,
      fernieId: params.fernieId,
    );
  }
}
