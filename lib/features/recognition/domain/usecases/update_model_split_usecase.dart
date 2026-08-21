import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';

/// Lo que hace falta para cambiar el reparto de un fernie dentro de un modelo.
class UpdateSplitParams {
  final int assignmentId;
  final DatasetSplit split;

  const UpdateSplitParams({required this.assignmentId, required this.split});
}

/// Cambia cómo se reparten las regiones de un fernie entre entrenar, validar y
/// probar.
class UpdateModelSplitUseCase
    extends UseCase<DataState<ModelFernieEntity>, UpdateSplitParams> {
  final ModelRepository _repository;

  UpdateModelSplitUseCase(this._repository);

  @override
  Future<DataState<ModelFernieEntity>> call({UpdateSplitParams? params}) {
    return _repository.updateSplit(
      assignmentId: params!.assignmentId,
      split: params.split,
    );
  }
}
