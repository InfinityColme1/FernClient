import 'dart:convert';
import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/data/services/sidecar_paths.dart';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// No se ha podido dejar `uv` en el equipo.
class UvBootstrapException implements Exception {
  final String message;

  const UvBootstrapException(this.message);

  @override
  String toString() => 'UvBootstrapException: $message';
}

/// Trae `uv` al equipo, que es lo único que hace falta descargar a mano.
///
/// `uv` es un binario único y sin dependencias que existe para Windows, macOS y
/// Linux. Con él se instala después un Python propio y el entorno virtual, así
/// que **el usuario no tiene que tener Python de antes** ni tocar el PATH: ésa
/// es toda la razón de que esté aquí en lugar de buscar un Python del sistema.
class UvBootstrap {
  final SidecarPaths paths;
  final http.Client _client;

  UvBootstrap({required this.paths, http.Client? client})
      : _client = client ?? http.Client();

  /// Si ya está descargado.
  bool get isInstalled => File(paths.uvExecutable).existsSync();

  /// Descarga `uv` y lo deja listo para usar. No hace nada si ya estaba.
  ///
  /// [onProgress] recibe los bytes descargados y el total, o `null` como total
  /// cuando el servidor no lo dice.
  Future<void> install({
    void Function(int received, int? total)? onProgress,
  }) async {
    if (isInstalled) return;

    await Directory(paths.uvDirectory).create(recursive: true);

    final asset = paths.uvAssetName;
    final urls = _candidateUrls(asset);

    Object? lastError;
    for (final base in urls) {
      try {
        final bytes = await _download('$base/$asset', onProgress: onProgress);
        await _verify(bytes, '$base/$asset.sha256');
        await _extract(bytes);
        await _makeRunnable();

        return;
      } on Object catch (error) {
        lastError = error;
      }
    }

    throw UvBootstrapException(
      'Could not download $asset: $lastError',
    );
  }

  /// De dónde se intenta bajar, en orden.
  ///
  /// Primero la versión fijada, que es la que se ha probado. Si esa etiqueta ya
  /// no existe (el proyecto retira releases viejas), se cae a la última: es
  /// preferible instalar una versión sin probar que dejar al usuario sin
  /// reconocimiento por un 404.
  List<String> _candidateUrls(String asset) => [
        '$uvReleaseBaseUrl/download/$uvPinnedVersion',
        '$uvReleaseBaseUrl/latest/download',
      ];

  Future<List<int>> _download(
    String url, {
    void Function(int received, int? total)? onProgress,
  }) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await _client.send(request);

    if (response.statusCode != 200) {
      throw UvBootstrapException('$url answered ${response.statusCode}');
    }

    final total = response.contentLength;
    final bytes = <int>[];

    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
      onProgress?.call(bytes.length, total);
    }

    return bytes;
  }

  /// Comprueba que lo descargado es lo que la release dice que es.
  ///
  /// La suma se pide a la propia release en lugar de llevarla escrita en el
  /// código: así no hay que tocar la aplicación cada vez que `uv` publica una
  /// versión. Protege de una descarga a medias o corrompida, que es el fallo
  /// que de verdad se ve.
  ///
  /// Si la release no publica el fichero de sumas no se aborta: se sigue con lo
  /// descargado. Quedarse sin reconocimiento por eso sería peor.
  Future<void> _verify(List<int> bytes, String checksumUrl) async {
    final response = await _client.get(Uri.parse(checksumUrl));
    if (response.statusCode != 200) return;

    final expected = response.body.trim().split(RegExp(r'\s+')).first;
    if (expected.length != 64) return;

    final actual = sha256.convert(bytes).toString();

    if (actual.toLowerCase() != expected.toLowerCase()) {
      throw const UvBootstrapException(
        'The downloaded uv does not match its checksum',
      );
    }
  }

  /// Saca el binario del archivo, sea zip (Windows) o tar comprimido (el resto).
  Future<void> _extract(List<int> bytes) async {
    final archive = paths.uvAssetIsZip
        ? ZipDecoder().decodeBytes(bytes)
        : TarDecoder().decodeBytes(GZipDecoder().decodeBytes(bytes));

    final wanted = p.basename(paths.uvExecutable);

    for (final entry in archive) {
      if (!entry.isFile) continue;
      // El artefacto trae el binario dentro de una carpeta con el nombre de la
      // plataforma, así que se busca por nombre y no por ruta.
      if (p.basename(entry.name) != wanted) continue;

      final file = File(paths.uvExecutable);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(entry.content as List<int>);

      return;
    }

    throw UvBootstrapException('$wanted was not inside the downloaded archive');
  }

  /// Deja el binario en condiciones de ejecutarse.
  ///
  /// En macOS y Linux hay que darle permiso de ejecución, que el archivo no
  /// conserva. Y en macOS, además, quitarle la cuarentena de Gatekeeper: sin eso
  /// el sistema se niega a lanzar lo que se acaba de descargar, y el error que
  /// da no dice nada de esto.
  Future<void> _makeRunnable() async {
    if (paths.isWindows) return;

    await Process.run('chmod', ['755', paths.uvExecutable]);

    if (paths.platform == SidecarPlatform.macos) {
      await Process.run(
        'xattr',
        ['-d', 'com.apple.quarantine', paths.uvExecutable],
      );
    }
  }

  /// Qué versión de `uv` ha quedado instalada.
  Future<String?> version() async {
    if (!isInstalled) return null;

    final result = await Process.run(paths.uvExecutable, ['--version']);
    if (result.exitCode != 0) return null;

    return const LineSplitter()
        .convert(result.stdout.toString())
        .firstOrNull
        ?.trim();
  }
}
