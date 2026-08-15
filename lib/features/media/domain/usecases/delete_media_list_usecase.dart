import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Contenidos a borrar y si sus ficheros se van con ellos, que es lo que el
/// usuario ha dicho en el aviso.
typedef MediaDeletion = ({List<int> ids, bool deleteFiles});

/// Borrado real de varios contenidos: el de lo que se descarta en importación,
/// que no pasa por la papelera porque nunca llegó a ser definitivo.
class DeleteMediaListUseCase extends UseCase<DataState, MediaDeletion> {
  final LocalMediaRepository _repository;

  DeleteMediaListUseCase(this._repository);

  @override
  Future<DataState> call({MediaDeletion? params}) {
    return _repository.deleteMediaList(
      params?.ids ?? const [],
      deleteFiles: params?.deleteFiles ?? false,
    );
  }
}
