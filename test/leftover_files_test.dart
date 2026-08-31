// Los ficheros sueltos de la carpeta de trabajo.
//
// Tres cosas y sólo tres: avatares sin dueño, descargas cuya fila ya no está en
// la base —lo que deja descartar algo conservando su fichero— y pesos que ya no
// apunta ningún modelo.
//
// **Lo que no toca es lo que más importa aquí.** En la misma carpeta viven el
// entorno de Python y el sidecar, que **no están en la base de datos**: un
// barrido de «todo lo que no reconozca» se los llevaría y dejaría el
// reconocimiento roto sin decir por qué. Los conjuntos de entrenamiento y las
// cachés tampoco entran: se regeneran solos, y borrarlos sólo consigue que la
// próxima vez vaya lento.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
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
import 'package:Fern/features/recognition/data/models/recognition_result_model.dart';
import 'package:Fern/features/settings/data/services/avatar_janitor.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/data/services/leftover_files.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late Directory avatars;
  late Directory downloads;
  late Directory recognition;
  late Isar isar;
  late LeftoverFiles leftovers;

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
    root = await Directory.systemTemp.createTemp('fern_leftovers');
    avatars = await Directory(p.join(root.path, 'avatars')).create();
    downloads = await Directory(p.join(root.path, 'downloads')).create();
    recognition = await Directory(p.join(root.path, 'recognition')).create();

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
        ModelTreeEdgeModelSchema,
        ModelTreeNodeModelSchema,
        RecognitionResultModelSchema,
      ],
      directory: root.path,
      inspector: false,
    );

    leftovers = LeftoverFiles(
      database: isar,
      avatars: AvatarJanitor(
        database: isar,
        storage: AvatarStorageService(
          settingsRepository: _Settings(avatarsPath: avatars.path),
        ),
      ),
      downloadsPath: () => downloads.path,
      recognitionPath: () => recognition.path,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await root.exists()) await root.delete(recursive: true);
  });

  Future<String> file(Directory where, String name, {int bytes = 8}) async {
    await where.create(recursive: true);
    final target = File(p.join(where.path, name));
    await target.writeAsBytes(List.filled(bytes, 0));

    return target.path;
  }

  Directory sub(Directory parent, String name) =>
      Directory(p.join(parent.path, name));

  Future<bool> exists(String path) => File(path).exists();

  group('las descargas', () {
    // Es lo que deja descartar algo diciendo que se conserve el fichero: el
    // contenido sale de la aplicación y el fichero se queda, invisible.
    test('las que ya no están en la base se cuentan', () async {
      await file(sub(downloads, 'reddit'), 'suelta.jpg');

      final plan = await leftovers.find();

      expect(plan.downloads, hasLength(1));
    });

    test('y las que sí, no', () async {
      final kept = await file(sub(downloads, 'reddit'), 'en_uso.jpg');

      await isar.writeTxn(() async {
        await isar.mediaSummaryModels.put(
          MediaSummaryModel()
            ..id = 1
            ..path = kept,
        );
      });

      final plan = await leftovers.find();

      expect(plan.downloads, isEmpty);
    });

    test('mira todas las fuentes', () async {
      await file(sub(downloads, 'reddit'), 'una.jpg');
      await file(sub(downloads, 'pixiv'), 'otra.png');

      final plan = await leftovers.find();

      expect(plan.downloads, hasLength(2));
    });
  });

  group('los pesos', () {
    test('los que no apunta ningún modelo se cuentan', () async {
      await file(sub(recognition, recognitionWeightsFolderName), 'viejo.pt');

      final plan = await leftovers.find();

      expect(plan.weights, hasLength(1));
    });

    test('y los que sí, no', () async {
      final kept =
          await file(sub(recognition, recognitionWeightsFolderName), 'suyo.pt');

      await isar.writeTxn(() async {
        await isar.recognitionModelModels.put(RecognitionModelModel()
          ..id = 1
          ..name = 'modelo'
          ..weightsPath = kept);
      });

      final plan = await leftovers.find();

      expect(plan.weights, isEmpty);
    });

    test('los importados también', () async {
      await file(sub(recognition, 'imported'), 'traido.pt');

      final plan = await leftovers.find();

      expect(plan.weights, hasLength(1));
    });
  });

  // Lo que de verdad hay que sostener: en esa carpeta vive el entorno de Python,
  // que no está en la base de datos. Llevárselo rompería el reconocimiento y
  // nada lo explicaría.
  group('lo que no toca', () {
    test('el entorno de Python', () async {
      final env = await file(sub(recognition, '.venv'), 'python.exe');

      final plan = await leftovers.find();

      expect(plan.all.map((each) => each.path), isNot(contains(env)));
    });

    test('el sidecar', () async {
      final sidecar = await file(recognition, 'fern_sidecar.py');

      final plan = await leftovers.find();

      expect(plan.all.map((each) => each.path), isNot(contains(sidecar)));
    });

    test('los conjuntos de entrenamiento', () async {
      final dataset = await file(
        sub(recognition, recognitionDatasetsFolderName),
        'recorte.jpg',
      );

      final plan = await leftovers.find();

      expect(plan.all.map((each) => each.path), isNot(contains(dataset)));
    });

    test('ni los registros del entrenador', () async {
      final run = await file(
        sub(recognition, recognitionRunsFolderName),
        'results.csv',
      );

      final plan = await leftovers.find();

      expect(plan.all.map((each) => each.path), isNot(contains(run)));
    });
  });

  group('el recuento', () {
    test('suma los tres tipos', () async {
      await file(avatars, 'suelto.png', bytes: 10);
      await file(sub(downloads, 'reddit'), 'suelta.jpg', bytes: 20);
      await file(
        sub(recognition, recognitionWeightsFolderName),
        'viejo.pt',
        bytes: 30,
      );

      final plan = await leftovers.find();

      expect(plan.files, 3);
      expect(plan.bytes, 60);
      expect(plan.isEmpty, isFalse);
    });

    test('sin nada suelto lo dice', () async {
      final plan = await leftovers.find();

      expect(plan.isEmpty, isTrue);
      expect(plan.files, 0);
    });
  });

  group('barrer', () {
    test('borra lo que se le da y sólo eso', () async {
      final loose = await file(sub(downloads, 'reddit'), 'suelta.jpg');
      final kept = await file(sub(downloads, 'reddit'), 'en_uso.jpg');

      await isar.writeTxn(() async {
        await isar.mediaSummaryModels.put(
          MediaSummaryModel()
            ..id = 1
            ..path = kept,
        );
      });

      final plan = await leftovers.find();
      final swept = await leftovers.sweep(plan.all);

      expect(await exists(loose), isFalse);
      expect(await exists(kept), isTrue);
      expect(swept.files, 1);
    });

    // Lo que se mira y lo que se borra son dos pasos, así que entre medias el
    // usuario ha podido decir que no: barrer una lista vacía no toca nada.
    test('con una lista vacía no borra nada', () async {
      final loose = await file(sub(downloads, 'reddit'), 'suelta.jpg');

      final swept = await leftovers.sweep(const []);

      expect(await exists(loose), isTrue);
      expect(swept, (files: 0, bytes: 0));
    });

    // Uno que ya no está no puede parar la limpieza de los demás.
    test('uno que ha desaparecido no rompe el resto', () async {
      final first = await file(sub(downloads, 'reddit'), 'una.jpg');
      final second = await file(sub(downloads, 'reddit'), 'otra.jpg');

      final plan = await leftovers.find();
      await File(first).delete();

      final swept = await leftovers.sweep(plan.all);

      expect(await exists(second), isFalse);
      expect(swept.files, 1);
    });
  });

  // Las carpetas pueden no existir todavía: la de descargas no se crea hasta la
  // primera importación.
  test('sin carpetas no revienta', () async {
    await downloads.delete(recursive: true);
    await recognition.delete(recursive: true);
    await avatars.delete(recursive: true);

    expect((await leftovers.find()).isEmpty, isTrue);
  });
}

class _Settings implements SettingsRepository {
  final String avatarsPath;

  _Settings({required this.avatarsPath});

  @override
  AppSettingsEntity getSettings() =>
      AppSettingsEntity(avatarsPath: avatarsPath, recognitionPath: '');

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
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
