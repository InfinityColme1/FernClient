import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/data/services/weights_importer.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/services/model_slug.dart';
import 'package:Fern/features/recognition/domain/services/training_metrics.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Dónde vive todo lo del reconocimiento.
typedef RecognitionRoot = Future<String> Function();

/// Lo que un modelo deja escrito en disco.
///
/// Los pesos, la carpeta de la run con sus gráficas y, si algo se quedó a
/// medias, el dataset temporal. Borrar el modelo de la base de datos y dejar
/// eso ahí llena el disco de carpetas que ya no se pueden asociar a nada: nadie
/// las va a reconocer meses después, y son cientos de megas cada una.
///
/// **No toca a los fernies ni a los contenidos.** Son suyos, no del modelo, y
/// siguen valiendo para otros: lo único que desaparece es lo que este modelo
/// escribió.
class ModelFiles {
  final RecognitionRoot _root;

  ModelFiles({required RecognitionRoot root}) : _root = root;

  /// Borra lo que dejó [model], y sólo eso.
  ///
  /// Devuelve lo que ha borrado, que es lo que se puede contar en un registro
  /// cuando alguien pregunte a dónde fue a parar el disco.
  ///
  /// Es un mejor esfuerzo a propósito: quien llama a esto ya ha borrado el
  /// modelo de la base de datos, y un fichero bloqueado por el antivirus no
  /// puede convertir un borrado hecho en un error.
  Future<List<String>> discard(RecognitionModelEntity model) async {
    final root = p.normalize(await _root());
    final removed = <String>[];

    for (final target in _targetsOf(model, root)) {
      if (!_isInside(target, root)) {
        // Un `.pt` fuera de la carpeta de reconocimiento no lo puso la
        // aplicación: es un fichero del usuario y no es nuestro para borrarlo.
        debugPrint('No se borra por estar fuera de $root: $target');
        continue;
      }

      if (await _remove(target)) removed.add(target);
    }

    return removed;
  }

  /// Todo lo que puede haber dejado este modelo.
  ///
  /// Se mira tanto lo **apuntado** —la ruta de los pesos, la carpeta que dijo el
  /// entrenador— como lo **deducido** del identificador y el nombre. Hacen falta
  /// las dos: lo apuntado es lo fiable, pero falta si el entrenamiento se rompió
  /// antes de guardar nada; y lo deducido usa el nombre de ahora, que puede no
  /// ser el que tenía cuando se entrenó.
  Iterable<String> _targetsOf(RecognitionModelEntity model, String root) {
    final folder = modelFolderName(id: model.id, name: model.name);
    final metrics = TrainingMetrics.parse(model.lastMetrics);

    return {
      if (model.weightsPath != null) p.normalize(model.weightsPath!),
      if (metrics?.curvesDirectory != null)
        p.normalize(metrics!.curvesDirectory!),
      p.join(root, recognitionRunsFolderName, folder),
      p.join(root, recognitionDatasetsFolderName, folder),
      p.join(root, recognitionWeightsFolderName, folder),
      p.join(root, WeightsImporter.importedFolder, '$folder.pt'),
    };
  }

  /// Que [target] cuelgue de verdad de [root].
  ///
  /// Es la única regla que no se puede romper: aquí se borra recursivamente, y
  /// una ruta apuntando fuera —unos pesos que alguien escribió a mano en la base
  /// de datos, un `..` de más— se llevaría por delante la carpeta de otro. Se
  /// compara por segmentos y no por texto, que `C:\fern-viejo` empieza por
  /// `C:\fern`.
  bool _isInside(String target, String root) {
    final String relative;

    try {
      relative = p.relative(target, from: root);
    } on ArgumentError {
      // En Windows, dos unidades distintas: no hay forma de llegar de una a la
      // otra, así que desde luego no está dentro.
      return false;
    }

    if (relative == '.' || relative.isEmpty) return false;

    return !p.split(relative).contains('..') && !p.isAbsolute(relative);
  }

  Future<bool> _remove(String target) async {
    try {
      final directory = Directory(target);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        return true;
      }

      final file = File(target);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } on FileSystemException catch (error) {
      // Un fichero abierto por otro (el antivirus, una carpeta abierta en el
      // explorador) no puede convertir un borrado ya hecho en un error.
      debugPrint('No se pudo borrar $target: ${error.message}');
    }

    return false;
  }
}
