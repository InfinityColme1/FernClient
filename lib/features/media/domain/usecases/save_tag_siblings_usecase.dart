import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Qué etiqueta y con quién va.
class SaveTagSiblingsParams {
  final int tagId;
  final List<int> siblingIds;

  const SaveTagSiblingsParams({required this.tagId, required this.siblingIds});
}

/// Deja en una etiqueta las etiquetas relacionadas que se le hayan puesto.
///
/// La relación es simétrica y de eso se encarga el repositorio: aquí no hay que
/// acordarse de nada.
class SaveTagSiblingsUseCase
    extends UseCase<DataState<TagEntity>, SaveTagSiblingsParams> {
  final LocalMediaRepository _repository;

  SaveTagSiblingsUseCase(this._repository);

  @override
  Future<DataState<TagEntity>> call({SaveTagSiblingsParams? params}) {
    return _repository.saveTagSiblings(params!.tagId, params.siblingIds);
  }
}
