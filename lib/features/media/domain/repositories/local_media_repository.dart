import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
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

  /// Guarda la etiqueta y, si se indica [parent], la cuelga de ella.
  Future<DataState<TagEntity>> saveTag(TagEntity tag, {TagEntity? parent});

  Future<DataState<CreatorEntity>> saveCreator(CreatorEntity creator);
  
  Future<DataState<List<TagEntity>>> getTags();

  Future<DataState<List<CreatorEntity>>> getCreators();

  /// Etiquetas cuyo nombre se parece a [query], como mucho [limit].
  Future<DataState<List<TagEntity>>> searchTags(String query, {int limit});

  /// Creadores cuyo nombre se parece a [query], como mucho [limit].
  Future<DataState<List<CreatorEntity>>> searchCreators(String query, {int limit});
}