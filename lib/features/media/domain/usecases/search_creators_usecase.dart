import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Creadores que se parecen al texto escrito, para las sugerencias de los
/// buscadores. Con el texto vacío devuelve una lista vacía.
class SearchCreatorsUseCase
    extends UseCase<DataState<List<CreatorEntity>>, String> {
  final LocalMediaRepository _repository;

  SearchCreatorsUseCase(this._repository);

  @override
  Future<DataState<List<CreatorEntity>>> call({String? params}) {
    return _repository.searchCreators(params ?? '');
  }
}
