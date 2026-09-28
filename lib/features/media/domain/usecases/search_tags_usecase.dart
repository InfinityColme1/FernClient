import 'package:Fern/core/constants/app_constants.dart';
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

  /// Lo mismo, sin las de [excluded], y **con todos los huecos llenos**.
  ///
  /// Quitándolas después de buscar, las que ya estaban puestas se comían sitio
  /// de las sugerencias: con dos de las tres primeras ya asignadas, se ofrecía
  /// una sola aunque hubiera más que encajaban. Se piden de más y se recorta
  /// después de quitarlas.
  Future<DataState<List<TagEntity>>> excluding(
    String query,
    Set<int> excluded,
  ) async {
    final result = await _repository.searchTags(
      query,
      limit: searchSuggestionsLimit + excluded.length,
    );
    if (result is! DataSuccess) return result;

    return DataSuccess([
      for (final tag in result.data ?? const <TagEntity>[])
        if (!excluded.contains(tag.id)) tag,
    ].take(searchSuggestionsLimit).toList());
  }
}
