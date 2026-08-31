import 'dart:io';

import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

/// Cuántos ficheros se han barrido y cuánto ocupaban.
typedef AvatarSweep = ({int files, int bytes});

/// Se lleva de la carpeta de avatares lo que ya no usa nadie.
///
/// Los avatares son **copias nuestras**: al elegir una imagen se copia a la
/// carpeta de avatares y lo que se guarda en la base es la ruta de la copia. Al
/// cambiar de imagen, la copia anterior dejaba de estar apuntada por nadie y se
/// quedaba en el disco para siempre — invisible, porque no sale en ninguna
/// pantalla, y creciendo con cada cambio.
///
/// Hay dos formas de usarlo y las dos hacen falta:
///
/// - [removeIfUnused] al cambiar un avatar, que es lo que evita que la basura
///   llegue a existir.
/// - [sweep] desde Ajustes, para lo que ya se acumuló antes de esto.
class AvatarJanitor {
  final Isar _database;
  final AvatarStorageService _storage;

  AvatarJanitor({
    required Isar database,
    required AvatarStorageService storage,
  })  : _database = database,
        _storage = storage;

  /// Todas las imágenes que alguien está usando ahora mismo.
  ///
  /// Las cinco colecciones que tienen avatar. Que estén todas es lo único que
  /// hace segura la limpieza: la que se olvide se queda sin dueño aparente y su
  /// fichero se borra estando en uso.
  Future<Set<String>> inUse() async {
    final paths = <String>{};

    void keep(String? path) {
      if (path == null || path.isEmpty) return;

      paths.add(p.normalize(path));
    }

    for (final each in await _database.tagModels.where().findAll()) {
      keep(each.picturePath);
    }
    for (final each in await _database.personaModels.where().findAll()) {
      keep(each.picturePath);
    }
    for (final each in await _database.creatorModels.where().findAll()) {
      keep(each.picturePath);
    }
    for (final each in await _database.fernieModels.where().findAll()) {
      keep(each.picturePath);
    }
    for (final each in await _database.recognitionModelModels.where().findAll()) {
      keep(each.picturePath);
    }

    return paths;
  }

  /// Borra [path] si no lo usa ya nadie más.
  ///
  /// Se llama **después** de haber escrito el avatar nuevo, así que la consulta
  /// ya no encuentra al que lo tenía. La comprobación es por si otro lo comparte:
  /// pasa cuando copiar falló y se guardó la ruta original del usuario, que dos
  /// fichas pueden tener apuntada a la vez. `AvatarStorageService.remove` no
  /// tocará esa de todas formas —está fuera de la carpeta de avatares— pero
  /// preguntarlo aquí es lo que hace que esto siga valiendo si eso cambia.
  Future<void> removeIfUnused(String? path) async {
    if (path == null || path.isEmpty) return;
    if ((await inUse()).contains(p.normalize(path))) return;

    await _storage.remove(path);
  }

  /// Barre la carpeta de avatares: se lleva todo lo que no apunta nadie.
  ///
  /// Sólo mira **su propia carpeta** y no entra en subcarpetas: la de avatares
  /// la elige el usuario y podría ser una que use para otra cosa. Lo que la
  /// aplicación no puso, la aplicación no lo borra sin más — y todo lo que pone
  /// va suelto en la raíz de esa carpeta.
  Future<AvatarSweep> sweep() async {
    final directory = Directory(_storage.avatarsDirectory);
    if (!await directory.exists()) return (files: 0, bytes: 0);

    final used = await inUse();

    var files = 0;
    var bytes = 0;

    await for (final entry in directory.list(followLinks: false)) {
      if (entry is! File) continue;
      if (used.contains(p.normalize(entry.path))) continue;

      try {
        final size = await entry.length();
        await entry.delete();

        files++;
        bytes += size;
      } on FileSystemException {
        // Uno que no se deja borrar —abierto, sin permisos— no puede parar la
        // limpieza de los demás.
        continue;
      }
    }

    return (files: files, bytes: bytes);
  }
}
