import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/media_type.dart';
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

  /// Carpeta raíz de las descargas, resuelta al arrancar la aplicación.
  final String downloadsPath;

  RemoteMediaDownloader({
    required this.downloadsPath,
    required ExternalMediaResolver resolver,
    http.Client? client,
  })  : _resolver = resolver,
        _client = client ?? http.Client();

  /// Dónde caen los ficheros de [source].
  String directoryOf(ImportSource source) => p.join(downloadsPath, source.id);

  /// Descarga lo que haya en [url] y devuelve la ruta del fichero, o `null` si
  /// no había nada que descargar o si la descarga ha fallado.
  ///
  /// [url] no tiene por qué ser ya un fichero: si es un enlace a uno de los
  /// sitios aceptados, el resolvedor averigua qué vídeo o qué imagen hay detrás.
  ///
  /// Si ya existe un fichero con ese nombre se da por descargado y se devuelve
  /// tal cual: lo guardado en la cuenta no cambia, así que volver a pedirlo
  /// sería bajarse lo mismo otra vez.
  Future<String?> download({
    required String url,
    required String name,
    required ImportSource source,
  }) async {
    try {
      final fileUrl = await _resolver.resolve(url);
      if (fileUrl == null) return null;

      final extension = mediaExtensionOfUrl(fileUrl);
      if (extension == null) return null;

      final directory = Directory(directoryOf(source));
      await directory.create(recursive: true);

      final path = p.join(directory.path, '$name$extension');
      if (await File(path).exists()) return path;

      final request = http.Request('GET', Uri.parse(fileUrl))
        ..headers['User-Agent'] = remoteUserAgent.replaceFirst('%s', 'fern');
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
