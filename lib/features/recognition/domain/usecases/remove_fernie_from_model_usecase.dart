import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';

/// Saca un fernie de un modelo. Su número de clase queda libre pero no se
/// reutiliza: los pesos entrenados lo conocían por ese número.
class RemoveFernieFromModelUseCase extends UseCase<DataState<bool>, int> {
  final ModelRepository _repository;

  RemoveFernieFromModelUseCase(this._repository);

  @override
  Future<DataState<bool>> call({int? params}) {
    return _repository.removeFernie(params!);
  }
}
