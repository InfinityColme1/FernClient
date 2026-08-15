import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Borrado definitivo de todo lo marcado, el que se fuerza desde la pantalla de
/// eliminados. Devuelve cuántos contenidos han salido de la base de datos.
///
/// [params] dice si los ficheros se van con ellos.
class PurgeDeletedMediaUseCase extends UseCase<DataState<int>, bool> {
  final LocalMediaRepository _repository;

  PurgeDeletedMediaUseCase(this._repository);

  @override
  Future<DataState<int>> call({bool? params}) {
    return _repository.purgeDeletedMedia(deleteFiles: params ?? false);
  }
}
