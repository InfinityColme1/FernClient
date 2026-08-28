import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Borra las regiones marcadas sobre unos contenidos.
///
/// Lo llama el borrado definitivo, no el paso por la papelera: de la papelera se
/// vuelve, y perder las regiones al restablecer sería perder trabajo de marcado
/// sin haberlo pedido.
class DeleteRegionsOfMediaUseCase extends UseCase<DataState<int>, List<int>> {
  final FernieRepository _repository;

  DeleteRegionsOfMediaUseCase(this._repository);

  @override
  Future<DataState<int>> call({List<int>? params}) {
    return _repository.deleteRegionsOfMedia(params ?? const []);
  }
}
