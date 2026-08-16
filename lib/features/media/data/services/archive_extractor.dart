import 'dart:io';
import 'dart:isolate';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

/// Abre los ficheros comprimidos que llegan de una fuente remota y se queda con
/// el contenido que hay dentro.
///
/// Hay plataformas donde lo que se publica no es una imagen sino un zip con
/// todas las de la entrega. Descargado, ese zip no es contenido: es una caja.
/// Aquí se abre, se saca lo que la aplicación sabe enseñar, y **se tira todo lo
/// demás, la caja incluida**: lo que quede en la carpeta de descargas tiene que
/// ser contenido y nada más.
class ArchiveExtractor {
  const ArchiveExtractor();

  /// Si [path] es un comprimido que se sabe abrir.
  bool isExtractable(String path) =>
      extractableArchiveExtensions.contains(p.extension(path).toLowerCase());

  /// Abre el comprimido de [path] y devuelve los ficheros de contenido que
  /// había dentro, ya sueltos en la misma carpeta.
  ///
  /// El comprimido se borra siempre, salga contenido o no: una vez abierto no
  /// pinta nada, y dejarlo haría que el escaneo de la carpeta lo encontrara una
  /// y otra vez.
  ///
  /// Se hace en otro hilo: un zip grande tarda, y la interfaz tiene que seguir
  /// respondiendo mientras dura la importación.
  Future<List<String>> extract(String path) async {
    final files = await Isolate.run(() => _extract(path));

    try {
      await File(path).delete();
    } on FileSystemException {
      // Si no se deja borrar, lo peor que pasa es que quede la caja vacía.
    }

    return files;
  }

  /// El trabajo en sí, ya en el otro hilo.
  ///
  /// De cada entrada sólo se saca lo que es contenido, y el nombre se aplana:
  /// dentro puede venir cualquier ruta, incluida alguna que apunte fuera de la
  /// carpeta ("../.."), y de un fichero que llega de internet no se acepta que
  /// diga dónde quiere escribirse.
  static List<String> _extract(String path) {
    final directory = p.dirname(path);
    final prefix = p.basenameWithoutExtension(path);

    final InputFileStream input;
    try {
      input = InputFileStream(path);
    } on FileSystemException {
      return const [];
    }

    final written = <String>[];
    var total = 0;

    try {
      final archive = ZipDecoder().decodeStream(input);

      for (final entry in archive.files) {
        if (!entry.isFile) continue;

        final name = p.basename(entry.name);
        if (mediaExtensionOfUrl(name) == null) continue;

        total += entry.size;
        if (total > maxArchiveContentBytes) break;

        final bytes = entry.readBytes();
        if (bytes == null) continue;

        // El nombre lleva delante el del comprimido: dos entregas distintas
        // pueden traer dentro un `01.jpg` cada una.
        final target = _freeName(directory, '${prefix}_$name');
        File(target).writeAsBytesSync(bytes);
        written.add(target);
      }
    } on Exception {
      // Un comprimido roto no trae contenido, y ya está: lo que se haya podido
      // sacar antes de romperse se queda.
    } finally {
      input.closeSync();
    }

    return written;
  }

  /// Un nombre que no pise nada de lo que ya hay en la carpeta.
  static String _freeName(String directory, String name) {
    final extension = p.extension(name);
    final base = p.basenameWithoutExtension(name);

    var candidate = p.join(directory, name);
    var attempt = 1;

    while (File(candidate).existsSync()) {
      candidate = p.join(directory, '$base($attempt)$extension');
      attempt++;
    }

    return candidate;
  }
}
