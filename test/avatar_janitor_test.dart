// Que no quede basura en la carpeta de avatares.
//
// Los avatares son **copias nuestras**: al elegir una imagen se copia a la
// carpeta y lo que se guarda en la base es la ruta de la copia. Al cambiar de
// imagen, la anterior dejaba de estar apuntada por nadie y se quedaba en el
// disco para siempre — invisible, porque no sale en ninguna pantalla, y
// creciendo con cada cambio.
//
// Contra base de datos y disco de verdad, porque lo que hay que comprobar es
// justo lo que pasa entre los dos: qué fichero se borra y cuál no. Con las dos
// cosas fingidas, la prueba diría que sí a cualquier cosa.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/shuffle_seed.dart';
import 'package:Fern/features/media/data/repositories/local_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
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
import 'package:Fern/features/recognition/data/models/recognition_result_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/settings/data/services/avatar_janitor.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory directory;
  late Directory avatars;
  late Isar isar;
  late AvatarJanitor janitor;

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
    directory = await Directory.systemTemp.createTemp('fern_avatar_janitor');
    avatars = await Directory(p.join(directory.path, 'avatars')).create();

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
        RecognitionResultModelSchema,
        ModelTreeNodeModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    janitor = AvatarJanitor(
      database: isar,
      storage: AvatarStorageService(
        settingsRepository: _Settings(avatarsPath: avatars.path),
      ),
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  /// Deja un fichero en la carpeta de avatares y devuelve su ruta.
  Future<String> avatar(String name, {int bytes = 16}) async {
    final file = File(p.join(avatars.path, name));
    await file.writeAsBytes(List.filled(bytes, 0));

    return file.path;
  }

  Future<bool> exists(String path) => File(path).exists();

  Future<List<String>> remaining() async => [
        for (final entry in avatars.listSync())
          if (entry is File) p.basename(entry.path),
      ]..sort();

  group('quién está usando qué', () {
    test('sin nada guardado, nadie', () async {
      expect(await janitor.inUse(), isEmpty);
    });

    // Las cinco colecciones que tienen avatar. Que estén todas es lo único que
    // hace segura la limpieza: la que se olvide se queda sin dueño aparente y su
    // fichero se borra estando en uso.
    test('cuenta las cinco clases que tienen avatar', () async {
      final paths = [
        for (final name in ['tag', 'persona', 'creator', 'fernie', 'model'])
          await avatar('$name.png'),
      ];

      await isar.writeTxn(() async {
        await isar.tagModels
            .put(TagModel(id: 1, name: 'etiqueta')..picturePath = paths[0]);
        await isar.personaModels
            .put(PersonaModel(id: 1, name: 'persona')..picturePath = paths[1]);
        await isar.creatorModels
            .put(CreatorModel(id: 1, name: 'creador')..picturePath = paths[2]);
        await isar.fernieModels.put(FernieModel()
          ..id = 1
          ..name = 'fernie'
          ..picturePath = paths[3]);
        await isar.recognitionModelModels.put(RecognitionModelModel()
          ..id = 1
          ..name = 'modelo'
          ..picturePath = paths[4]);
      });

      expect(await janitor.inUse(), paths.map(p.normalize).toSet());
    });
  });

  group('barrer la carpeta', () {
    test('se lleva lo que no apunta nadie', () async {
      final huerfano = await avatar('suelto.png');

      final barrido = await janitor.sweep();

      expect(await exists(huerfano), isFalse);
      expect(barrido.files, 1);
    });

    test('y deja lo que sí', () async {
      final usado = await avatar('en_uso.png');
      await avatar('suelto.png');

      await isar.writeTxn(() async {
        await isar.tagModels
            .put(TagModel(id: 1, name: 'etiqueta')..picturePath = usado);
      });

      await janitor.sweep();

      expect(await remaining(), ['en_uso.png']);
    });

    test('dice cuánto ha liberado', () async {
      await avatar('uno.png', bytes: 100);
      await avatar('dos.png', bytes: 50);

      final barrido = await janitor.sweep();

      expect(barrido.files, 2);
      expect(barrido.bytes, 150);
    });

    test('sin nada suelto no borra nada y lo dice', () async {
      final usado = await avatar('en_uso.png');

      await isar.writeTxn(() async {
        await isar.tagModels
            .put(TagModel(id: 1, name: 'etiqueta')..picturePath = usado);
      });

      final barrido = await janitor.sweep();

      expect(barrido, (files: 0, bytes: 0));
      expect(await exists(usado), isTrue);
    });

    // La carpeta la elige el usuario y podría ser una que use para otra cosa.
    // Lo que la aplicación no puso, la aplicación no lo borra: todo lo que pone
    // va suelto en la raíz.
    test('no entra en subcarpetas', () async {
      final dentro = await Directory(p.join(avatars.path, 'suyo')).create();
      final ajeno = File(p.join(dentro.path, 'no_es_nuestro.png'));
      await ajeno.writeAsBytes([0]);

      await janitor.sweep();

      expect(await ajeno.exists(), isTrue);
    });

    test('sin carpeta no revienta', () async {
      await avatars.delete(recursive: true);

      expect(await janitor.sweep(), (files: 0, bytes: 0));
    });
  });

  group('al cambiar un avatar', () {
    test('el anterior se borra si no lo usa nadie', () async {
      final anterior = await avatar('antes.png');
      final nuevo = await avatar('ahora.png');

      // Como hace el repositorio: primero se guarda el nuevo, y sólo después se
      // pregunta por el viejo.
      await isar.writeTxn(() async {
        await isar.tagModels
            .put(TagModel(id: 1, name: 'etiqueta')..picturePath = nuevo);
      });

      await janitor.removeIfUnused(anterior);

      expect(await exists(anterior), isFalse);
      expect(await exists(nuevo), isTrue);
    });

    // Pasa cuando copiar falló y se guardó la ruta original del usuario, que dos
    // fichas pueden tener apuntada a la vez.
    test('pero no si otro lo comparte', () async {
      final compartido = await avatar('compartido.png');

      await isar.writeTxn(() async {
        await isar.tagModels
            .put(TagModel(id: 1, name: 'etiqueta')..picturePath = compartido);
        await isar.creatorModels
            .put(CreatorModel(id: 1, name: 'creador')..picturePath = compartido);
      });

      await janitor.removeIfUnused(compartido);

      expect(await exists(compartido), isTrue);
    });

    test('sin avatar anterior no hay nada que hacer', () async {
      await expectLater(janitor.removeIfUnused(null), completes);
      await expectLater(janitor.removeIfUnused(''), completes);
    });

    // La aplicación borra sus copias, no los originales de nadie: lo que quedó
    // fuera de la carpeta es un fichero del usuario.
    test('lo que está fuera de la carpeta no se toca', () async {
      final ajeno = File(p.join(directory.path, 'del_usuario.png'));
      await ajeno.writeAsBytes([0]);

      await janitor.removeIfUnused(ajeno.path);

      expect(await ajeno.exists(), isTrue);
    });
  });

  // Por el camino de verdad, que es donde tenía que estar pasando y no pasaba:
  // guardar la ficha de una etiqueta o de un creador con otra imagen dejaba la
  // anterior tirada en la carpeta.
  group('guardando la ficha', () {
    late LocalMediaRepositoryImpl repository;

    setUp(() {
      final settings = _Settings(avatarsPath: avatars.path);
      final hierarchy = TagHierarchy(database: isar);

      repository = LocalMediaRepositoryImpl(
        shuffle: ShuffleSeed(),
        appDatabase: isar,
        fileOrganizer: MediaFileOrganizer(settingsRepository: settings),
        avatarStorage: AvatarStorageService(settingsRepository: settings),
        registry: MediaRegistry(database: isar, tagHierarchy: hierarchy),
        tagHierarchy: hierarchy,
      );
    });

    test('cambiarle el avatar a una etiqueta borra el anterior', () async {
      final antes = await avatar('etiqueta_antes.png');
      final ahora = await avatar('etiqueta_ahora.png');

      await isar.writeTxn(() async {
        await isar.tagModels
            .put(TagModel(id: 1, name: 'etiqueta')..picturePath = antes);
      });

      final result = await repository.updateTag(
        TagEntity(
          id: 1,
          name: 'etiqueta',
          picturePath: ahora,
          children: const [],
        ),
      );
      expect(result, isA<DataSuccess>());

      expect(await exists(antes), isFalse);
      expect(await exists(ahora), isTrue);
    });

    test('y guardarla sin tocar el avatar no lo borra', () async {
      final suyo = await avatar('sigue_igual.png');

      await isar.writeTxn(() async {
        await isar.tagModels
            .put(TagModel(id: 1, name: 'etiqueta')..picturePath = suyo);
      });

      await repository.updateTag(
        TagEntity(
          id: 1,
          name: 'otro nombre',
          picturePath: suyo,
          children: const [],
        ),
      );

      expect(await exists(suyo), isTrue);
    });

    test('cambiárselo a un creador también', () async {
      final antes = await avatar('creador_antes.png');
      final ahora = await avatar('creador_ahora.png');

      await isar.writeTxn(() async {
        await isar.creatorModels
            .put(CreatorModel(id: 1, name: 'alguien')..picturePath = antes);
      });

      final result = await repository.updateCreator(
        CreatorEntity(id: 1, name: 'alguien', picturePath: ahora),
      );
      expect(result, isA<DataSuccess>());

      expect(await exists(antes), isFalse);
      expect(await exists(ahora), isTrue);
    });

    // Con el nombre repetido no se escribe nada, así que el avatar de antes
    // sigue siendo el suyo: borrarlo dejaría al creador sin imagen por un
    // guardado que ni siquiera llegó a ocurrir.
    test('pero no si el guardado se rechaza', () async {
      final antes = await avatar('no_se_toca.png');

      await isar.writeTxn(() async {
        await isar.creatorModels
            .put(CreatorModel(id: 1, name: 'alguien')..picturePath = antes);
        await isar.creatorModels.put(CreatorModel(id: 2, name: 'ocupado'));
      });

      final result = await repository.updateCreator(
        CreatorEntity(
          id: 1,
          name: 'ocupado',
          picturePath: await avatar('el_nuevo.png'),
        ),
      );

      expect(result, isA<DataException>());
      expect(await exists(antes), isTrue);
    });
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
