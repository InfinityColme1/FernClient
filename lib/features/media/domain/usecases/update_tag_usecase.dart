import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Etiqueta con sus datos nuevos y la etiqueta padre que le toca.
///
/// [parent] manda siempre: con `null` la etiqueta se queda como raíz, no es que
/// se deje su padre como estaba.
class UpdateTagParams {
  final TagEntity tag;
  final TagEntity? parent;

  const UpdateTagParams({required this.tag, this.parent});
}

/// Cambia el nombre, el avatar y el sitio en la jerarquía de una etiqueta que ya
/// existe, y devuelve cómo ha quedado.
class UpdateTagUseCase extends UseCase<DataState<TagEntity>, UpdateTagParams> {
  final LocalMediaRepository _repository;

  UpdateTagUseCase(this._repository);

  @override
  Future<DataState<TagEntity>> call({UpdateTagParams? params}) {
    return _repository.updateTag(params!.tag, parent: params.parent);
  }
}
