import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Qué etiqueta se pone y a qué contenidos.
class AddTagToMediaParams {
  final int tagId;
  final List<int> mediaIds;

  const AddTagToMediaParams({required this.tagId, required this.mediaIds});
}

/// Pone una etiqueta a un puñado de contenidos de una vez.
///
/// Es lo que hace falta para etiquetar en tanda: hasta ahora la única forma de
/// poner la misma etiqueta a treinta contenidos era abrirlos uno a uno.
///
/// Con la etiqueta van las de encima en la jerarquía, porque eso lo resuelve el
/// repositorio y tiene que dar igual por dónde se ponga: la misma acción no
/// puede dar dos resultados distintos según desde qué pantalla se haga.
///
/// Un contenido que falle no para a los demás: en una tanda de treinta, que uno
/// se haya quedado sin fila por medio no puede costar los otros veintinueve.
/// Devuelve a cuántos se les ha puesto.
class AddTagToMediaUseCase extends UseCase<DataState<int>, AddTagToMediaParams> {
  final LocalMediaRepository _repository;

  AddTagToMediaUseCase(this._repository);

  @override
  Future<DataState<int>> call({AddTagToMediaParams? params}) async {
    final asked = params!;
    var tagged = 0;

    for (final mediaId in asked.mediaIds) {
      final result =
          await _repository.addTagsToMedia(mediaId, [asked.tagId]);

      if (result is DataSuccess) tagged++;
    }

    return DataSuccess(tagged);
  }
}
