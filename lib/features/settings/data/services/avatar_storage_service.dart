import 'dart:io';

import 'package:Fern/core/utils/file_utils.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:path/path.dart' as p;

/// Guarda las imágenes que se usan como avatar en la carpeta de avatares.
///
/// Copiar el avatar es una función que **siempre** está activa: no depende de
/// la sincronización de ficheros locales. Lo único que el usuario decide es en
/// qué carpeta se guardan, y esa carpeta es también de la que se cargan (todas
/// las rutas que acaban en la base de datos apuntan aquí).
class AvatarStorageService {
  final SettingsRepository _settingsRepository;

  AvatarStorageService({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository;

  String get avatarsDirectory => _settingsRepository.getSettings().avatarsPath;

  /// Copia [sourcePath] a la carpeta de avatares y devuelve la ruta de la
  /// copia, que es la que hay que guardar en la base de datos.
  ///
  /// Si la imagen ya está en la carpeta se devuelve tal cual, y si algo falla
  /// (el fichero ha desaparecido, no hay permisos) se devuelve la ruta original
  /// en lugar de dejar al usuario sin avatar.
  Future<String> store(String sourcePath) async {
    try {
      final directory = avatarsDirectory;
      if (p.equals(p.dirname(sourcePath), directory)) return sourcePath;

      final source = File(sourcePath);
      if (!await source.exists()) return sourcePath;

      final target = uniqueFilePath(p.join(directory, p.basename(sourcePath)));
      await placeFile(source, target, copy: true);

      return target;
    } on FileSystemException {
      return sourcePath;
    }
  }

  /// Lleva la imagen [currentPath] a [targetDirectory].
  ///
  /// Se mueve cuando venía de la carpeta de avatares anterior (es una copia
  /// nuestra, no hay nada que conservar) y se copia en cualquier otro caso.
  /// Devuelve `null` si no ha hecho falta tocar nada o si el fichero ya no
  /// está.
  Future<String?> relocate(
    String currentPath, {
    required String targetDirectory,
    String? previousDirectory,
  }) async {
    try {
      if (p.equals(p.dirname(currentPath), targetDirectory)) return null;

      final source = File(currentPath);
      if (!await source.exists()) return null;

      final target =
          uniqueFilePath(p.join(targetDirectory, p.basename(currentPath)));

      final wasManaged = previousDirectory != null &&
          p.equals(p.dirname(currentPath), previousDirectory);
      await placeFile(source, target, copy: !wasManaged);

      return target;
    } on FileSystemException {
      return null;
    }
  }
}
