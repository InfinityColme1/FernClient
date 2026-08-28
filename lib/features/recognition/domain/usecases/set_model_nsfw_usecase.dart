import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';

class SetModelNsfwParams {
  final int modelId;
  final bool isNsfw;

  const SetModelNsfwParams({required this.modelId, required this.isNsfw});
}

/// Marca o desmarca un modelo como contenido no apto.
///
/// **No lo desconecta de nada.** Un modelo marcado se sigue entrenando, sigue
/// colgando de donde colgara en el árbol y sigue reconociendo exactamente igual;
/// lo que cambia es que con el filtro puesto no se ve ni él ni la lista de sus
/// fernies.
class SetModelNsfwUseCase extends UseCase<DataState<bool>, SetModelNsfwParams> {
  final ModelRepository _repository;

  SetModelNsfwUseCase(this._repository);

  @override
  Future<DataState<bool>> call({SetModelNsfwParams? params}) {
    return _repository.setModelNsfw(params!.modelId, isNsfw: params.isNsfw);
  }
}
