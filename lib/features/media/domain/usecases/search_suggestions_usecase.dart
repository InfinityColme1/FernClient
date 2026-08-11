import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Sugerencias del buscador principal: contenidos, etiquetas y creadores que se
/// parecen al texto escrito. Con el texto vacío devuelve una lista vacía.
class SearchSuggestionsUseCase
    extends UseCase<DataState<List<SearchSuggestionEntity>>, String> {
  final LocalMediaRepository _repository;

  SearchSuggestionsUseCase(this._repository);

  @override
  Future<DataState<List<SearchSuggestionEntity>>> call({String? params}) {
    return _repository.searchSuggestions(params ?? '');
  }
}
