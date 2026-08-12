import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Vaciado automático de la papelera: lo que lleva más de una semana marcado
/// sale de la base de datos. Devuelve cuántos contenidos se han borrado.
class PurgeExpiredDeletedMediaUseCase extends UseCase<DataState<int>, void> {
  final LocalMediaRepository _repository;

  PurgeExpiredDeletedMediaUseCase(this._repository);

  @override
  Future<DataState<int>> call({void params}) {
    return _repository.purgeExpiredDeletedMedia();
  }
}
