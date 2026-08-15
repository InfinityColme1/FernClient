import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/data/datasources/pixiv_api_client.dart';
import 'package:Fern/features/media/data/datasources/reddit_api_client.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/remote_media_downloader.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/remote_media_repository.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';

/// Las fuentes remotas de la aplicación: Reddit y Pixiv.
///
/// El recorrido es siempre el mismo, dé igual la plataforma: se pregunta a su
/// API qué tiene guardado el usuario, se descarga lo que aún no está en el
/// equipo y se da de alta con el registro, que es por donde entra también lo
/// que se escanea del disco.
class RemoteMediaRepositoryImpl implements RemoteMediaRepository {
  final RedditApiClient _reddit;
  final PixivApiClient _pixiv;
  final RemoteMediaDownloader _downloader;
  final MediaRegistry _registry;
  final SettingsRepository _settingsRepository;
  final PreferencesService _preferencesService;

  RemoteMediaRepositoryImpl({
    required RedditApiClient reddit,
    required PixivApiClient pixiv,
    required RemoteMediaDownloader downloader,
    required MediaRegistry registry,
    required SettingsRepository settingsRepository,
    required PreferencesService preferencesService,
  })  : _reddit = reddit,
        _pixiv = pixiv,
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
      case ImportSource.pixiv:
        yield* _scanPixiv(untilLastImport: untilLastImport);
      case ImportSource.all:
      case ImportSource.local:
      // El navegador tampoco: de él no se puede pedir nada, es el usuario quien
      // trae el contenido página a página.
      case ImportSource.browser:
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
    final settings = _settingsRepository.getSettings();
    final credentials = settings.reddit;
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
          // La etiqueta de la plataforma sólo si el usuario la ha pedido: por
          // defecto la fuente se guarda en el sumario y se filtra por ella, sin
          // llenar el menú lateral de etiquetas que no ha creado nadie.
          sourceTagName:
              settings.autoTagRemoteSource ? redditSourceTagName : null,
          sourceUrls: item.sourceUrls,
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

  /// Lo marcado en la cuenta de Pixiv del usuario, tanto lo público como lo
  /// privado.
  ///
  /// Funciona igual que lo de Reddit, y por lo mismo: Pixiv tampoco dice cuándo
  /// se marcó cada obra, pero sí devuelve lo marcado de lo más reciente a lo más
  /// antiguo, así que "desde la última vez" se resuelve con una marca.
  ///
  /// La diferencia está en que aquí no hay un listado sino dos, el de marcadores
  /// públicos y el de privados, y cada uno se recorre por su cuenta de lo más
  /// nuevo a lo más antiguo. Por eso hay una marca por listado: una sola pararía
  /// el segundo recorrido en la obra en la que se quedó el primero, que no tiene
  /// nada que ver.
  ///
  /// Las marcas sólo se guardan si el recorrido llega hasta el final, igual que
  /// en Reddit: si se corta antes, dejarlas en lo más nuevo daría por importado
  /// lo que se ha quedado sin mirar.
  Stream<DataState<MediaSummaryEntity>> _scanPixiv({
    required bool untilLastImport,
  }) async* {
    final settings = _settingsRepository.getSettings();
    final credentials = settings.pixiv;
    if (!credentials.isComplete) {
      yield DataException(Exception('Pixiv is not configured'));
      return;
    }

    final markers = <String, String>{
      if (untilLastImport)
        for (final collection in pixivBookmarkCollections)
          if (_preferencesService.getLastImportMarker(
                ImportSource.pixiv,
                collection: collection,
              )
              case final marker?)
            collection: marker,
    };

    // Lo más nuevo que había en cada listado al empezar, que es lo que quedará
    // como marca cuando el recorrido termine.
    final newest = <String, String>{};

    try {
      await for (final item
          in _pixiv.bookmarkedMedia(credentials, stopAt: markers)) {
        final collection = item.collection;
        if (collection != null) newest.putIfAbsent(collection, () => item.postId);

        final path = await _downloader.download(
          url: item.url,
          name: item.id,
          source: ImportSource.pixiv,
          // Su servidor de contenidos sólo da la imagen a quien dice venir de
          // su web, y eso sólo lo sabe la fuente que dio la dirección.
          headers: item.headers,
          // Las animaciones no vienen como fichero sino como un paquete de
          // fotogramas, y hay que montarlas al descargarlas.
          frameDelays: item.frameDelays,
        );
        if (path == null) continue;

        final summary = await _registry.register(
          path: path,
          source: ImportSource.pixiv,
          description: item.title.isEmpty ? null : item.title,
          sourceTagName:
              settings.autoTagRemoteSource ? pixivSourceTagName : null,
          sourceUrls: item.sourceUrls,
        );
        if (summary != null) yield DataSuccess(summary);
      }
    } on Exception catch (e) {
      yield DataException(e);
      return;
    }

    for (final entry in newest.entries) {
      await _preferencesService.setLastImportMarker(
        ImportSource.pixiv,
        entry.value,
        collection: entry.key,
      );
    }
  }
}
