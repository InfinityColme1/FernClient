import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/search/media_search_section_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Contenido de la sugerencia elegida en el buscador: sólo el de esa etiqueta,
/// ese creador o ese contenido.
class SearchMediaBySuggestionUseCase extends UseCase<
    DataState<List<MediaSearchSectionEntity>>, SearchSuggestionEntity> {
  final LocalMediaRepository _repository;

  SearchMediaBySuggestionUseCase(this._repository);

  @override
  Future<DataState<List<MediaSearchSectionEntity>>> call({
    SearchSuggestionEntity? params,
  }) async {
    if (params == null) return const DataSuccess([]);

    return _repository.searchMediaBySuggestion(params);
  }
}
