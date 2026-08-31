// Marcar a un creador como contenido no apto.
//
// Es lo mismo que ya hacían las etiquetas, y lo que hay que sostener es
// exactamente lo mismo: que no se escape ni uno. Esconder a un creador esconde
// **también su galería** —esconder el nombre dejando su contenido a la vista no
// esconde gran cosa, y encima ese contenido aparecería sin creador—, así que la
// prueba recorre los sitios por donde se escapan estas cosas: la rejilla, los
// buscadores, las sugerencias y los fernies que le apuntan.
//
// Y el creador desconocido, que no se puede marcar: es el respaldo al que van a
// parar los contenidos que se quedan sin creador, así que esconderlo escondería
// media biblioteca de una pulsación.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/shuffle_seed.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/data/repositories/local_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/nsfw_index.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/media/domain/entities/search/search_criterion_entity.dart';
import 'package:Fern/features/nsfw/data/services/password_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/recognition/data/models/model_fernie_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

/// La biblioteca de prueba: dos creadores con un contenido cada uno.
const markedCreatorId = 10;
const plainCreatorId = 11;
const unknownCreatorId = 12;

const markedMediaId = 100;
const plainMediaId = 101;

void main() {
  late Directory directory;
  late Isar isar;
  late LocalMediaRepositoryImpl repository;
  late NsfwIndex index;
  late NsfwModeService mode;

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
    directory = await Directory.systemTemp.createTemp('fern_nsfw_creators');
    final avatars = await Directory(p.join(directory.path, 'avatars')).create();

    isar = await Isar.open(
      [
        TagModelSchema,
        PersonaModelSchema,
        CreatorModelSchema,
        MediaSummaryModelSchema,
        MediaModelSchema,
        FernieModelSchema,
        FernieRegionModelSchema,
        // El indice mira tambien los modelos para saber cuales se quedan sin
        // clases visibles, asi que sus colecciones tienen que estar.
        RecognitionModelModelSchema,
        ModelFernieModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    final settings = _Settings(avatarsPath: avatars.path);
    final hierarchy = TagHierarchy(database: isar);

    index = NsfwIndex(database: isar, hierarchy: hierarchy);
    mode = NsfwModeService(
      storage: _MemoryStorage(),
      passwords: PasswordService(iterations: 64),
    );

    repository = LocalMediaRepositoryImpl(
      shuffle: ShuffleSeed(),
      appDatabase: isar,
      fileOrganizer: MediaFileOrganizer(settingsRepository: settings),
      avatarStorage: AvatarStorageService(settingsRepository: settings),
      registry: MediaRegistry(database: isar, tagHierarchy: hierarchy),
      tagHierarchy: hierarchy,
      visibility: NsfwVisibility(index: index, mode: mode),
      onNsfwChanged: index.rebuild,
    );

    await _seed(isar);
    await index.rebuild();

    // Con contraseña puesta y el bloqueo cerrado, que es la situación que hay
    // que probar: sin contraseña no se esconde nada a propósito.
    await mode.configure(password: 'la buena');
    mode.lock();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  Future<void> mark(int creatorId) async {
    final result = await repository.setCreatorNsfw(creatorId, isNsfw: true);
    expect(result, isA<DataSuccess>(), reason: 'no se pudo marcar');
  }

  Set<int> idsOf(DataState<List<dynamic>> result) =>
      {for (final one in result.data ?? const []) one.id as int};

  group('con el bloqueo cerrado', () {
    test('el creador marcado no sale en la lista', () async {
      await mark(markedCreatorId);

      expect(idsOf(await repository.getCreators()), {
        plainCreatorId,
        unknownCreatorId,
      });
    });

    test('ni autocompletando', () async {
      await mark(markedCreatorId);

      final found = await repository.searchCreators('marcado');

      expect(found.data, isEmpty);
    });

    test('ni en las sugerencias del buscador', () async {
      await mark(markedCreatorId);

      final found = await repository.searchSuggestions('marcado');

      expect(found.data, isEmpty);
    });

    // Lo que hace que marcar a un creador sirva de algo.
    test('y su contenido tampoco', () async {
      await mark(markedCreatorId);

      final library = await repository.getMediaList();

      expect(idsOf(library), {plainMediaId});
    });

    test('su grupo de la búsqueda no se devuelve', () async {
      await mark(markedCreatorId);

      final found = await repository.searchMediaByCriteria([
        const SearchCriterionEntity(
          kind: SearchCriterionKind.creator,
          id: markedCreatorId,
          label: 'marcado',
        ),
      ]);

      expect(found.data, isEmpty);
    });

    // Un fernie que apunta a un creador escondido **es** ese creador dicho con
    // otro nombre.
    test('un fernie enlazado a él se esconde también', () async {
      await mark(markedCreatorId);

      expect(index.hasFernie(1), isTrue);
    });

    test('el que apunta al otro se queda', () async {
      await mark(markedCreatorId);

      expect(index.hasFernie(2), isFalse);
    });
  });

  group('con el bloqueo abierto', () {
    test('se ve todo otra vez', () async {
      await mark(markedCreatorId);
      await mode.unlock('la buena');

      expect(idsOf(await repository.getCreators()), hasLength(3));
      expect(idsOf(await repository.getMediaList()), hasLength(2));
    });

    // Con el filtro quitado el creador se ve, y hay que poder distinguirlo.
    test('pero se sabe cuál esconde algo', () async {
      await mark(markedCreatorId);
      await mode.unlock('la buena');

      expect(index.hasCreator(markedCreatorId), isTrue);
      expect(index.hasCreator(plainCreatorId), isFalse);
    });
  });

  group('la marca', () {
    test('dice a cuánto contenido afecta', () async {
      final result =
          await repository.setCreatorNsfw(markedCreatorId, isNsfw: true);

      expect(result.data, 1);
    });

    test('se puede quitar', () async {
      await mark(markedCreatorId);
      await repository.setCreatorNsfw(markedCreatorId, isNsfw: false);

      expect(index.hasCreator(markedCreatorId), isFalse);
      expect(idsOf(await repository.getMediaList()), hasLength(2));
    });

    // El respaldo al que van a parar los contenidos que se quedan sin creador:
    // marcarlo escondería media biblioteca de una pulsación.
    test('el desconocido no se puede marcar', () async {
      final result =
          await repository.setCreatorNsfw(unknownCreatorId, isNsfw: true);

      expect(result, isA<DataException>());
      expect(index.hasCreator(unknownCreatorId), isFalse);
    });

    test('lo que ya estaba guardado no está marcado', () async {
      expect(index.hasCreator(plainCreatorId), isFalse);
      expect(index.creators, isEmpty);
    });
  });
}

Future<void> _seed(Isar isar) async {
  await isar.writeTxn(() async {
    await isar.creatorModels.putAll([
      CreatorModel(id: markedCreatorId, name: 'marcado'),
      CreatorModel(id: plainCreatorId, name: 'normal'),
      CreatorModel(id: unknownCreatorId, name: unknownCreator.name),
    ]);

    await isar.fernieModels.putAll([
      FernieModel()
        ..id = 1
        ..name = 'del marcado'
        ..linkedCreatorId = markedCreatorId
        ..createdAt = DateTime(2024),
      FernieModel()
        ..id = 2
        ..name = 'del normal'
        ..linkedCreatorId = plainCreatorId
        ..createdAt = DateTime(2024),
    ]);

    for (final each in [
      (markedMediaId, markedCreatorId),
      (plainMediaId, plainCreatorId),
    ]) {
      final path = r'C:\biblioteca\media_' '${each.$1}.png';

      final summary = MediaSummaryModel()
        ..id = each.$1
        ..path = path
        ..isImported = true
        ..importSource = 'local';

      final details = MediaModel(id: each.$1, path: path)
        ..downloaded = DateTime(2024)
        ..isFavorite = false;

      await isar.mediaSummaryModels.put(summary);
      await isar.mediaModels.put(details);

      details.creator.value = await isar.creatorModels.get(each.$2);
      await details.creator.save();

      summary.details.value = details;
      await summary.details.save();
    }
  });
}

class _Settings implements SettingsRepository {
  final String avatarsPath;

  _Settings({required this.avatarsPath});

  @override
  AppSettingsEntity getSettings() => AppSettingsEntity(
        avatarsPath: avatarsPath,
        recognitionPath: 'reconocimiento',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _MemoryStorage implements NsfwStorage {
  final Map<String, String> values = {};

  @override
  String? read(String key) => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
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
