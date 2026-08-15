import 'dart:io';

import 'package:Fern/core/utils/file_utils.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:path/path.dart' as p;

/// Coloca el fichero de un contenido donde dicen los ajustes de archivos.
///
/// Se usa en los dos momentos en los que la aplicación toca el disco: al marcar
/// un contenido como definitivo y al lanzar la migración desde los ajustes. En
/// ambos casos la decisión es la misma, así que vive aquí y no repartida por
/// los casos de uso.
class MediaFileOrganizer {
  final SettingsRepository _settingsRepository;

  MediaFileOrganizer({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository;

  /// Reubica el fichero de [media] y devuelve su ruta nueva.
  ///
  /// Devuelve `null` cuando no hay nada que hacer: la sincronización está
  /// apagada, no hay carpeta elegida, el fichero ya está en su sitio o ha
  /// desaparecido del disco. Un fallo de disco tampoco se propaga: el contenido
  /// se queda donde está y la base de datos sigue apuntando a un fichero que
  /// existe.
  Future<String?> organize(MediaEntity media) async {
    final settings = _settingsRepository.getSettings();
    if (!settings.managesFiles) return null;

    final source = File(media.path);
    if (!await source.exists()) return null;

    final subfolder = _subfolder(media, settings.organization);
    final targetDirectory = subfolder == null
        ? settings.libraryPath!
        : p.join(settings.libraryPath!, subfolder);

    final naturalTarget = p.join(targetDirectory, p.basename(media.path));
    if (p.equals(naturalTarget, media.path)) return null;

    // Copiar sólo tiene sentido cuando el fichero viene de fuera: es lo que
    // conserva el original en la carpeta de la que se importó. Dentro de la
    // biblioteca siempre se mueve, porque si no cada cambio de criterio dejaría
    // otra copia del mismo contenido ordenada por el criterio anterior.
    final comesFromOutside = !p.isWithin(settings.libraryPath!, media.path);

    try {
      await Directory(targetDirectory).create(recursive: true);
      final target = uniqueFilePath(naturalTarget);
      final moved = !(settings.copyFiles && comesFromOutside);
      await placeFile(source, target, copy: !moved);

      // Si el fichero se ha ido de una carpeta de la biblioteca y era el
      // último, esa carpeta ya no dice nada. Sólo se miran ella y sus padres,
      // así que un guardado suelto no paga por recorrer la biblioteca entera.
      if (moved && !comesFromOutside) {
        await _pruneEmptyAncestors(
          p.dirname(media.path),
          libraryPath: settings.libraryPath!,
          avatarsPath: settings.avatarsPath,
        );
      }

      return target;
    } on FileSystemException {
      return null;
    }
  }


  /// Sube desde [directory] borrando las carpetas que se hayan quedado vacías.
  ///
  /// Se para en la primera que tenga algo dentro, en la raíz de la biblioteca
  /// (que no se borra) y en la carpeta de avatares.
  Future<void> _pruneEmptyAncestors(
    String directory, {
    required String libraryPath,
    required String avatarsPath,
  }) async {
    var current = directory;

    while (p.isWithin(libraryPath, current)) {
      if (p.equals(current, avatarsPath)) return;

      final folder = Directory(current);
      if (!await folder.exists()) return;
      if (!await folder.list(followLinks: false).isEmpty) return;

      try {
        await folder.delete();
      } on FileSystemException {
        return;
      }

      current = p.dirname(current);
    }
  }


  /// Borra las subcarpetas que se hayan quedado vacías dentro de la biblioteca.
  ///
  /// Se llama al terminar una migración: los criterios son excluyentes, así que
  /// al cambiar de criterio las carpetas del anterior se vacían y quedarían ahí
  /// como si todavía significaran algo.
  ///
  /// Sólo desaparece lo que está vacío. Ni un fichero que la aplicación no
  /// conozca ni la carpeta de avatares (que puede estar dentro de la
  /// biblioteca) se tocan, y la raíz se queda aunque no le quede nada.
  Future<void> removeEmptyFolders() async {
    final settings = _settingsRepository.getSettings();
    if (!settings.managesFiles) return;

    final root = Directory(settings.libraryPath!);
    if (!await root.exists()) return;

    await _removeIfEmpty(root, settings.avatarsPath, isRoot: true);
  }

  /// Vacía [directory] de subcarpetas vacías y lo borra si se queda sin nada.
  /// Devuelve `true` si lo ha borrado.
  Future<bool> _removeIfEmpty(
    Directory directory,
    String avatarsPath, {
    bool isRoot = false,
  }) async {
    if (!isRoot && p.equals(directory.path, avatarsPath)) return false;

    try {
      // El listado se resuelve entero antes de borrar nada: recorrer una
      // carpeta mientras se le quitan entradas no es de fiar.
      final entries = await directory.list(followLinks: false).toList();

      var isEmpty = true;
      for (final entry in entries) {
        if (entry is! Directory) {
          isEmpty = false;
          continue;
        }

        final removed = await _removeIfEmpty(entry, avatarsPath);
        if (!removed) isEmpty = false;
      }

      if (isRoot || !isEmpty) return false;

      await directory.delete();
      return true;
    } on FileSystemException {
      return false;
    }
  }

  /// Subcarpeta que le toca al contenido, o `null` si van todos sueltos en la
  /// raíz de la biblioteca.
  String? _subfolder(MediaEntity media, FileOrganizationCriteria criteria) {
    if (criteria == FileOrganizationCriteria.flat) return null;

    final tags = media.tags;
    final name = switch (criteria) {
      FileOrganizationCriteria.flat => null,
      FileOrganizationCriteria.byTag =>
        (tags == null || tags.isEmpty) ? null : tags.first.name,
      // La etiqueta de origen manda cuando está puesta; si no, se usa el nombre
      // de la plataforma de la que llegó, que se guarda siempre. Así ordenar por
      // origen sigue separando lo remoto aunque no se estén creando etiquetas
      // por plataforma.
      FileOrganizationCriteria.bySource =>
        media.source?.name ?? media.importSource.label,
      FileOrganizationCriteria.byCreator => media.creator.name,
    };

    // Sin etiqueta, sin origen o sin creador el contenido no se queda fuera:
    // va a la carpeta de descartes en lugar de a la raíz, que es la que usa el
    // criterio "todos juntos".
    return sanitizeFolderName(name ?? '');
  }
}
