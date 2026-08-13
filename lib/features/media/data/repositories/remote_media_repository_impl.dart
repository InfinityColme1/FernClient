import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/data/datasources/reddit_api_client.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/remote_media_downloader.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/remote_media_repository.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';

/// Las fuentes remotas de la aplicación. Por ahora sólo Reddit.
///
/// El recorrido es siempre el mismo, dé igual la plataforma: se pregunta a su
/// API qué tiene guardado el usuario, se descarga lo que aún no está en el
/// equipo y se da de alta con el registro, que es por donde entra también lo
/// que se escanea del disco.
class RemoteMediaRepositoryImpl implements RemoteMediaRepository {
  final RedditApiClient _reddit;
  final RemoteMediaDownloader _downloader;
  final MediaRegistry _registry;
  final SettingsRepository _settingsRepository;
  final PreferencesService _preferencesService;

  RemoteMediaRepositoryImpl({
    required RedditApiClient reddit,
    required RemoteMediaDownloader downloader,
    required MediaRegistry registry,
    required SettingsRepository settingsRepository,
    required PreferencesService preferencesService,
  })  : _reddit = reddit,
        _downloader = downloader,
        _registry = registry,
        _settingsRepository = settingsRepository,
        _preferencesService = preferencesService;

  @override
  Stream<DataState<MediaSummaryEntity>> scanRemoteSource(
    ImportSource source, {
    bool untilLastImport = false,
  }) async* {
    switch (source) {
      case ImportSource.reddit:
        yield* _scanReddit(untilLastImport: untilLastImport);
      case ImportSource.all:
      case ImportSource.local:
        yield DataException(
          Exception('${source.id} is not a remote source'),
        );
    }
  }

  /// Lo guardado en la cuenta de Reddit del usuario.
  ///
  /// Cada publicación puede dar más de un fichero (una galería son varias
  /// imágenes) y cada fichero acaba siendo un contenido: se descarga, se da de
  /// alta con el título de la publicación como descripción y se devuelve para
  /// que la rejilla lo pinte sin esperar a que acabe el resto.
  ///
  /// Lo que no se puede descargar (un enlace a una web sin vídeo dentro, una
  /// descarga que falla) se pasa por alto: es contenido que no llega, no un
  /// fallo de la importación.
  ///
  /// Reddit no dice cuándo se guardó cada cosa, pero sí devuelve lo guardado de
  /// lo más reciente a lo más antiguo, así que "desde la última vez" se resuelve
  /// con una marca: se recuerda la publicación más nueva de cada importación y
  /// la siguiente para al volver a encontrarla.
  ///
  /// La marca sólo se mueve si el recorrido llega hasta el final. Si se corta
  /// antes (por el tope de la cabecera, o porque quien escucha se va), no se
  /// toca: dejarla en lo más nuevo daría por importado lo que se ha quedado sin
  /// mirar.
  Stream<DataState<MediaSummaryEntity>> _scanReddit({
    required bool untilLastImport,
  }) async* {
    final credentials = _settingsRepository.getSettings().reddit;
    if (!credentials.isComplete) {
      yield DataException(Exception('Reddit is not configured'));
      return;
    }

    final marker = untilLastImport
        ? _preferencesService.getLastImportMarker(ImportSource.reddit)
        : null;
    String? newest;

    try {
      await for (final item in _reddit.savedMedia(credentials)) {
        // Lo primero que llega es lo más nuevo que hay en la cuenta: eso es lo
        // que quedará como marca cuando el recorrido termine.
        newest ??= item.postId;

        // Aquí se quedó la vez anterior: de este punto para atrás ya se miró.
        if (item.postId == marker) break;

        final path = await _downloader.download(
          url: item.url,
          name: item.id,
          source: ImportSource.reddit,
        );
        if (path == null) continue;

        final summary = await _registry.register(
          path: path,
          source: ImportSource.reddit,
          description: item.title.isEmpty ? null : item.title,
          sourceTagName: redditSourceTagName,
        );
        if (summary != null) yield DataSuccess(summary);
      }
    } on Exception catch (e) {
      yield DataException(e);
      return;
    }

    if (newest != null) {
      await _preferencesService.setLastImportMarker(ImportSource.reddit, newest);
    }
  }
}
