import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Etiquetas que se parecen al texto escrito, para las sugerencias de los
/// buscadores. Con el texto vacío devuelve una lista vacía.
class SearchTagsUseCase extends UseCase<DataState<List<TagEntity>>, String> {
  final LocalMediaRepository _repository;

  SearchTagsUseCase(this._repository);

  @override
  Future<DataState<List<TagEntity>>> call({String? params}) {
    return _repository.searchTags(params ?? '');
  }
}
