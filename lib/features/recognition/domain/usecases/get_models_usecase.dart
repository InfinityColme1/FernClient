import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';

/// Todos los modelos, cada uno con cuántos fernies y cuántas regiones suma.
///
/// Menos los escondidos. Como con los fernies, el filtro va aquí y no en el
/// repositorio: el entrenamiento y el recorrido del árbol leen por allí y tienen
/// que seguir viéndolos todos.
class GetModelsUseCase
    extends UseCase<DataState<List<RecognitionModelEntity>>, void> {
  final ModelRepository _repository;
  final ContentVisibility _visibility;

  GetModelsUseCase(
    this._repository, {
    ContentVisibility visibility = const ContentVisibility(),
  }) : _visibility = visibility;

  @override
  Future<DataState<List<RecognitionModelEntity>>> call({void params}) async {
    final result = await _repository.getModels();
    if (result is! DataSuccess) return result;

    return DataSuccess([
      for (final model in result.data ?? const <RecognitionModelEntity>[])
        if (!_visibility.hidesModel(model.id)) model,
    ]);
  }
}
