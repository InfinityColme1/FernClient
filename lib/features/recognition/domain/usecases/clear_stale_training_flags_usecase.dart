import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';

/// Desatasca los modelos que se quedaron marcados como «entrenando».
///
/// Se llama al arrancar: si el equipo se apagó a media faena, esa marca se
/// habría quedado puesta para siempre y el modelo no se dejaría entrenar nunca
/// más. Devuelve cuántos ha desatascado.
class ClearStaleTrainingFlagsUseCase extends UseCase<DataState<int>, void> {
  final ModelRepository _repository;

  ClearStaleTrainingFlagsUseCase(this._repository);

  @override
  Future<DataState<int>> call({void params}) {
    return _repository.clearStaleTrainingFlags();
  }
}
