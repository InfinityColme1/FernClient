import 'dart:async';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/data/datasources/danbooru_api_client.dart';
import 'package:Fern/features/media/data/datasources/gelbooru_api_client.dart';
import 'package:Fern/features/media/data/datasources/pawchive_api_client.dart';
import 'package:Fern/features/media/data/datasources/pinterest_api_client.dart';
import 'package:Fern/features/media/data/datasources/pixiv_api_client.dart';
import 'package:Fern/features/media/data/datasources/reddit_api_client.dart';
import 'package:Fern/features/media/data/services/archive_extractor.dart';
import 'package:Fern/features/media/data/services/download_pool.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/remote_media_downloader.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/empty_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:Fern/features/media/domain/repositories/remote_media_repository.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';

/// Las fuentes remotas de la aplicación: Reddit, Pixiv, Danbooru, Gelbooru,
/// Pinterest y Pawchive.
///
/// El recorrido es siempre el mismo, dé igual la plataforma: se pregunta a su
/// API qué tiene guardado el usuario, se descarga lo que aún no está en el
/// equipo y se da de alta con el registro, que es por donde entra también lo
/// que se escanea del disco.
class RemoteMediaRepositoryImpl implements RemoteMediaRepository {
  final RedditApiClient _reddit;
  final PixivApiClient _pixiv;
  final DanbooruApiClient _danbooru;
  final GelbooruApiClient _gelbooru;
  final PinterestApiClient _pinterest;
  final PawchiveApiClient _pawchive;
  final ArchiveExtractor _archives;
  final ImportDecisions _decisions;
  final RemoteMediaDownloader _downloader;
  final MediaRegistry _registry;
  final SettingsRepository _settingsRepository;
  final PreferencesService _preferencesService;

  RemoteMediaRepositoryImpl({
    required RedditApiClient reddit,
    required PixivApiClient pixiv,
    required DanbooruApiClient danbooru,
    required GelbooruApiClient gelbooru,
    required PinterestApiClient pinterest,
    required PawchiveApiClient pawchive,
    required ImportDecisions decisions,
    ArchiveExtractor archives = const ArchiveExtractor(),
    required RemoteMediaDownloader downloader,
    required MediaRegistry registry,
    required SettingsRepository settingsRepository,
    required PreferencesService preferencesService,
  })  : _reddit = reddit,
        _pixiv = pixiv,
        _danbooru = danbooru,
        _gelbooru = gelbooru,
        _pinterest = pinterest,
        _pawchive = pawchive,
        _decisions = decisions,
        _archives = archives,
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
      case ImportSource.danbooru:
        yield* _scanDanbooru(untilLastImport: untilLastImport);
      case ImportSource.gelbooru:
        yield* _scanGelbooru(untilLastImport: untilLastImport);
      case ImportSource.pinterest:
        yield* _scanPinterest(untilLastImport: untilLastImport);
      case ImportSource.pawchive:
        yield* _scanPawchive(untilLastImport: untilLastImport);
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
    var imported = 0;
    var failed = 0;

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
        if (path == null) {
          failed++;
          continue;
        }

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
        if (summary != null) {
          imported++;
          yield DataSuccess(summary);
        }
      }
    } on Exception catch (e) {
      yield DataException(e);
      return;
    }

    if (_nothingCameThrough(ImportSource.reddit, failed: failed, imported: imported)
        case final error?) {
      yield error;
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
    var imported = 0;
    var failed = 0;

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
        if (path == null) {
          failed++;
          continue;
        }

        final summary = await _registry.register(
          path: path,
          source: ImportSource.pixiv,
          description: item.title.isEmpty ? null : item.title,
          sourceTagName:
              settings.autoTagRemoteSource ? pixivSourceTagName : null,
          sourceUrls: item.sourceUrls,
        );
        if (summary != null) {
          imported++;
          yield DataSuccess(summary);
        }
      }
    } on Exception catch (e) {
      yield DataException(e);
      return;
    }

    if (_nothingCameThrough(ImportSource.pixiv, failed: failed, imported: imported)
        case final error?) {
      yield error;
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

  /// Lo que el usuario tiene en favoritos en Danbooru.
  ///
  /// Es el más sencillo de los tres: su API es pública y devuelve los favoritos
  /// en el orden en el que se marcaron, así que "desde la última vez" se
  /// resuelve con una marca igual que en las otras dos, y una publicación es
  /// siempre un fichero, así que no hay galerías que repartir.
  Stream<DataState<MediaSummaryEntity>> _scanDanbooru({
    required bool untilLastImport,
  }) async* {
    final settings = _settingsRepository.getSettings();
    final credentials = settings.danbooru;
    if (!credentials.isComplete) {
      yield DataException(Exception('Danbooru is not configured'));
      return;
    }

    final marker = untilLastImport
        ? _preferencesService.getLastImportMarker(ImportSource.danbooru)
        : null;

    // Lo más nuevo que había al empezar, que es lo que quedará como marca
    // cuando el recorrido termine.
    String? newest;
    var imported = 0;
    var failed = 0;

    try {
      await for (final item
          in _danbooru.favoriteMedia(credentials, stopAt: marker)) {
        newest ??= item.postId;

        final path = await _downloader.download(
          url: item.url,
          name: item.id,
          source: ImportSource.danbooru,
        );
        if (path == null) {
          failed++;
          continue;
        }

        final summary = await _registry.register(
          path: path,
          source: ImportSource.danbooru,
          sourceTagName:
              settings.autoTagRemoteSource ? danbooruSourceTagName : null,
          sourceUrls: item.sourceUrls,
        );
        if (summary != null) {
          imported++;
          yield DataSuccess(summary);
        }
      }
    } on Exception catch (e) {
      yield DataException(e);
      return;
    }

    if (_nothingCameThrough(ImportSource.danbooru, failed: failed, imported: imported)
        case final error?) {
      yield error;
      return;
    }

    if (newest != null) {
      await _preferencesService.setLastImportMarker(
        ImportSource.danbooru,
        newest,
      );
    }
  }

  /// Lo que el usuario tiene en favoritos en Gelbooru.
  ///
  /// Por fuera es igual que Danbooru; por dentro, su listado de favoritos es
  /// bastante peor (ni devuelve las publicaciones ni las da siempre en el mismo
  /// orden), pero de eso se encarga su cliente. Aquí llega lo mismo que de
  /// cualquier otra fuente: contenido de lo más reciente a lo más antiguo.
  Stream<DataState<MediaSummaryEntity>> _scanGelbooru({
    required bool untilLastImport,
  }) async* {
    final settings = _settingsRepository.getSettings();
    final credentials = settings.gelbooru;
    if (!credentials.isComplete) {
      yield DataException(Exception('Gelbooru is not configured'));
      return;
    }

    final marker = untilLastImport
        ? _preferencesService.getLastImportMarker(ImportSource.gelbooru)
        : null;

    String? newest;
    var imported = 0;
    var failed = 0;

    try {
      await for (final item
          in _gelbooru.favoriteMedia(credentials, stopAt: marker)) {
        newest ??= item.postId;

        final path = await _downloader.download(
          url: item.url,
          name: item.id,
          source: ImportSource.gelbooru,
          // Su servidor de imágenes sólo las da a quien dice venir de su web.
          headers: item.headers,
        );
        if (path == null) {
          failed++;
          continue;
        }

        final summary = await _registry.register(
          path: path,
          source: ImportSource.gelbooru,
          sourceTagName:
              settings.autoTagRemoteSource ? gelbooruSourceTagName : null,
          sourceUrls: item.sourceUrls,
        );
        if (summary != null) {
          imported++;
          yield DataSuccess(summary);
        }
      }
    } on Exception catch (e) {
      yield DataException(e);
      return;
    }

    if (_nothingCameThrough(ImportSource.gelbooru, failed: failed, imported: imported)
        case final error?) {
      yield error;
      return;
    }

    if (newest != null) {
      await _preferencesService.setLastImportMarker(
        ImportSource.gelbooru,
        newest,
      );
    }
  }

  /// El fallo que hay que contar cuando se ha encontrado contenido y no ha
  /// entrado nada de nada, o `null` si no hay nada que contar.
  ///
  /// Una descarga que falla se pasa por alto de una en una, y está bien: es
  /// contenido que no llega. Pero si fallan **todas**, lo que hay no es una
  /// importación sin novedades sino una importación rota, y las dos se ven
  /// exactamente igual en la pantalla si no se dice.
  ///
  /// Además, en ese caso no se guarda la marca de por dónde se iba: darla por
  /// buena dejaría fuera para siempre lo que no se ha llegado a descargar.
  DataException<MediaSummaryEntity>? _nothingCameThrough(
    ImportSource source, {
    required int failed,
    required int imported,
  }) {
    if (failed == 0 || imported > 0) return null;

    return DataException(Exception(
      'None of the $failed files found in ${source.id} could be downloaded',
    ));
  }

  /// Lo que el usuario tiene guardado en Pinterest.
  ///
  /// Igual que las demás: llega de lo más reciente a lo más antiguo, así que
  /// "desde la última vez" se resuelve con una marca. Lo que cambia es que aquí
  /// basta el nombre de la cuenta, sin entrar en ninguna parte: la sesión sólo
  /// añade lo que el usuario tenga en tableros secretos.
  Stream<DataState<MediaSummaryEntity>> _scanPinterest({
    required bool untilLastImport,
  }) async* {
    final settings = _settingsRepository.getSettings();
    final credentials = settings.pinterest;
    if (!credentials.isComplete) {
      yield DataException(Exception('Pinterest is not configured'));
      return;
    }

    final marker = untilLastImport
        ? _preferencesService.getLastImportMarker(ImportSource.pinterest)
        : null;

    String? newest;
    var imported = 0;
    var failed = 0;

    try {
      await for (final item
          in _pinterest.savedMedia(credentials, stopAt: marker)) {
        newest ??= item.postId;

        final path = await _downloader.download(
          url: item.url,
          name: item.id,
          source: ImportSource.pinterest,
        );
        if (path == null) {
          failed++;
          continue;
        }

        final summary = await _registry.register(
          path: path,
          source: ImportSource.pinterest,
          description: item.title.isEmpty ? null : item.title,
          sourceTagName:
              settings.autoTagRemoteSource ? pinterestSourceTagName : null,
          sourceUrls: item.sourceUrls,
        );
        if (summary != null) {
          imported++;
          yield DataSuccess(summary);
        }
      }
    } on Exception catch (e) {
      yield DataException(e);
      return;
    }

    if (_nothingCameThrough(ImportSource.pinterest, failed: failed, imported: imported)
        case final error?) {
      yield error;
      return;
    }

    if (newest != null) {
      await _preferencesService.setLastImportMarker(
        ImportSource.pinterest,
        newest,
      );
    }
  }

  /// Lo que el usuario tiene marcado en Pawchive.
  ///
  /// Según el ajuste, se recorren sus publicaciones marcadas o todo lo de los
  /// creadores que sigue. Lo segundo lleva una marca por autor, porque cada uno
  /// se recorre por su cuenta.
  ///
  /// Aquí no se va de una en una: lo que es contenido sin más (lo que la
  /// publicación trae adjunto, y lo que enlaza cuando el enlace es uno y lleva
  /// directo a un fichero) se pone a descargar y se sigue mirando la siguiente
  /// publicación mientras tanto. Lo que hay que decidir o abrir (varios enlaces,
  /// un comprimido) sí se hace en su turno: preguntarle dos cosas a la vez al
  /// usuario no tendría sentido, y abrir comprimidos a la vez sólo pelearía por
  /// el disco.
  Stream<DataState<MediaSummaryEntity>> _scanPawchive({
    required bool untilLastImport,
  }) {
    // El recorrido va por su cuenta y va soltando lo que sale, en lugar de
    // producir y consumir al mismo paso: es lo que permite que unas descargas
    // sigan en marcha mientras se mira la publicación siguiente.
    final out = StreamController<DataState<MediaSummaryEntity>>();
    var isCancelled = false;

    out.onCancel = () => isCancelled = true;

    unawaited(
      _pawchiveInto(
        out,
        untilLastImport: untilLastImport,
        isCancelled: () => isCancelled,
      ).whenComplete(out.close),
    );

    return out.stream;
  }

  /// El recorrido de Pawchive, soltando en [out] lo que va entrando.
  Future<void> _pawchiveInto(
    StreamController<DataState<MediaSummaryEntity>> out, {
    required bool untilLastImport,
    required bool Function() isCancelled,
  }) async {
    final settings = _settingsRepository.getSettings();
    final credentials = settings.pawchive;
    if (!credentials.isComplete) {
      out.add(DataException(Exception('Pawchive is not configured')));
      return;
    }

    final byCreators = credentials.byFavoriteCreators;

    // La marca es una por autor cuando se va por creadores, y una sola cuando
    // se buscan las publicaciones marcadas.
    final markers = <String, String>{};
    String? marker;
    if (untilLastImport) {
      if (byCreators) {
        markers.addAll(_preferencesService.importMarkers(ImportSource.pawchive));
      } else {
        marker = _preferencesService.getLastImportMarker(ImportSource.pawchive);
      }
    }

    final newest = <String, String>{};
    String? newestPost;
    var imported = 0;
    var failed = 0;

    final tagName = settings.autoTagRemoteSource ? pawchiveSourceTagName : null;
    final pool = DownloadPool();

    /// Se trae un fichero y lo da de alta. Es lo que corre en paralelo.
    Future<void> bring(
      String url,
      String name,
      String description,
      List<String> sourceUrls,
    ) async {
      final path = await _downloader.download(
        url: url,
        name: name,
        source: ImportSource.pawchive,
      );
      if (path == null) {
        failed++;
        return;
      }

      final summary = await _registry.register(
        path: path,
        source: ImportSource.pawchive,
        description: description.isEmpty ? null : description,
        sourceTagName: tagName,
        sourceUrls: sourceUrls,
      );

      if (summary != null && !out.isClosed) {
        imported++;
        out.add(DataSuccess(summary));
      }
    }

    try {
      final posts = byCreators
          ? _pawchive.creatorPosts(credentials, stopAt: markers)
          : _pawchive.favoritePosts(credentials, stopAt: marker);

      await for (final post in posts) {
        if (isCancelled()) break;

        final collection = post.collection;
        if (collection == null) {
          newestPost ??= post.id;
        } else {
          newest.putIfAbsent(collection, () => post.id);
        }

        // Lo que la publicación trae puesto: a descargar, y seguimos.
        for (final item in post.media) {
          await pool.add(
            () => bring(item.url, item.id, item.title, item.sourceUrls),
          );
        }

        // El aviso de los sitios de descargas no espera a nadie.
        _decisions.noticeRepository(post.title, post.repositoryLinks);

        final links = post.downloadableLinks;
        if (links.isEmpty) continue;

        // Un solo enlace a un fichero es contenido sin más: no hay nada que
        // preguntar ni que abrir, así que se descarga como lo adjunto.
        if (links.length == 1 && links.single.kind == PostLinkKind.media) {
          await pool.add(() => bring(
                links.single.url,
                'pawchive_${post.id}_link0',
                post.title,
                post.sourceUrls,
              ));
          continue;
        }

        // Y lo que hay que decidir o abrir, en su turno.
        final choice = await _decisions.chooseLinks(post.title, links);

        for (final (index, link) in links.indexed) {
          if (isCancelled()) break;
          if (!choice.accepts(link)) continue;

          if (link.kind != PostLinkKind.archive) {
            await pool.add(() => bring(
                  link.url,
                  'pawchive_${post.id}_link$index',
                  post.title,
                  post.sourceUrls,
                ));
            continue;
          }

          final entered = await _importArchive(
            link.url,
            name: 'pawchive_${post.id}_link$index',
            description: post.title,
            tagName: tagName,
            sourceUrls: post.sourceUrls,
            out: out,
          );

          entered == 0 ? failed++ : imported += entered;
        }
      }

      // Lo que quede bajando termina antes de dar la importación por acabada.
      await pool.drain();

      // Ni una publicación en todo el recorrido: eso no es un fallo, pero
      // tampoco es "ya estaba todo", y hay una explicación que suele ser la
      // buena.
      if (!byCreators && newestPost == null && imported == 0) {
        final hasCreators = await _pawchive.hasFavoriteCreators(credentials);

        if (!out.isClosed) {
          out.add(DataException(EmptySourceException(
            ImportSource.pawchive,
            hint: hasCreators
                ? EmptySourceHint.pawchiveHasCreatorsInstead
                : null,
          )));
        }
        return;
      }
    } on Exception catch (e) {
      await pool.drain();
      if (!out.isClosed) out.add(DataException(e));
      return;
    }

    if (_nothingCameThrough(ImportSource.pawchive,
            failed: failed, imported: imported)
        case final error?) {
      if (!out.isClosed) out.add(error);
      return;
    }

    for (final entry in newest.entries) {
      await _preferencesService.setLastImportMarker(
        ImportSource.pawchive,
        entry.value,
        collection: entry.key,
      );
    }

    if (newestPost != null) {
      await _preferencesService.setLastImportMarker(
        ImportSource.pawchive,
        newestPost,
      );
    }
  }

  /// Se trae un comprimido, lo abre y da de alta lo que traía dentro.
  ///
  /// Devuelve cuántos contenidos han entrado. Esto no se solapa con nada: abrir
  /// un comprimido es trabajo de disco, y varios a la vez sólo se estorbarían.
  Future<int> _importArchive(
    String url, {
    required String name,
    required String description,
    required String? tagName,
    required List<String> sourceUrls,
    required StreamController<DataState<MediaSummaryEntity>> out,
  }) async {
    final path = await _downloader.download(
      url: url,
      name: name,
      source: ImportSource.pawchive,
      asArchive: true,
    );
    if (path == null) return 0;

    // De un comprimido no se queda el comprimido: se abre, se saca lo que es
    // contenido y lo demás se tira.
    final files = await _archives.extract(path);

    var entered = 0;
    for (final file in files) {
      final summary = await _registry.register(
        path: file,
        source: ImportSource.pawchive,
        description: description.isEmpty ? null : description,
        sourceTagName: tagName,
        sourceUrls: sourceUrls,
      );

      if (summary != null && !out.isClosed) {
        entered++;
        out.add(DataSuccess(summary));
      }
    }

    return entered;
  }
}
