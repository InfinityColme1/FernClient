import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/search/media_search_section_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Búsqueda de contenido para la rejilla de la pantalla de media, agrupada por
/// descripción, etiqueta y creador. Con el texto vacío no devuelve grupos.
class SearchMediaUseCase
    extends UseCase<DataState<List<MediaSearchSectionEntity>>, String> {
  final LocalMediaRepository _repository;

  SearchMediaUseCase(this._repository);

  @override
  Future<DataState<List<MediaSearchSectionEntity>>> call({String? params}) {
    return _repository.searchMedia(params ?? '');
  }
}
