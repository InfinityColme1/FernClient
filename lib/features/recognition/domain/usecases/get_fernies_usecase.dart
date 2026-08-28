import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Todos los fernies de la aplicación, cada uno con el recuento de regiones y de
/// contenidos distintos en los que están marcadas.
///
/// Menos los que ahora mismo no se pueden enseñar. **El filtro va aquí y no en
/// el repositorio** a propósito: por el repositorio lee también quien trabaja
/// —el conjunto de datos con el que se entrena, el recorrido que reconoce—, y
/// eso tiene que seguir viéndolos todos, o marcar un fernie rompería el modelo
/// que lo usa. Los casos de uso son lo que mira la interfaz.
class GetFerniesUseCase extends UseCase<DataState<List<FernieEntity>>, void> {
  final FernieRepository _repository;
  final ContentVisibility _visibility;

  GetFerniesUseCase(
    this._repository, {
    ContentVisibility visibility = const ContentVisibility(),
  }) : _visibility = visibility;

  @override
  Future<DataState<List<FernieEntity>>> call({void params}) async {
    final result = await _repository.getFernies();
    if (result is! DataSuccess) return result;

    return DataSuccess([
      for (final fernie in result.data ?? const <FernieEntity>[])
        if (!_visibility.hidesFernie(fernie.id)) fernie,
    ]);
  }
}
