// Que guarda y que borra el repositorio de modelos.
//
// Se prueba contra una base de datos de verdad, como el de fernies: lo que
// importa aqui son los enlaces —que un fernie quede metido en un modelo, que
// borrar el modelo no se lleve al fernie— y eso solo lo demuestra Isar.
//
// Y sobre todo el numero de clase, que es lo mas facil de romper sin enterarse:
// los pesos entrenados conocen a cada fernie por su numero, asi que quitar uno
// no puede correr los de detras.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/recognition/data/models/model_fernie_model.dart';
import 'package:Fern/features/recognition/data/models/model_tree_edge_model.dart';
import 'package:Fern/features/recognition/data/models/model_tree_node_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/recognition/data/repositories/model_repository_impl.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late ModelRepositoryImpl repository;

  final isarLibrary = _isarLibrary();

  setUpAll(() async {
    if (isarLibrary == null) {
      throw StateError(
        'No se encuentra isar.dll. Se coge de la compilación de la aplicación '
        '(flutter build windows --debug) o del paquete isar_flutter_libs.',
      );
    }

    await Isar.initializeIsarCore(libraries: {Abi.windowsX64: isarLibrary});
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fern_models_test');

    isar = await Isar.open(
      [
        TagModelSchema,
        PersonaModelSchema,
        CreatorModelSchema,
        MediaSummaryModelSchema,
        MediaModelSchema,
        FernieModelSchema,
        FernieRegionModelSchema,
        RecognitionModelModelSchema,
        ModelFernieModelSchema,
        // Los del arbol tambien, aunque este fichero no lo pruebe: borrar un
        // modelo se lleva su sitio en el arbol en la misma transaccion, y una
        // base de pruebas que no se parece a la de la aplicacion falla por
        // parecerse poco, no por el codigo.
        ModelTreeNodeModelSchema,
        ModelTreeEdgeModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    repository = ModelRepositoryImpl(database: isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  Future<RecognitionModelEntity> addModel(
    String name, {
    ModelFunction function = ModelFunction.classification,
  }) async {
    final result = await repository.saveModel(
      RecognitionModelEntity(
        id: unsavedId,
        name: name,
        function: function,
        createdAt: DateTime.now(),
      ),
    );

    expect(result, isA<DataSuccess>());
    return result.data!;
  }

  Future<int> addFernie(String name) async {
    final row = FernieModel()..name = name;
    await isar.writeTxn(() => isar.fernieModels.put(row));

    return row.id;
  }

  /// Da de alta un contenido. Lo que no está confirmado se marca aparte: sus
  /// regiones se guardan pero no entrenan (D29).
  Future<int> addMedia(String path, {bool isImported = true}) async {
    final summary = MediaSummaryModel()
      ..path = path
      ..isImported = isImported;

    await isar.writeTxn(() => isar.mediaSummaryModels.put(summary));

    return summary.id;
  }

  Future<void> addRegion(int fernieId, int mediaId) async {
    final fernie = await isar.fernieModels.get(fernieId);

    final region = FernieRegionModel()
      ..mediaId = mediaId
      ..x = 0.1
      ..y = 0.1
      ..w = 0.3
      ..h = 0.3;

    await isar.writeTxn(() async {
      await isar.fernieRegionModels.put(region);
      region.fernie.value = fernie;
      await region.fernie.save();
    });
  }

  group('los recuentos de un fernie dentro de un modelo', () {
    test('separan lo marcado de lo que entrena', () async {
      final model = await addModel('Personajes');
      final fernie = await addFernie('Marinette');

      final firme = await addMedia('C:/biblioteca/uno.jpg');
      final pendiente =
          await addMedia('C:/biblioteca/dos.jpg', isImported: false);

      await addRegion(fernie, firme);
      await addRegion(fernie, pendiente);
      await addRegion(fernie, pendiente);

      await repository.assignFernie(modelId: model.id, fernieId: fernie);

      final assignments = await repository.getFerniesOfModel(model.id);
      final counted = assignments.data!.single.fernie;

      expect(counted.regionCount, 3);
      expect(counted.mediaCount, 2);
      expect(counted.usableRegionCount, 1,
          reason: 'las del contenido sin confirmar no entrenan');
      expect(counted.usableMediaCount, 1);
    });

    test('sin nada pendiente los dos recuentos coinciden', () async {
      final model = await addModel('Personajes');
      final fernie = await addFernie('Adrien');
      final media = await addMedia('C:/biblioteca/uno.jpg');

      await addRegion(fernie, media);
      await repository.assignFernie(modelId: model.id, fernieId: fernie);

      final assignments = await repository.getFerniesOfModel(model.id);
      final counted = assignments.data!.single.fernie;

      expect(counted.regionCount, counted.usableRegionCount);
      expect(counted.mediaCount, counted.usableMediaCount);
    });
  });

  group('modelos', () {
    test('se crea y se relee', () async {
      final model = await addModel('Personajes');

      expect(model.id, isNot(unsavedId));
      expect(model.name, 'Personajes');
      expect(model.fernieCount, 0);

      final all = await repository.getModels();
      expect(all.data, hasLength(1));
    });

    test('borrarlo no se lleva a sus fernies', () async {
      final model = await addModel('Personajes');
      final fernie = await addFernie('Marinette');

      await repository.assignFernie(modelId: model.id, fernieId: fernie);
      await repository.deleteModel(model.id);

      // El fernie es suyo, no del modelo: sigue valiendo para otros.
      expect(await isar.fernieModels.get(fernie), isNotNull);

      // Lo que desaparece es que estuviera metido en éste.
      expect(await isar.modelFernieModels.count(), 0);
    });
  });

  group('la funcion efectiva', () {
    test('un clasificatorio con un solo fernie se comporta como booleano',
        () async {
      final model = await addModel('Personajes');
      final fernie = await addFernie('Marinette');

      await repository.assignFernie(modelId: model.id, fernieId: fernie);

      final one = (await repository.getModel(model.id)).data!;

      // Clasificar entre una sola opcion no es clasificar.
      expect(one.function, ModelFunction.classification, reason: 'lo elegido');
      expect(one.effectiveFunction, ModelFunction.boolean, reason: 'lo real');
      expect(one.isDegraded, isTrue);
    });

    test('con dos fernies ya clasifica', () async {
      final model = await addModel('Personajes');

      await repository.assignFernie(
        modelId: model.id,
        fernieId: await addFernie('Marinette'),
      );
      await repository.assignFernie(
        modelId: model.id,
        fernieId: await addFernie('Adrien'),
      );

      final two = (await repository.getModel(model.id)).data!;

      expect(two.effectiveFunction, ModelFunction.classification);
      expect(two.isDegraded, isFalse);
    });
  });

  group('el numero de clase', () {
    test('se reparte en orden', () async {
      final model = await addModel('Personajes');

      for (final name in ['Marinette', 'Adrien', 'Alya']) {
        await repository.assignFernie(
          modelId: model.id,
          fernieId: await addFernie(name),
        );
      }

      final assignments = (await repository.getFerniesOfModel(model.id)).data!;

      expect([for (final a in assignments) a.classIndex], [0, 1, 2]);
    });

    test('quitar uno de en medio deja el hueco y no recoloca a nadie',
        () async {
      final model = await addModel('Personajes');

      final ids = <int>[];
      for (final name in ['Marinette', 'Adrien', 'Alya']) {
        final result = await repository.assignFernie(
          modelId: model.id,
          fernieId: await addFernie(name),
        );
        ids.add(result.data!.id);
      }

      await repository.removeFernie(ids[1]);

      final left = (await repository.getFerniesOfModel(model.id)).data!;

      // Correr el 2 al hueco del 1 cambiaria lo que significan unos pesos
      // entrenados con los numeros de antes.
      expect([for (final a in left) a.classIndex], [0, 2]);

      // Y el siguiente que entre va detras del mayor, no al hueco.
      final next = await repository.assignFernie(
        modelId: model.id,
        fernieId: await addFernie('Nino'),
      );

      expect(next.data!.classIndex, 3);
    });

    test('meter dos veces al mismo fernie no lo duplica', () async {
      final model = await addModel('Personajes');
      final fernie = await addFernie('Marinette');

      final first =
          await repository.assignFernie(modelId: model.id, fernieId: fernie);
      final again =
          await repository.assignFernie(modelId: model.id, fernieId: fernie);

      expect(again.data!.id, first.data!.id);
      expect((await repository.getFerniesOfModel(model.id)).data, hasLength(1));
    });

    test('cada modelo lleva su propia cuenta', () async {
      final one = await addModel('Personajes');
      final other = await addModel('Ropa');
      final fernie = await addFernie('Marinette');

      await repository.assignFernie(
        modelId: one.id,
        fernieId: await addFernie('Adrien'),
      );
      final second =
          await repository.assignFernie(modelId: other.id, fernieId: fernie);

      // El mismo fernie puede estar en dos modelos, con numeros distintos.
      expect(second.data!.classIndex, 0);
    });
  });

  group('el reparto', () {
    test('se guarda y vuelve', () async {
      final model = await addModel('Personajes');
      final assignment = (await repository.assignFernie(
        modelId: model.id,
        fernieId: await addFernie('Marinette'),
      ))
          .data!;

      expect(assignment.split, DatasetSplit.balanced);

      await repository.updateSplit(
        assignmentId: assignment.id,
        split: const DatasetSplit(train: 80, validation: 10, test: 10),
      );

      final saved = (await repository.getFerniesOfModel(model.id)).data!.single;
      expect(saved.split.train, 80);
      expect(saved.split.validation, 10);
    });

    test('uno que no suma cien no entra', () async {
      final model = await addModel('Personajes');
      final assignment = (await repository.assignFernie(
        modelId: model.id,
        fernieId: await addFernie('Marinette'),
      ))
          .data!;

      final result = await repository.updateSplit(
        assignmentId: assignment.id,
        split: const DatasetSplit(train: 80, validation: 30, test: 10),
      );

      expect(result, isA<DataException>());
    });
  });

  group('entrenamiento', () {
    test('un fallo no se lleva por delante los pesos que funcionaban',
        () async {
      final model = await addModel('Personajes');

      await repository.saveTrainingResult(
        modelId: model.id,
        weightsPath: 'C:/runs/uno/best.pt',
        metrics: '{"map50":0.83}',
      );

      final failed = (await repository.saveTrainingResult(
        modelId: model.id,
        error: 'OUT_OF_MEMORY',
      ))
          .data!;

      expect(failed.weightsPath, 'C:/runs/uno/best.pt');
      expect(failed.lastMetrics, '{"map50":0.83}');
      expect(failed.lastError, 'OUT_OF_MEMORY');
      expect(failed.status, ModelTrainingStatus.failed);
    });

    test('un entrenamiento bueno limpia el fallo anterior', () async {
      final model = await addModel('Personajes');

      await repository.saveTrainingResult(modelId: model.id, error: 'roto');
      final good = (await repository.saveTrainingResult(
        modelId: model.id,
        weightsPath: 'C:/runs/dos/best.pt',
      ))
          .data!;

      expect(good.lastError, isNull);
      expect(good.status, ModelTrainingStatus.ready);
    });

    test('ponerse a entrenar borra el fallo de la vez anterior', () async {
      final model = await addModel('Personajes');
      await repository.saveTrainingResult(
        modelId: model.id,
        error: 'OUT_OF_MEMORY',
      );

      await repository.setTraining(modelId: model.id, isTraining: true);

      // Dejarlo puesto mientras corre el nuevo deja la pantalla diciendo que se
      // rompio justo cuando se esta entrenando otra vez, y no hay forma de saber
      // si el mensaje es de antes o de ahora.
      final current = (await repository.getModel(model.id)).data!;

      expect(current.lastError, isNull);
      expect(current.isTraining, isTrue);
      expect(current.status, ModelTrainingStatus.training);
    });

    test('quitar la marca no toca el fallo recien apuntado', () async {
      final model = await addModel('Personajes');
      await repository.setTraining(modelId: model.id, isTraining: true);
      await repository.saveTrainingResult(modelId: model.id, error: 'roto');

      // El runner apaga la marca en su `finally`, despues de apuntar el fallo:
      // si eso lo borrara, no quedaria constancia de nada.
      await repository.setTraining(modelId: model.id, isTraining: false);

      expect((await repository.getModel(model.id)).data!.lastError, 'roto');
    });

    test('la marca de entrenando se desatasca al arrancar', () async {
      final model = await addModel('Personajes');
      await repository.setTraining(modelId: model.id, isTraining: true);

      // Si el equipo se apaga a media faena, esta marca se queda puesta y el
      // modelo no se dejaria entrenar nunca mas.
      expect((await repository.getModel(model.id)).data!.isTraining, isTrue);

      final cleared = await repository.clearStaleTrainingFlags();

      expect(cleared.data, 1);
      expect((await repository.getModel(model.id)).data!.isTraining, isFalse);
    });
  });
}

String? _isarLibrary() {
  final pubCache = Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['LOCALAPPDATA']}\\Pub\\Cache';

  final candidates = [
    r'build\windows\x64\runner\Debug\isar.dll',
    r'build\windows\x64\runner\Release\isar.dll',
    '$pubCache\\hosted\\pub.dev\\isar_flutter_libs-3.1.0+1\\windows\\isar.dll',
  ];

  for (final candidate in candidates) {
    if (File(candidate).existsSync()) return candidate;
  }
  return null;
}
