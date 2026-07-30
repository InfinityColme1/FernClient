import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import '../../../../core/resources/data_state.dart';


abstract class LocalMediaRepository {

  Stream<DataState<MediaSummaryEntity>> selectAndScanDirectory(String rootPath);

  Stream<DataState<MediaSummaryEntity>> scanDirectory(String rootPath);

  Future<DataState> saveScannedMedia(List<MediaEntity> mediaList);
  
  Future<DataState> saveMedia(MediaEntity media);

  Future<DataState<List<MediaSummaryEntity>>> getMediaList();

  Future<DataState<MediaEntity>> getMediaDetails(int id);
  
  Future<DataState> deleteMedia(int id);
}