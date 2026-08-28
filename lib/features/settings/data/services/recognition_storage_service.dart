import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/file_utils.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:path/path.dart' as p;

/// La carpeta donde vive todo lo del reconocimiento, y sus cuatro subcarpetas.
///
/// Es el equivalente de [AvatarStorageService] para la maquinaria de visión: un
/// único sitio que resuelve rutas, las crea cuando hacen falta y sabe llevarse
/// el contenido a otro disco si el usuario cambia de carpeta.
///
/// Nadie más debe componer estas rutas a mano: el día que cambie el reparto de
/// subcarpetas, tiene que cambiar aquí y en ningún otro sitio.
class RecognitionStorageService {
  final SettingsRepository _settingsRepository;

  RecognitionStorageService({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository;

  /// La carpeta elegida por el usuario, o la de fábrica si no ha elegido.
  String get root => _settingsRepository.getSettings().recognitionPath;

  /// Los conjuntos de datos que se preparan para entrenar, uno por modelo. Es
  /// material de usar y tirar: se regenera a partir de las regiones guardadas.
  String get datasetsDirectory =>
      p.join(root, recognitionDatasetsFolderName);

  /// Los modelos ya entrenados. Es lo único de aquí dentro que duele perder.
  String get weightsDirectory => p.join(root, recognitionWeightsFolderName);

  /// Lo que escribe el entrenador: registros, curvas y matrices de confusión.
  String get runsDirectory => p.join(root, recognitionRunsFolderName);

  /// El entorno de Python con el que se entrena y se reconoce. Se puede volver
  /// a instalar, así que es lo primero que se sacrifica si algo va mal.
  String get runtimeDirectory =>
      p.join(root, recognitionRuntimeFolderName);

  /// Crea las carpetas que falten. Se llama antes de escribir en cualquiera de
  /// ellas: la primera vez no existe ninguna.
  Future<void> ensureLayout({String? directory}) async {
    final base = directory ?? root;

    for (final name in recognitionSubfolderNames) {
      await Directory(p.join(base, name)).create(recursive: true);
    }
  }

  /// Lleva lo que hubiera en [previousDirectory] a [targetDirectory] y devuelve
  /// cuántos ficheros se han movido.
  ///
  /// Se mueve en lugar de copiar: son datos de la aplicación, no del usuario, y
  /// pueden ocupar varios gigas. Los ficheros se recorren uno a uno porque
  /// origen y destino pueden estar en unidades distintas, donde un `rename` de
  /// la carpeta entera no funciona; [placeFile] ya se encarga de caer a copiar
  /// y borrar cuando hace falta.
  ///
  /// Ojo con el entorno de Python: un entorno virtual lleva rutas absolutas
  /// dentro, así que después de moverlo hay que volver a comprobarlo y, si no
  /// responde, reinstalarlo. Eso es cosa de quien lo gestiona, no de aquí.
  Future<int> relocate({
    required String targetDirectory,
    required String previousDirectory,
  }) async {
    if (p.equals(previousDirectory, targetDirectory)) return 0;

    await ensureLayout(directory: targetDirectory);

    final source = Directory(previousDirectory);
    if (!await source.exists()) return 0;

    var moved = 0;

    await for (final entity in source.list(recursive: true)) {
      if (entity is! File) continue;

      final relative = p.relative(entity.path, from: previousDirectory);
      final target = p.join(targetDirectory, relative);

      try {
        await placeFile(entity, target, copy: false);
        moved++;
      } on FileSystemException {
        // Un fichero que no se deja mover (otro programa lo tiene abierto, o
        // faltan permisos) no puede parar la mudanza entera: lo que se quede
        // atrás se vuelve a generar o se vuelve a instalar.
        continue;
      }
    }

    await _removeEmptyTree(source);

    return moved;
  }

  /// Borra la carpeta de origen si ha quedado vacía, y lo que cuelgue de ella.
  ///
  /// Si algo no se pudo mover, la carpeta sigue teniendo contenido y se deja
  /// como está: borrarla se llevaría por delante lo que no se ha copiado.
  Future<void> _removeEmptyTree(Directory directory) async {
    try {
      final hasFiles = await directory
          .list(recursive: true)
          .any((entity) => entity is File);

      if (hasFiles) return;

      await directory.delete(recursive: true);
    } on FileSystemException {
      return;
    }
  }
}
