// Traerse unos pesos entrenados en otro sitio: el plan B del doc 02.
//
// Lo que importa aqui es **que el fichero acabe dentro** de la carpeta de
// reconocimiento. Apuntar a un `.pt` que sigue en Descargas deja el modelo roto
// la primera vez que alguien limpie esa carpeta, y sin manera de saber por que.
//
// Y que las metricas del entrenamiento anterior **se vayan**: eran de otros
// pesos, y dejarlas puestas diria que este `.pt` acierta un 0,83 sin que nadie
// lo haya medido.

import 'dart:io';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/data/services/weights_importer.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Un repositorio que se queda con lo que le mandan.
class _FakeRepository implements ModelRepository {
  RecognitionModelEntity? model;
  final saved = <RecognitionModelEntity>[];
  bool failsToSave = false;

  _FakeRepository(this.model);

  @override
  Future<DataState<RecognitionModelEntity>> getModel(int id) async {
    final current = model;

    return current == null
        ? DataException(Exception('no existe'))
        : DataSuccess(current);
  }

  @override
  Future<DataState<RecognitionModelEntity>> saveModel(
    RecognitionModelEntity model,
  ) async {
    if (failsToSave) return DataException(Exception('disco lleno'));

    saved.add(model);
    this.model = model;

    return DataSuccess(model);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

void main() {
  late Directory temp;
  late _FakeRepository repository;
  late File source;

  /// El modelo antes de importar: ya entrenado aqui, con sus metricas.
  RecognitionModelEntity trained() {
    return RecognitionModelEntity(
      id: 7,
      name: 'Personajes de Miraculous',
      weightsPath: r'C:\fern\recognition\runs\7\weights\best.pt',
      lastMetrics: '{"map50":0.83}',
      lastError: 'OUT_OF_MEMORY',
      lastTrainedAt: DateTime(2026, 1, 1),
      createdAt: DateTime(2025),
    );
  }

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('fern-weights-');
    repository = _FakeRepository(trained());

    source = File(p.join(temp.path, 'descargas', 'best.pt'));
    await source.parent.create(recursive: true);
    await source.writeAsString('unos pesos cualquiera');
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  WeightsImporter importer({
    List<String> classes = const ['marinette', 'adrien'],
    Object? throws,
  }) {
    return WeightsImporter(
      models: repository,
      root: () async => p.join(temp.path, 'recognition'),
      inspect: (path) async {
        if (throws != null) throw throws;

        return classes;
      },
    );
  }

  group('cuando va bien', () {
    test('el fichero acaba dentro de la carpeta de reconocimiento', () async {
      final result = await importer().import(modelId: 7, sourcePath: source.path);

      expect(result, isA<DataSuccess<ImportedWeights>>());

      final destination = result.data!.model.weightsPath!;

      // Dentro, no apuntando a Descargas: si no, el modelo se rompe la primera
      // vez que alguien limpie esa carpeta.
      expect(destination, contains(WeightsImporter.importedFolder));
      expect(File(destination).existsSync(), isTrue);
      expect(File(destination).readAsStringSync(), 'unos pesos cualquiera');
    });

    test('el original se queda donde estaba', () async {
      await importer().import(modelId: 7, sourcePath: source.path);

      // Se copia, no se mueve: el fichero es del usuario.
      expect(source.existsSync(), isTrue);
    });

    test('el nombre lleva el modelo delante', () async {
      final result = await importer().import(modelId: 7, sourcePath: source.path);

      // `best.pt` lo llama todo el mundo: sin el identificador delante, dos
      // modelos se pisarian el fichero el uno al otro.
      expect(p.basename(result.data!.model.weightsPath!),
          '7-personajes-de-miraculous.pt');
    });

    test('queda marcado como traido de fuera', () async {
      final result = await importer().import(modelId: 7, sourcePath: source.path);

      expect(result.data!.model.isImportedWeights, isTrue);
    });

    test('las metricas y el fallo anteriores se van', () async {
      final result = await importer().import(modelId: 7, sourcePath: source.path);

      // Eran de otros pesos. Dejarlas diria que este `.pt` acierta un 0,83 sin
      // que nadie lo haya medido.
      expect(result.data!.model.lastMetrics, isNull);
      expect(result.data!.model.lastError, isNull);
    });

    test('se dice que clases trae', () async {
      final result = await importer(classes: ['ladybug', 'cat noir'])
          .import(modelId: 7, sourcePath: source.path);

      // Es lo unico que revela si el fichero es el que el usuario creia.
      expect(result.data!.classes, ['ladybug', 'cat noir']);
    });

    test('reimportar reemplaza en vez de acumular', () async {
      await importer().import(modelId: 7, sourcePath: source.path);
      await source.writeAsString('otros pesos');
      final result = await importer().import(modelId: 7, sourcePath: source.path);

      final folder = Directory(p.dirname(result.data!.model.weightsPath!));

      expect(folder.listSync(), hasLength(1));
      expect(File(result.data!.model.weightsPath!).readAsStringSync(),
          'otros pesos');
    });
  });

  group('cuando no', () {
    test('un fichero que no esta no se importa', () async {
      final result = await importer()
          .import(modelId: 7, sourcePath: p.join(temp.path, 'nada.pt'));

      expect(result, isA<DataException>());
      expect('${result.exception}', contains('WEIGHTS_NOT_FOUND'));
    });

    test('un modelo que no existe tampoco', () async {
      repository.model = null;

      final result = await importer().import(modelId: 7, sourcePath: source.path);

      expect(result, isA<DataException>());
      expect('${result.exception}', contains('MODEL_NOT_FOUND'));
    });

    test('unos pesos que no se pueden leer no se copian', () async {
      final result = await importer(throws: Exception('MODEL_INVALID'))
          .import(modelId: 7, sourcePath: source.path);

      expect(result, isA<DataException>());

      // Se pregunta antes de copiar: si no valen, no tiene sentido dejarlos
      // dentro y luego tener que limpiar.
      final folder =
          Directory(p.join(temp.path, 'recognition', WeightsImporter.importedFolder));
      expect(folder.existsSync(), isFalse);
    });

    test('unos pesos que no valen dejan el modelo como estaba', () async {
      await importer(throws: Exception('MODEL_INVALID'))
          .import(modelId: 7, sourcePath: source.path);

      expect(repository.saved, isEmpty);
      expect(repository.model!.weightsPath, contains('runs'));
      expect(repository.model!.lastMetrics, '{"map50":0.83}');
    });

    test('si no se puede guardar, se dice', () async {
      repository.failsToSave = true;

      final result = await importer().import(modelId: 7, sourcePath: source.path);

      expect(result, isA<DataException>());
      expect('${result.exception}', contains('disco lleno'));
    });
  });
}
