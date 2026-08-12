import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Borrado real de varios contenidos: el de lo que se descarta en importación,
/// que no pasa por la papelera porque nunca llegó a ser definitivo.
class DeleteMediaListUseCase extends UseCase<DataState, List<int>> {
  final LocalMediaRepository _repository;

  DeleteMediaListUseCase(this._repository);

  @override
  Future<DataState> call({List<int>? params}) {
    return _repository.deleteMediaList(params ?? const []);
  }
}
