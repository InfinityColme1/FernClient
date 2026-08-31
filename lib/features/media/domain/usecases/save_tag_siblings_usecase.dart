import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/services/sibling_direction.dart';

/// Qué etiqueta, con quién va y quién arrastra a quién.
class SaveTagSiblingsParams {
  final int tagId;

  /// Cada hermana con su dirección. Las que no estén dejan de serlo.
  final Map<int, SiblingDirection> siblings;

  const SaveTagSiblingsParams({required this.tagId, required this.siblings});
}

/// Deja en una etiqueta las etiquetas relacionadas que se le hayan puesto, con
/// la dirección de cada una.
///
/// La relación es simétrica y el arrastre se escribe en los dos lados; de las
/// dos cosas se encarga el repositorio, así que aquí no hay que acordarse de
/// nada.
class SaveTagSiblingsUseCase
    extends UseCase<DataState<TagEntity>, SaveTagSiblingsParams> {
  final LocalMediaRepository _repository;

  SaveTagSiblingsUseCase(this._repository);

  @override
  Future<DataState<TagEntity>> call({SaveTagSiblingsParams? params}) {
    return _repository.saveTagSiblings(params!.tagId, params.siblings);
  }
}
