import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Guarda un creador (enlaces de redes sociales incluidos) y devuelve el que ha
/// quedado en la base de datos, ya con su identificador definitivo.
class SaveCreatorUseCase extends UseCase<DataState<CreatorEntity>, CreatorEntity> {
  final LocalMediaRepository _repository;

  SaveCreatorUseCase(this._repository);

  @override
  Future<DataState<CreatorEntity>> call({CreatorEntity? params}) {
    return _repository.saveCreator(params!);
  }
}
