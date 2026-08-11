import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/search/media_search_section_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import '../../../../core/resources/data_state.dart';


abstract class LocalMediaRepository {

  Stream<DataState<MediaSummaryEntity>> selectAndScanDirectory(String rootPath);

  Stream<DataState<MediaSummaryEntity>> scanDirectory(String rootPath);

  Future<DataState> saveScannedMedia(List<MediaEntity> mediaList);
  
  Future<DataState> saveMedia(MediaEntity media);

  Future<DataState<List<MediaSummaryEntity>>> getMediaList();

  Future<DataState<List<MediaSummaryEntity>>> getScannedMedia();

  Future<DataState<MediaEntity>> getMediaDetails(int id);
  
  Future<DataState> deleteMedia(int id);

  /// Borra de la base de datos todos los contenidos indicados.
  Future<DataState> deleteMediaList(List<int> ids);

  /// Marca como definitivos los contenidos indicados dejando sus detalles tal
  /// y como están (los del escaneo si nadie los ha revisado).
  Future<DataState> confirmMediaList(List<int> ids);

  /// Guarda la etiqueta y, si se indica [parent], la cuelga de ella.
  Future<DataState<TagEntity>> saveTag(TagEntity tag, {TagEntity? parent});

  Future<DataState<CreatorEntity>> saveCreator(CreatorEntity creator);
  
  Future<DataState<List<TagEntity>>> getTags();

  Future<DataState<List<CreatorEntity>>> getCreators();

  /// Etiquetas cuyo nombre se parece a [query], como mucho [limit].
  Future<DataState<List<TagEntity>>> searchTags(String query, {int limit});

  /// Creadores cuyo nombre se parece a [query], como mucho [limit].
  Future<DataState<List<CreatorEntity>>> searchCreators(String query, {int limit});

  /// Sugerencias del buscador principal: contenidos (por su descripción),
  /// etiquetas y creadores que se parecen a [query], como mucho [limit] en
  /// total.
  Future<DataState<List<SearchSuggestionEntity>>> searchSuggestions(
    String query, {
    int limit,
  });

  /// Contenido definitivo que responde a [query], agrupado para la rejilla:
  /// primero las coincidencias por descripción, luego un grupo por cada
  /// etiqueta que encaje y por último uno por cada creador.
  Future<DataState<List<MediaSearchSectionEntity>>> searchMedia(String query);

  /// Contenido de **una** sugerencia concreta: sólo el de esa etiqueta, ese
  /// creador o ese contenido, sin arrastrar lo que se parezca a su nombre.
  Future<DataState<List<MediaSearchSectionEntity>>> searchMediaBySuggestion(
    SearchSuggestionEntity suggestion,
  );
}