import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Retira de la base de datos un contenido cuyo fichero ha desaparecido.
///
/// Se dispara cuando la aplicación intenta pintar el contenido y no lo
/// consigue; es el repositorio el que decide si el motivo es que el fichero se
/// ha borrado o movido, así que un fallo de carga por cualquier otro motivo no
/// borra nada.
///
/// Devuelve `true` si la fila se ha borrado.
class DeleteMissingMediaUseCase extends UseCase<DataState<bool>, int> {
  final LocalMediaRepository _repository;

  DeleteMissingMediaUseCase(this._repository);

  @override
  Future<DataState<bool>> call({int? params}) {
    return _repository.deleteMissingMedia(params!);
  }
}
