// La carpeta donde vive todo lo del reconocimiento.
//
// Lo que hay que sostener es que las subcarpetas existan cuando se va a
// escribir en ellas, y que cambiar de carpeta se lleve de verdad lo que había
// (son los modelos entrenados: dejarlos atrás es perderlos) sin dejar la
// carpeta vieja a medias.

import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/settings/data/services/recognition_storage_service.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

class _Settings implements SettingsRepository {
  String recognitionPath;

  _Settings(this.recognitionPath);

  @override
  AppSettingsEntity getSettings() => AppSettingsEntity(
        avatarsPath: 'avatars',
        recognitionPath: recognitionPath,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> writeFile(String path, String content) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(content);
}

void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('fern_recognition_test');
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('las subcarpetas se crean donde diga el ajuste', () async {
    final root = p.join(temp.path, 'recognition');
    final storage = RecognitionStorageService(settingsRepository: _Settings(root));

    await storage.ensureLayout();

    for (final name in recognitionSubfolderNames) {
      expect(
        Directory(p.join(root, name)).existsSync(),
        isTrue,
        reason: 'falta la subcarpeta $name',
      );
    }

    // Y las rutas que expone son esas mismas, que es de lo que se fía el resto
    // de la aplicación.
    expect(storage.weightsDirectory, p.join(root, recognitionWeightsFolderName));
    expect(storage.runtimeDirectory, p.join(root, recognitionRuntimeFolderName));
  });

  test('cambiar de carpeta se lleva el contenido y limpia la de origen', () async {
    final previous = p.join(temp.path, 'antes');
    final target = p.join(temp.path, 'despues');
    final settings = _Settings(previous);
    final storage = RecognitionStorageService(settingsRepository: settings);

    await storage.ensureLayout();
    await writeFile(
      p.join(previous, recognitionWeightsFolderName, 'modelo.pt'),
      'pesos',
    );
    await writeFile(
      p.join(previous, recognitionRunsFolderName, 'run1', 'results.csv'),
      'metricas',
    );

    final moved = await storage.relocate(
      targetDirectory: target,
      previousDirectory: previous,
    );

    expect(moved, 2);

    // El contenido está en el destino, con su estructura de carpetas intacta.
    expect(
      File(p.join(target, recognitionWeightsFolderName, 'modelo.pt'))
          .readAsStringSync(),
      'pesos',
    );
    expect(
      File(p.join(target, recognitionRunsFolderName, 'run1', 'results.csv'))
          .existsSync(),
      isTrue,
    );

    // Y la carpeta vieja ya no está: se ha quedado sin nada dentro.
    expect(Directory(previous).existsSync(), isFalse);
  });

  test('elegir la misma carpeta no mueve nada', () async {
    final root = p.join(temp.path, 'recognition');
    final storage = RecognitionStorageService(settingsRepository: _Settings(root));

    await storage.ensureLayout();
    await writeFile(
      p.join(root, recognitionWeightsFolderName, 'modelo.pt'),
      'pesos',
    );

    final moved = await storage.relocate(
      targetDirectory: root,
      previousDirectory: root,
    );

    expect(moved, 0);
    expect(
      File(p.join(root, recognitionWeightsFolderName, 'modelo.pt')).existsSync(),
      isTrue,
    );
  });

  test('una carpeta de origen que no existe no es un error', () async {
    final target = p.join(temp.path, 'despues');
    final storage = RecognitionStorageService(
      settingsRepository: _Settings(target),
    );

    final moved = await storage.relocate(
      targetDirectory: target,
      previousDirectory: p.join(temp.path, 'no-existe'),
    );

    // No había nada que mover, pero el destino queda listo para escribir.
    expect(moved, 0);
    expect(
      Directory(p.join(target, recognitionDatasetsFolderName)).existsSync(),
      isTrue,
    );
  });
}
