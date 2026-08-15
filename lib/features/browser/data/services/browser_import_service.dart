import 'dart:convert';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/browser/data/services/browser_session_service.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/remote_media_downloader.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:crypto/crypto.dart';

/// Cómo ha ido el traerse lo marcado.
///
/// Son tres cuentas y no una porque las tres acaban igual de vacías en la
/// pantalla y significan cosas muy distintas: que un contenido ya estuviera no
/// es lo mismo que no haberlo podido descargar, y decir sólo cuántos han
/// entrado deja al usuario sin saber cuál de las dos le ha pasado.
class BrowserImportResult {
  /// Los que han entrado y están esperando en la pantalla de importación.
  final int imported;

  /// Los que ya estaban en la biblioteca: se han descargado o se tenían, pero
  /// no vuelven a entrar.
  final int known;

  /// Los que no se han podido traer: el sitio no los ha dado, o lo que ha dado
  /// no era el fichero que decía ser.
  final int failed;

  /// Bajo qué fuente han quedado, que es la sección en la que hay que buscarlos.
  final ImportSource source;

  const BrowserImportResult({
    required this.imported,
    required this.known,
    required this.failed,
    required this.source,
  });
}

/// Se trae al equipo el contenido que el usuario ha encontrado navegando.
///
/// No hace nada distinto de lo que hace una fuente remota: descarga y da de
/// alta lo descargado como contenido pendiente de revisar. La diferencia está
/// en de dónde sale la lista, que aquí no la da una API sino la página que el
/// usuario tiene delante.
///
/// Lo que se prepara aquí aparece en la pantalla de importación, que es donde
/// se revisa y se confirma, igual que lo que llega de Reddit o de Pixiv.
class BrowserImportService {
  final RemoteMediaDownloader _downloader;
  final MediaRegistry _registry;
  final SettingsRepository _settingsRepository;

  const BrowserImportService({
    required RemoteMediaDownloader downloader,
    required MediaRegistry registry,
    required SettingsRepository settingsRepository,
  })  : _downloader = downloader,
        _registry = registry,
        _settingsRepository = settingsRepository;

  /// Se descarga [urls] y las da de alta. Devuelve cuántas han entrado.
  ///
  /// Lo que ya estaba no vuelve a entrar y no cuenta: navegar por el mismo
  /// sitio dos veces no duplica nada.
  ///
  /// [pageUrl] es la página de la que salió todo, y hace dos cosas: se guarda
  /// como su origen (que es lo que el usuario reconoce y lo que puede haber
  /// vinculado con una etiqueta) y decide de qué fuente es lo que se trae. Lo
  /// que sale de una plataforma que la aplicación conoce entra bajo esa
  /// plataforma y no bajo el navegador: al usuario le da igual por qué camino
  /// llegó una obra de Pixiv, lo que quiere es encontrarla en Pixiv.
  ///
  /// [onProgress] va diciendo por cuál se va, para que la pantalla pueda
  /// contarlo mientras dura.
  Future<BrowserImportResult> importAll(
    List<String> urls, {
    required String pageUrl,
    void Function(int done, int total)? onProgress,
  }) async {
    final settings = _settingsRepository.getSettings();

    const sessions = BrowserSessionService();
    final platform = sessions.sourceOf(Uri.tryParse(pageUrl));

    final source = platform?.source ?? ImportSource.browser;
    final tagName = platform?.tagName ?? browserSourceTagName;

    // Las que pida el servidor de contenidos de la plataforma, si es una
    // conocida. Del resto no se sabe nada, así que se pide como lo pediría el
    // navegador que está enseñando la página: diciendo que se viene de ella. Es
    // lo que muchos servidores de contenidos comprueban antes de dar un
    // fichero, y sin eso responden que no hay permiso.
    final headers = platform?.downloadHeaders ??
        {'User-Agent': browserUserAgent, 'Referer': pageUrl};

    var imported = 0;
    var known = 0;
    var failed = 0;
    var done = 0;

    for (final url in urls) {
      final path = await _downloader.download(
        url: url,
        name: _nameOf(url),
        source: source,
        headers: headers,
      );

      if (path == null) {
        failed++;
      } else {
        final summary = await _registry.register(
          path: path,
          source: source,
          sourceTagName: settings.autoTagRemoteSource ? tagName : null,
          sourceUrls: [pageUrl],
        );
        summary == null ? known++ : imported++;
      }

      onProgress?.call(++done, urls.length);
    }

    return BrowserImportResult(
      imported: imported,
      known: known,
      failed: failed,
      source: source,
    );
  }

  /// Con qué nombre se guarda el fichero de [url].
  ///
  /// Aquí no hay identificador de publicación que valga: lo único que
  /// distingue a un fichero de otro es su dirección, así que el nombre sale de
  /// ella. Se le pone delante el sitio del que viene para que la carpeta de
  /// descargas siga siendo legible.
  String _nameOf(String url) {
    final host = (Uri.tryParse(url)?.host ?? '').replaceAll(
      RegExp(r'[^A-Za-z0-9]'),
      '_',
    );
    final digest = md5.convert(utf8.encode(url)).toString().substring(0, 12);

    return host.isEmpty ? digest : '${host}_$digest';
  }
}
