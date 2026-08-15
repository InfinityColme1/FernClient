import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Todos los creadores de la aplicación. Es lo que lista la pantalla de gestión
/// de creadores.
class GetCreatorsUseCase extends UseCase<DataState<List<CreatorEntity>>, void> {
  final LocalMediaRepository _repository;

  GetCreatorsUseCase(this._repository);

  @override
  Future<DataState<List<CreatorEntity>>> call({void params}) {
    return _repository.getCreators();
  }
}
