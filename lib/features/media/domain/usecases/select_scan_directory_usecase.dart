import 'package:Fern/core/resources/data_state.dart';import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:file_picker/file_picker.dart';

class SelectAndScanDirectoryUsecase extends UseCase<Stream<DataState<MediaSummaryEntity>>, void> {
  final LocalMediaRepository _localMediaRepository;
  final PreferencesService _preferencesService;

  SelectAndScanDirectoryUsecase({
    required LocalMediaRepository localMediaRepository,
    required PreferencesService preferencesService,
  })  : _localMediaRepository = localMediaRepository,
        _preferencesService = preferencesService;

  @override
  Future<Stream<DataState<MediaSummaryEntity>>> call({void params}) async {

    String? selectedDirectory = await FilePicker.getDirectoryPath();

    if (selectedDirectory != null) {
      await _preferencesService.setRootPath(selectedDirectory);
      return _localMediaRepository.selectAndScanDirectory(selectedDirectory);
    } else {

      return const Stream.empty();
    }
  }
}