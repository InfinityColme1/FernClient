// Lo que un modelo deja escrito en disco, cuando el modelo se borra.
//
// La regla que no se puede romper es **no salirse de la carpeta de
// reconocimiento**. Aqui se borra recursivamente, y una ruta apuntando fuera
// —unos pesos que el usuario tenia en Descargas, un `..` de mas— se llevaria por
// delante una carpeta que no es nuestra. Eso no es un fallo que se arregle
// despues.
//
// Lo segundo es que borrar sea **a fondo**: los pesos, la carpeta de la run con
// sus graficas y el dataset temporal si se quedo a medias. Dejarlos ahi llena el
// disco de cientos de megas que nadie va a saber asociar a nada meses despues.

import 'dart:convert';
import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/data/services/model_files.dart';
import 'package:Fern/features/recognition/data/services/weights_importer.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory temp;
  late String root;
  late ModelFiles files;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('fern-model-files-');
    root = p.join(temp.path, 'recognition');

    files = ModelFiles(root: () async => root);
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  /// Crea un fichero con todo lo que haga falta por encima.
  Future<String> touch(String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString('lo que sea');

    return path;
  }

  String runFolder(String folder) =>
      p.join(root, recognitionRunsFolderName, folder);

  RecognitionModelEntity model({
    String name = 'Personajes de Miraculous',
    String? weightsPath,
    String? curvesDirectory,
  }) {
    return RecognitionModelEntity(
      id: 7,
      name: name,
      weightsPath: weightsPath,
      lastMetrics: curvesDirectory == null
          ? null
          : jsonEncode({'map50': 0.83, 'curves_dir': curvesDirectory}),
      createdAt: DateTime(2026),
    );
  }

  group('lo que se borra', () {
    test('los pesos entrenados', () async {
      final weights =
          await touch(p.join(runFolder('7-personajes-de-miraculous'),
              'weights', 'best.pt'));

      await files.discard(model(weightsPath: weights));

      expect(File(weights).existsSync(), isFalse);
    });

    test('la carpeta de la run entera, con sus graficas', () async {
      final folder = runFolder('7-personajes-de-miraculous');
      await touch(p.join(folder, 'confusion_matrix.png'));
      await touch(p.join(folder, 'results.png'));
      await touch(p.join(folder, 'weights', 'best.pt'));

      await files.discard(model(curvesDirectory: folder));

      expect(Directory(folder).existsSync(), isFalse);
    });

    test('el dataset que se quedo a medias', () async {
      final dataset = p.join(
        root,
        recognitionDatasetsFolderName,
        '7-personajes-de-miraculous',
      );
      await touch(p.join(dataset, 'data.yaml'));
      await touch(p.join(dataset, 'train', 'images', 'uno.jpg'));

      // Sin haber entrenado nunca: no hay pesos ni metricas que apunten a el.
      await files.discard(model());

      expect(Directory(dataset).existsSync(), isFalse);
    });

    test('unos pesos traidos de fuera', () async {
      final imported = await touch(p.join(
        root,
        WeightsImporter.importedFolder,
        '7-personajes-de-miraculous.pt',
      ));

      await files.discard(model(weightsPath: imported));

      expect(File(imported).existsSync(), isFalse);
    });

    test('la carpeta de la run aunque le hayan cambiado el nombre al modelo',
        () async {
      // El entrenamiento se hizo con el nombre viejo, y la carpeta lo lleva.
      final folder = runFolder('7-personajes-viejos');
      await touch(p.join(folder, 'results.png'));

      // Lo apuntado manda sobre lo deducido, que usaria el nombre de ahora.
      await files.discard(
        model(name: 'Otro nombre', curvesDirectory: folder),
      );

      expect(Directory(folder).existsSync(), isFalse);
    });

    test('se dice lo que se ha borrado', () async {
      final weights = await touch(p.join(
        root,
        WeightsImporter.importedFolder,
        '7-personajes-de-miraculous.pt',
      ));

      final removed = await files.discard(model(weightsPath: weights));

      expect(removed, contains(weights));
    });
  });

  group('lo que no se toca', () {
    test('unos pesos fuera de la carpeta de reconocimiento', () async {
      // Alguien apuntando a su propio `.pt` en Descargas: es suyo.
      final mine = await touch(p.join(temp.path, 'descargas', 'best.pt'));

      final removed = await files.discard(model(weightsPath: mine));

      expect(File(mine).existsSync(), isTrue);
      expect(removed, isEmpty);
    });

    test('una carpeta a la que se llega saliendo y volviendo', () async {
      final other = await touch(p.join(temp.path, 'otra-cosa', 'importante.txt'));
      final sneaky = p.join(root, '..', 'otra-cosa');

      await files.discard(model(curvesDirectory: sneaky));

      expect(File(other).existsSync(), isTrue);
    });

    test('una carpeta que empieza igual pero es otra', () async {
      // `recognition-viejo` empieza por `recognition`: comparar por texto se la
      // llevaria por delante.
      final other =
          await touch(p.join('$root-viejo', 'runs', 'algo', 'best.pt'));

      await files.discard(
        model(curvesDirectory: p.join('$root-viejo', 'runs', 'algo')),
      );

      expect(File(other).existsSync(), isTrue);
    });

    test('la propia carpeta de reconocimiento', () async {
      final other = await touch(p.join(root, 'runtime', 'python.exe'));

      await files.discard(model(curvesDirectory: root));

      // Borrarla se llevaria el entorno de Python entero, que cuesta gigas y
      // media hora de descarga.
      expect(Directory(root).existsSync(), isTrue);
      expect(File(other).existsSync(), isTrue);
    });

    test('lo que dejaron otros modelos', () async {
      final another = await touch(p.join(runFolder('8-otro-modelo'), 'best.pt'));

      await files.discard(model());

      expect(File(another).existsSync(), isTrue);
    });
  });

  group('cuando no hay nada', () {
    test('un modelo sin entrenar no se queja', () async {
      final removed = await files.discard(model());

      expect(removed, isEmpty);
    });

    test('unos pesos que ya no estan tampoco', () async {
      final removed = await files.discard(
        model(weightsPath: p.join(root, 'runs', 'lo-que-sea', 'best.pt')),
      );

      expect(removed, isEmpty);
    });

    test('unas metricas ilegibles no impiden borrar lo demas', () async {
      final dataset = p.join(
        root,
        recognitionDatasetsFolderName,
        '7-personajes-de-miraculous',
      );
      await touch(p.join(dataset, 'data.yaml'));

      final broken = RecognitionModelEntity(
        id: 7,
        name: 'Personajes de Miraculous',
        lastMetrics: 'esto no es json',
        createdAt: DateTime(2026),
      );

      await files.discard(broken);

      expect(Directory(dataset).existsSync(), isFalse);
    });
  });
}
