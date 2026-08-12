import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Marca contenido para borrar: es lo que hace el botón de eliminar en
/// cualquier pantalla que no sea la de eliminados. Nada sale de la base de
/// datos todavía.
class MarkMediaDeletedUseCase extends UseCase<DataState, List<int>> {
  final LocalMediaRepository _repository;

  MarkMediaDeletedUseCase(this._repository);

  @override
  Future<DataState> call({List<int>? params}) {
    return _repository.markMediaListAsDeleted(params ?? const []);
  }
}
