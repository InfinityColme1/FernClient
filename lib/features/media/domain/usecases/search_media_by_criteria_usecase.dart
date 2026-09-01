import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/media_sort_order.dart';
import 'package:Fern/features/media/domain/entities/search/media_search_section_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_criterion_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Busca el contenido que cumple todas las pastillas de la barra.
///
/// Sustituye a los dos casos de uso que había —buscar por texto y buscar por
/// una sugerencia—, que eran el mismo con una pastilla de una clase o de otra.
/// Lo que se busca y cómo se quiere ver ordenado.
typedef SearchRequest = ({
  List<SearchCriterionEntity> criteria,
  MediaSortOrder order,
});

class SearchMediaByCriteriaUseCase
    extends UseCase<DataState<List<MediaSearchSectionEntity>>, SearchRequest> {
  final LocalMediaRepository _repository;

  SearchMediaByCriteriaUseCase(this._repository);

  @override
  Future<DataState<List<MediaSearchSectionEntity>>> call({
    SearchRequest? params,
  }) {
    return _repository.searchMediaByCriteria(
      params?.criteria ?? const [],
      order: params?.order ?? MediaSortOrder.newestFirst,
    );
  }
}
