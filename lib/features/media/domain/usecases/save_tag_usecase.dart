import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Etiqueta a guardar y, opcionalmente, la etiqueta padre de la que cuelga.
class SaveTagParams {
  final TagEntity tag;
  final TagEntity? parent;

  const SaveTagParams({required this.tag, this.parent});
}

/// Guarda una etiqueta y devuelve la que ha quedado en la base de datos, ya con
/// su identificador definitivo.
class SaveTagUseCase extends UseCase<DataState<TagEntity>, SaveTagParams> {
  final LocalMediaRepository _repository;

  SaveTagUseCase(this._repository);

  @override
  Future<DataState<TagEntity>> call({SaveTagParams? params}) {
    return _repository.saveTag(params!.tag, parent: params.parent);
  }
}
