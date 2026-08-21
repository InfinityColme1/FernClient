import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';

/// Un modelo por su identificador.
class GetModelUseCase extends UseCase<DataState<RecognitionModelEntity>, int> {
  final ModelRepository _repository;

  GetModelUseCase(this._repository);

  @override
  Future<DataState<RecognitionModelEntity>> call({int? params}) {
    return _repository.getModel(params!);
  }
}
