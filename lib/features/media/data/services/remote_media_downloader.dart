import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/media/data/services/animation_encoder.dart';
import 'package:Fern/features/media/data/services/external_media_resolver.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// Trae a este equipo los ficheros de las fuentes remotas.
///
/// Cada fuente tiene su carpeta dentro de la de descargas, que hace el mismo
/// papel que la carpeta que se escanea en el equipo: de ahí sale el fichero y
/// ahí se queda hasta que el contenido pasa a ser definitivo y la gestión de
/// ficheros lo coloca donde toque.
class RemoteMediaDownloader {
  final http.Client _client;
  final ExternalMediaResolver _resolver;
  final AnimationEncoder _encoder;

  /// Carpeta raíz de las descargas, resuelta al arrancar la aplicación.
  final String downloadsPath;

  RemoteMediaDownloader({
    required this.downloadsPath,
    required ExternalMediaResolver resolver,
    AnimationEncoder encoder = const AnimationEncoder(),
    http.Client? client,
  })  : _resolver = resolver,
        _encoder = encoder,
        _client = client ?? http.Client();

  /// Dónde caen los ficheros de [source].
  String directoryOf(ImportSource source) => p.join(downloadsPath, source.id);

  /// Descarga lo que haya en [url] y devuelve la ruta del fichero, o `null` si
  /// no había nada que descargar o si la descarga ha fallado.
  ///
  /// [url] no tiene por qué ser ya un fichero: si es un enlace a uno de los
  /// sitios aceptados, el resolvedor averigua qué vídeo o qué imagen hay detrás.
  ///
  /// [headers] son las que pida el servidor del que se baja el fichero, si es
  /// que pide alguna. Las trae la fuente junto con la dirección porque es la
  /// única que lo sabe: hay servidores de contenidos que sólo dan el fichero a
  /// quien dice venir de su web. Lo que traigan manda sobre lo de casa.
  ///
  /// [frameDelays] es para lo que no es un fichero sino un paquete de
  /// fotogramas que hay que montar: entonces lo que se guarda es la animación
  /// ya armada. Va vacío en lo normal.
  ///
  /// Si ya existe un fichero con ese nombre se da por descargado y se devuelve
  /// tal cual: lo guardado en la cuenta no cambia, así que volver a pedirlo
  /// sería bajarse lo mismo otra vez.
  Future<String?> download({
    required String url,
    required String name,
    required ImportSource source,
    Map<String, String> headers = const {},
    List<int>? frameDelays,
    bool asArchive = false,
  }) async {
    try {
      if (asArchive) {
        return await _downloadArchive(
          url: url,
          name: name,
          source: source,
          headers: headers,
        );
      }

      if (frameDelays != null) {
        return await _downloadAnimation(
          url: url,
          name: name,
          source: source,
          headers: headers,
          delays: frameDelays,
        );
      }

      final fileUrl = await _resolver.resolve(url, headers: headers);
      if (fileUrl == null) return null;

      final extension = mediaExtensionOfUrl(fileUrl);
      if (extension == null) return null;

      final directory = Directory(directoryOf(source));
      await directory.create(recursive: true);

      final path = p.join(directory.path, '$name$extension');
      if (await File(path).exists()) return path;

      final request = http.Request('GET', Uri.parse(fileUrl))
        ..headers['User-Agent'] = remoteUserAgent.replaceFirst('%s', 'fern')
        // Lo que pida el servidor del que sale el fichero, y no el de la fuente
        // que lo enlazó: un vídeo de Redgifs enlazado desde otra plataforma se
        // baja de Redgifs, y es Redgifs quien mira de dónde dice venir.
        ..headers.addAll(_hostHeaders(fileUrl))
        ..headers.addAll(headers);
      final response = await _client.send(request).timeout(remoteRequestTimeout);
      if (response.statusCode != 200) return null;

      // Lo que llega tiene que ser lo que decía ser: una página de error o un
      // fichero de cualquier otra cosa no se guarda por mucho que su dirección
      // acabara en `.mp4`.
      final contentType = response.headers['content-type'] ?? '';
      if (!remoteMediaContentTypes.any(contentType.startsWith)) return null;

      final length = response.contentLength;
      if (length != null && length > maxRemoteDownloadBytes) return null;

      return await _write(response, path);
    } on Exception {
      // Un fallo de red o de disco deja este contenido sin descargar, y ya
      // está: la importación sigue con el siguiente.
      return null;
    }
  }

  /// Lo que pide el servidor del que sale [url], si es que pide algo.
  ///
  /// Hay servidores de contenidos que sólo dan el fichero a quien dice venir de
  /// su web, y alguno que da **otra cosa** en vez de negarse — que es la forma
  /// más difícil de diagnosticar, porque la descarga funciona y lo que llega no
  /// es lo que se pidió.
  Map<String, String> _hostHeaders(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';

    if (host == redgifsMediaHost || host.endsWith('.$redgifsMediaHost')) {
      return redgifsDownloadHeaders;
    }

    return const {};
  }

  /// Se trae un fichero comprimido tal cual.
  ///
  /// No pasa por las comprobaciones de lo demás porque no es contenido: es una
  /// caja, y lo que importa es lo que traiga dentro. Quien la abra decidirá qué
  /// se queda.
  Future<String?> _downloadArchive({
    required String url,
    required String name,
    required ImportSource source,
    required Map<String, String> headers,
  }) async {
    final extension = p.extension(Uri.parse(url).path).toLowerCase();
    if (!archiveExtensions.contains(extension)) return null;

    final directory = Directory(directoryOf(source));
    await directory.create(recursive: true);

    final path = p.join(directory.path, '$name$extension');
    if (await File(path).exists()) return path;

    final request = http.Request('GET', Uri.parse(url))
      ..headers['User-Agent'] = remoteUserAgent.replaceFirst('%s', 'fern')
      ..headers.addAll(headers);

    final response = await _client.send(request).timeout(remoteRequestTimeout);
    if (response.statusCode != 200) return null;

    final length = response.contentLength;
    if (length != null && length > maxRemoteDownloadBytes) return null;

    return await _write(response, path);
  }

  /// Se trae un paquete de fotogramas, lo monta en una animación y la guarda.
  ///
  /// Lo que se descarga aquí no es contenido todavía: es un zip que hay que
  /// abrir entero para poder armarlo, así que no se va escribiendo según llega
  /// como el resto y lleva su propio tope de tamaño. Lo que queda en la carpeta
  /// es un GIF, que es lo que la aplicación sí sabe enseñar.
  Future<String?> _downloadAnimation({
    required String url,
    required String name,
    required ImportSource source,
    required Map<String, String> headers,
    required List<int> delays,
  }) async {
    final directory = Directory(directoryOf(source));
    await directory.create(recursive: true);

    final path = p.join(directory.path, '$name.gif');
    if (await File(path).exists()) return path;

    final response = await _client.get(
      Uri.parse(url),
      headers: {
        'User-Agent': remoteUserAgent.replaceFirst('%s', 'fern'),
        ...headers,
      },
    ).timeout(remoteRequestTimeout);
    if (response.statusCode != 200) return null;
    if (response.bodyBytes.length > maxAnimationSourceBytes) return null;

    final gif = await _encoder.gifFromZip(response.bodyBytes, delays: delays);
    if (gif == null) return null;

    // A un fichero aparte y luego se renombra, igual que el resto: así un
    // montaje a medias no deja en la carpeta algo que parezca contenido.
    final partial = File('$path.part');
    await partial.writeAsBytes(gif);
    await partial.rename(path);

    return path;
  }

  /// Vuelca la respuesta en [path] y devuelve la ruta, o `null` si se ha pasado
  /// de tamaño por el camino (hay servidores que no dicen cuánto ocupa lo que
  /// mandan).
  ///
  /// Se escribe a un fichero temporal y se renombra al terminar: así una
  /// descarga a medias no deja en la carpeta algo que parezca contenido.
  Future<String?> _write(http.StreamedResponse response, String path) async {
    final partial = File('$path.part');
    final sink = partial.openWrite();

    var written = 0;
    var tooBig = false;

    try {
      await for (final chunk in response.stream) {
        written += chunk.length;
        if (written > maxRemoteDownloadBytes) {
          tooBig = true;
          break;
        }
        sink.add(chunk);
      }
    } finally {
      await sink.close();
    }

    if (tooBig) {
      await partial.delete();
      return null;
    }

    await partial.rename(path);
    return path;
  }

  void close() => _client.close();
}
