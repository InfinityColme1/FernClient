import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

class ScanDirectoryUseCase extends UseCase<Stream<DataState<MediaSummaryEntity>>, void> {
  final LocalMediaRepository _localMediaRepository;
  final PreferencesService _preferencesService;

  ScanDirectoryUseCase({
    required this._localMediaRepository,
    required this._preferencesService
  });

  @override
  Future<Stream<DataState<MediaSummaryEntity>>> call({void params}) async {
    final rootPath = _preferencesService.getRootPath();
    
    if (rootPath == null || rootPath.isEmpty) {
      return Stream.value(DataException(Exception("No directory selected in preferences.")));
    }

    return _localMediaRepository.scanDirectory(rootPath);
  }
}
