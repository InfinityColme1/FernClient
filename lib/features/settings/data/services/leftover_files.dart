import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/settings/data/services/avatar_janitor.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

/// Un fichero suelto y lo que ocupa.
typedef Leftover = ({String path, int bytes});

/// Lo que se ha encontrado, repartido por qué es cada cosa.
///
/// Se cuenta por separado porque no todo pesa igual en la decisión: cien
/// avatares son unos megas y cien descargas pueden ser gigas.
typedef LeftoverPlan = ({
  List<Leftover> avatars,
  List<Leftover> downloads,
  List<Leftover> weights,
});

extension LeftoverPlanTotals on LeftoverPlan {
  List<Leftover> get all => [...avatars, ...downloads, ...weights];

  int get files => all.length;

  int get bytes => all.fold(0, (sum, each) => sum + each.bytes);

  bool get isEmpty => files == 0;
}

/// Los ficheros de la carpeta de trabajo que ya no usa nadie.
///
/// Tres cosas, y **sólo tres**:
///
/// - **Avatares** sin dueño: copias que se quedaron al cambiar una imagen.
/// - **Descargas sin dar de alta**: lo que se bajó y cuya fila ya no está en la
///   base, que es lo que deja descartar algo conservando su fichero.
/// - **Pesos huérfanos**: los que ya no apunta ningún modelo, que es lo que deja
///   «olvidar el entrenamiento» o borrar un modelo.
///
/// **Lo que no toca, y por qué.** El entorno de Python y el sidecar viven en la
/// misma carpeta y **no están en la base de datos**, así que un barrido de «todo
/// lo que no reconozca» se los llevaría y dejaría el reconocimiento roto sin
/// decir por qué. Los conjuntos de entrenamiento y las cachés tampoco: se
/// regeneran solos, pero borrarlos sólo consigue que la próxima vez vaya lento.
class LeftoverFiles {
  final Isar _database;
  final AvatarJanitor _avatars;

  /// Dónde caen las descargas y dónde vive el reconocimiento. Por parámetro
  /// porque las decide el arranque y los ajustes, no esto.
  final String Function() _downloadsPath;
  final String Function() _recognitionPath;

  LeftoverFiles({
    required Isar database,
    required AvatarJanitor avatars,
    required String Function() downloadsPath,
    required String Function() recognitionPath,
  })  : _database = database,
        _avatars = avatars,
        _downloadsPath = downloadsPath,
        _recognitionPath = recognitionPath;

  /// Qué se llevaría la limpieza, sin llevarse nada.
  ///
  /// Se mira antes de borrar y se pregunta: con los avatares no hacía falta
  /// —son copias nuestras— pero aquí hay descargas que a lo mejor se quieren
  /// rescatar, y un fichero borrado no vuelve.
  Future<LeftoverPlan> find() async {
    return (
      avatars: await _looseAvatars(),
      downloads: await _looseDownloads(),
      weights: await _looseWeights(),
    );
  }

  /// Borra lo que se le diga. Devuelve cuánto se ha llevado de verdad.
  Future<AvatarSweep> sweep(Iterable<Leftover> files) async {
    var count = 0;
    var bytes = 0;

    for (final each in files) {
      try {
        await File(each.path).delete();

        count++;
        bytes += each.bytes;
      } on FileSystemException {
        // Uno que no se deja borrar —abierto, sin permisos— no puede parar la
        // limpieza de los demás.
        continue;
      }
    }

    return (files: count, bytes: bytes);
  }

  Future<List<Leftover>> _looseAvatars() async {
    final used = await _avatars.inUse();

    return _looseIn(Directory(_avatars.storageDirectory), used);
  }

  /// Lo descargado cuya fila ya no está en la base.
  ///
  /// Es lo que deja descartar algo diciendo que se conserve el fichero: el
  /// contenido sale de la aplicación y el fichero se queda, invisible, en la
  /// carpeta de su fuente.
  Future<List<Leftover>> _looseDownloads() async {
    final root = Directory(_downloadsPath());
    if (!await root.exists()) return const [];

    final used = {
      for (final summary in await _database.mediaSummaryModels.where().findAll())
        p.normalize(summary.path),
    };

    final loose = <Leftover>[];

    // Una carpeta por fuente, y dentro los ficheros sueltos. Se entra un nivel
    // porque es como se guardan; más adentro no pone nada la aplicación.
    await for (final entry in root.list(followLinks: false)) {
      if (entry is! Directory) continue;

      loose.addAll(await _looseIn(entry, used));
    }

    return loose;
  }

  /// Los pesos que ya no apunta ningún modelo.
  Future<List<Leftover>> _looseWeights() async {
    final root = _recognitionPath();
    if (root.isEmpty) return const [];

    final used = {
      for (final model
          in await _database.recognitionModelModels.where().findAll())
        if (model.weightsPath case final path?) p.normalize(path),
    };

    final loose = <Leftover>[];

    // Sólo las dos carpetas de pesos. Las de conjuntos y registros no se tocan,
    // y el entorno de Python menos todavía: no está en la base de datos, así que
    // «no lo usa nadie» sería mentira y llevárselo rompería el reconocimiento.
    for (final folder in [recognitionWeightsFolderName, 'imported']) {
      final directory = Directory(p.join(root, folder));
      if (!await directory.exists()) continue;

      loose.addAll(await _looseIn(directory, used, recursive: true));
    }

    return loose;
  }

  /// Los ficheros de [directory] que no están en [used].
  Future<List<Leftover>> _looseIn(
    Directory directory,
    Set<String> used, {
    bool recursive = false,
  }) async {
    if (!await directory.exists()) return const [];

    final loose = <Leftover>[];

    await for (final entry in directory.list(
      recursive: recursive,
      followLinks: false,
    )) {
      if (entry is! File) continue;
      if (used.contains(p.normalize(entry.path))) continue;

      try {
        loose.add((path: entry.path, bytes: await entry.length()));
      } on FileSystemException {
        continue;
      }
    }

    return loose;
  }
}
