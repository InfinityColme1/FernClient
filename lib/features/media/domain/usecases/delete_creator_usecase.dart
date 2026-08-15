import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Borra un creador de la base de datos, por su identificador.
///
/// Los contenidos que lo tenían no se borran: pasan al creador desconocido.
class DeleteCreatorUseCase extends UseCase<DataState, int> {
  final LocalMediaRepository _repository;

  DeleteCreatorUseCase(this._repository);

  @override
  Future<DataState> call({int? params}) {
    return _repository.deleteCreator(params!);
  }
}
