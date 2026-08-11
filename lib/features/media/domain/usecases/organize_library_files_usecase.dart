import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Migración de la biblioteca: coloca en su carpeta los ficheros de todo el
/// contenido definitivo. Devuelve cuántos han cambiado de sitio.
class OrganizeLibraryFilesUseCase extends UseCase<DataState<int>, void> {
  final LocalMediaRepository _repository;

  OrganizeLibraryFilesUseCase(this._repository);

  @override
  Future<DataState<int>> call({void params}) {
    return _repository.organizeLibraryFiles();
  }
}
