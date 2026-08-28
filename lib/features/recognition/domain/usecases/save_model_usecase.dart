import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';

/// Crea un modelo o guarda los cambios de uno que ya estaba.
class SaveModelUseCase
    extends UseCase<DataState<RecognitionModelEntity>, RecognitionModelEntity> {
  final ModelRepository _repository;

  SaveModelUseCase(this._repository);

  @override
  Future<DataState<RecognitionModelEntity>> call({
    RecognitionModelEntity? params,
  }) {
    return _repository.saveModel(params!);
  }
}
