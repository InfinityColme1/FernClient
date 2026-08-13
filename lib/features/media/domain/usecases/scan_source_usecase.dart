import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/repositories/remote_media_repository.dart';

/// Lo que se le pide a un escaneo: de dónde traer contenido y hasta dónde.
///
/// [limit] es el número de contenidos **nuevos** tras el que se para;
/// [unlimitedImportLimit] es traerse todo lo que haya y [untilLastImportLimit]
/// es parar donde se quedó la importación anterior.
typedef ScanSourceParams = ({ImportSource source, int limit});

/// Busca contenido nuevo en la fuente elegida en la pantalla de importación.
///
/// Con [ImportSource.all] se recorren todas, una detrás de otra: es lo que hace
/// que esa opción no sea sólo un filtro de la rejilla, sino también un escaneo
/// completo.
///
/// Lo que devuelve es el mismo flujo de siempre, así que a la pantalla le da
/// igual si el contenido sale del disco o de una API: va llegando de uno en uno
/// y ella lo va pintando.
class ScanSourceUseCase
    extends UseCase<Stream<DataState<MediaSummaryEntity>>, ScanSourceParams> {
  final LocalMediaRepository _localMediaRepository;
  final RemoteMediaRepository _remoteMediaRepository;
  final PreferencesService _preferencesService;

  ScanSourceUseCase({
    required LocalMediaRepository localMediaRepository,
    required RemoteMediaRepository remoteMediaRepository,
    required PreferencesService preferencesService,
  })  : _localMediaRepository = localMediaRepository,
        _remoteMediaRepository = remoteMediaRepository,
        _preferencesService = preferencesService;

  @override
  Future<Stream<DataState<MediaSummaryEntity>>> call({
    ScanSourceParams? params,
  }) async {
    final source = params?.source ?? ImportSource.local;
    final limit = params?.limit ?? unlimitedImportLimit;

    return _scan(source.sources, limit);
  }

  /// Si [limit] es una cuenta de contenidos y no una forma de parar.
  bool _isCount(int limit) =>
      limit != unlimitedImportLimit && limit != untilLastImportLimit;

  /// Recorre las fuentes en orden y va soltando lo que encuentra cada una.
  ///
  /// El corte por [limit] cuenta los contenidos nuevos de todo el escaneo, no
  /// los de cada fuente: pedir diez con "todas" elegido son diez en total, y en
  /// cuanto se llega se deja de buscar (la fuente que estuviera a medias se
  /// corta ahí mismo, sin descargar de más).
  ///
  /// "Desde la última vez" no se cuenta aquí: no es un número, es un punto de
  /// parada que sólo conoce cada fuente. Se le pasa a la remota, y en el equipo
  /// no significa nada (un escaneo del disco ya recoge sólo lo que no estaba),
  /// así que ahí se recorre todo igual.
  ///
  /// Un fallo de una fuente no corta a las demás: llega como tal y se sigue con
  /// la siguiente.
  Stream<DataState<MediaSummaryEntity>> _scan(
    List<ImportSource> sources,
    int limit,
  ) async* {
    var fetched = 0;

    for (final source in sources) {
      final stream = switch (source) {
        ImportSource.local => _scanLocal(),
        _ => _remoteMediaRepository.scanRemoteSource(
            source,
            untilLastImport: limit == untilLastImportLimit,
          ),
      };

      await for (final result in stream) {
        yield result;

        if (result is! DataSuccess) continue;

        fetched++;
        if (_isCount(limit) && fetched >= limit) {
          await _preferencesService.setLastImport(source, DateTime.now());
          return;
        }
      }

      // La fuente se ha recorrido entera: desde ahora, lo que se está viendo de
      // ella es lo que había en este momento.
      await _preferencesService.setLastImport(source, DateTime.now());
    }
  }

  /// El escaneo del equipo va sobre la última carpeta elegida; mientras no se
  /// haya elegido ninguna no hay nada que recorrer.
  Stream<DataState<MediaSummaryEntity>> _scanLocal() {
    final rootPath = _preferencesService.getRootPath();

    if (rootPath == null || rootPath.isEmpty) {
      return Stream.value(
        DataException(Exception('No directory selected in preferences.')),
      );
    }

    return _localMediaRepository.scanDirectory(rootPath);
  }
}
