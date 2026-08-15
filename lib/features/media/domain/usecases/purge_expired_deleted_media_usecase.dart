import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Vaciado automático de la papelera: lo que lleva más de una semana marcado
/// sale de la base de datos. Devuelve cuántos contenidos se han borrado.
///
/// [params] dice si los ficheros se van con ellos. Como aquí no se pregunta
/// nada, quien llama pasa lo último que el usuario eligió al vaciarla a mano.
class PurgeExpiredDeletedMediaUseCase extends UseCase<DataState<int>, bool> {
  final LocalMediaRepository _repository;

  PurgeExpiredDeletedMediaUseCase(this._repository);

  @override
  Future<DataState<int>> call({bool? params}) {
    return _repository.purgeExpiredDeletedMedia(deleteFiles: params ?? false);
  }
}
