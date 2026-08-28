import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';

/// Los fernies metidos en un modelo, con su reparto y su número de clase.
///
/// Los escondidos no se listan, pero **siguen metidos**: su número de clase no
/// se toca y el modelo se entrena con ellos igual que antes. Lo único que se
/// pierde con el filtro puesto es verlos y poder tocarles el reparto.
class GetFerniesOfModelUseCase
    extends UseCase<DataState<List<ModelFernieEntity>>, int> {
  final ModelRepository _repository;
  final ContentVisibility _visibility;

  GetFerniesOfModelUseCase(
    this._repository, {
    ContentVisibility visibility = const ContentVisibility(),
  }) : _visibility = visibility;

  @override
  Future<DataState<List<ModelFernieEntity>>> call({int? params}) async {
    final result = await _repository.getFerniesOfModel(params!);
    if (result is! DataSuccess) return result;

    return DataSuccess([
      for (final assignment in result.data ?? const <ModelFernieEntity>[])
        if (!_visibility.hidesFernie(assignment.fernie.id)) assignment,
    ]);
  }
}
