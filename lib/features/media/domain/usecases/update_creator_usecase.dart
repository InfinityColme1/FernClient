import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Cambia el nombre, el avatar y los enlaces de un creador que ya existe, y
/// devuelve cómo ha quedado.
class UpdateCreatorUseCase
    extends UseCase<DataState<CreatorEntity>, CreatorEntity> {
  final LocalMediaRepository _repository;

  UpdateCreatorUseCase(this._repository);

  @override
  Future<DataState<CreatorEntity>> call({CreatorEntity? params}) {
    return _repository.updateCreator(params!);
  }
}
