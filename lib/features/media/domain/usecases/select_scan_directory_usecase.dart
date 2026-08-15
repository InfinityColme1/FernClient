import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/import_cancellation.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:file_picker/file_picker.dart';

/// Elige otra carpeta del equipo y la escanea.
///
/// Es siempre la fuente local: lo que cambia respecto a [ScanSourceUseCase] es
/// que la carpeta se pregunta en el momento y se recuerda como la de la próxima
/// vez. El tope de contenidos nuevos se respeta igual, que es el que hay puesto
/// en la cabecera.
class SelectAndScanDirectoryUsecase
    extends UseCase<Stream<DataState<MediaSummaryEntity>>, int> {
  final LocalMediaRepository _localMediaRepository;
  final PreferencesService _preferencesService;
  final ImportCancellation _cancellation;

  SelectAndScanDirectoryUsecase({
    required LocalMediaRepository localMediaRepository,
    required PreferencesService preferencesService,
    required ImportCancellation cancellation,
  })  : _localMediaRepository = localMediaRepository,
        _preferencesService = preferencesService,
        _cancellation = cancellation;

  @override
  Future<Stream<DataState<MediaSummaryEntity>>> call({int? params}) async {
    final String? selectedDirectory = await FilePicker.getDirectoryPath();
    if (selectedDirectory == null) return const Stream.empty();

    await _preferencesService.setRootPath(selectedDirectory);

    return _scan(selectedDirectory, params ?? unlimitedImportLimit);
  }

  /// Si [limit] es una cuenta de contenidos. "Todos" y "desde la última vez" no
  /// lo son: en una carpeta del equipo las dos cosas significan lo mismo, porque
  /// un escaneo ya recoge sólo los ficheros que no estaban.
  bool _isCount(int limit) =>
      limit != unlimitedImportLimit && limit != untilLastImportLimit;

  Stream<DataState<MediaSummaryEntity>> _scan(String directory, int limit) async* {
    var fetched = 0;

    await for (final result
        in _localMediaRepository.selectAndScanDirectory(directory)) {
      yield result;

      // Igual que en el escaneo de una fuente: parar es terminar antes, así
      // que se sale del recorrido y la carpeta se sella con su fecha.
      if (_cancellation.isCancelled) break;

      if (result is! DataSuccess) continue;

      fetched++;
      if (_isCount(limit) && fetched >= limit) break;
    }

    await _preferencesService.setLastImport(ImportSource.local, DateTime.now());
  }
}
