import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';

/// Todos los modelos, cada uno con cuántos fernies y cuántas regiones suma.
class GetModelsUseCase
    extends UseCase<DataState<List<RecognitionModelEntity>>, void> {
  final ModelRepository _repository;

  GetModelsUseCase(this._repository);

  @override
  Future<DataState<List<RecognitionModelEntity>>> call({void params}) {
    return _repository.getModels();
  }
}
