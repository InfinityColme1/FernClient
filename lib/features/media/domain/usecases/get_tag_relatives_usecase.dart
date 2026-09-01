import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Lo que viene con unas etiquetas al ponerlas: sus hermanas y su rama.
///
/// Es lo que deja a los diálogos enseñarlo según se elige. El etiquetado
/// automático las pone igualmente —al importar, al aceptar una sugerencia, al
/// marcar un fernie—, así que sin esto aparecerían sin avisar; y peor: puestas a
/// mano no aparecían en absoluto, porque guardar desde el panel escribe la lista
/// tal cual se deja.
class GetTagRelativesUseCase
    extends UseCase<DataState<List<TagEntity>>, List<TagEntity>> {
  final LocalMediaRepository _repository;

  GetTagRelativesUseCase(this._repository);

  @override
  Future<DataState<List<TagEntity>>> call({List<TagEntity>? params}) {
    return _repository.getTagRelatives(params ?? const []);
  }
}
