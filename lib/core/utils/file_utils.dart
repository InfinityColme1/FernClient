import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:path/path.dart' as p;

/// Utilidades de disco compartidas por lo que reubica ficheros: el organizador
/// de la biblioteca y el almacén de avatares.

/// Nombre válido para una carpeta.
///
/// Se sustituyen los caracteres que Windows no admite en un nombre de fichero y
/// se recortan los puntos y espacios del final, que también da por malos. Si no
/// queda nada se devuelve [fallbackFolderName].
String sanitizeFolderName(String name) {
  final cleaned = name
      .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .replaceAll(RegExp(r'[. ]+$'), '');

  return cleaned.isEmpty ? fallbackFolderName : cleaned;
}

/// Ruta libre a partir de [targetPath].
///
/// Si ya hay un fichero ahí se prueba con "nombre (2).ext", "nombre (3).ext"...
/// hasta encontrar un hueco: dos ficheros con el mismo nombre pueden venir de
/// carpetas distintas y ninguno debe pisar al otro.
String uniqueFilePath(String targetPath) {
  if (!File(targetPath).existsSync()) return targetPath;

  final directory = p.dirname(targetPath);
  final extension = p.extension(targetPath);
  final base = p.basenameWithoutExtension(targetPath);

  for (var index = 2;; index++) {
    final candidate = p.join(directory, '$base ($index)$extension');
    if (!File(candidate).existsSync()) return candidate;
  }
}

/// Borra el fichero de [path] y dice si se ha llegado a borrar.
///
/// Lo que ya no está (o no se deja borrar porque otro programa lo tiene abierto,
/// o por permisos) no es un error: quien borra contenido está quitándolo de la
/// aplicación, y eso tiene que salir adelante aunque el disco no acompañe.
Future<bool> deleteFileAt(String path) async {
  try {
    final file = File(path);
    if (!await file.exists()) return false;

    await file.delete();
    return true;
  } on FileSystemException {
    return false;
  }
}

/// Deja [source] en [targetPath], copiándolo o moviéndolo.
///
/// El movimiento se intenta primero con `rename`, que es instantáneo, y se cae
/// a copiar y borrar cuando origen y destino están en unidades distintas
/// (`rename` no cruza sistemas de ficheros).
Future<void> placeFile(
  File source,
  String targetPath, {
  required bool copy,
}) async {
  await Directory(p.dirname(targetPath)).create(recursive: true);

  if (copy) {
    await source.copy(targetPath);
    return;
  }

  try {
    await source.rename(targetPath);
  } on FileSystemException {
    await source.copy(targetPath);
    await source.delete();
  }
}
