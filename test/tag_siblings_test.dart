// Etiquetas relacionadas: las que van juntas sin colgar unas de otras.
//
// Contra base de datos de verdad porque lo que hay que comprobar es lo que
// sobrevive a la escritura: que la relación quede en **los dos lados**. Una
// relación a medias no se ve —la etiqueta que no sabe que es hermana de la otra
// sencillamente no la pone— y el usuario descubriría que a veces funciona y a
// veces no sin ninguna pista de por qué.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/data/repositories/local_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:Fern/core/services/shuffle_seed.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late LocalMediaRepositoryImpl repository;
  late TagHierarchy hierarchy;

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
    directory = await Directory.systemTemp.createTemp('fern_siblings_test');
    final avatars = await Directory(p.join(directory.path, 'avatars')).create();

    isar = await Isar.open(
      [
        TagModelSchema,
        PersonaModelSchema,
        CreatorModelSchema,
        MediaSummaryModelSchema,
        MediaModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    final settings = _Settings(avatarsPath: avatars.path);
    hierarchy = TagHierarchy(database: isar);

    repository = LocalMediaRepositoryImpl(
      shuffle: ShuffleSeed(),
      appDatabase: isar,
      fileOrganizer: MediaFileOrganizer(settingsRepository: settings),
      avatarStorage: AvatarStorageService(settingsRepository: settings),
      registry: MediaRegistry(database: isar, tagHierarchy: hierarchy),
      tagHierarchy: hierarchy,
    );

    await isar.writeTxn(() async {
      await isar.tagModels.putAll([
        TagModel(id: 1, name: 'marinette'),
        TagModel(id: 2, name: 'miraculous'),
        TagModel(id: 3, name: 'ladybug'),
        TagModel(id: 4, name: 'parís'),
      ]);
    });
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  /// Las hermanas guardadas de [tagId], por identificador.
  Future<Set<int>> siblingsOf(int tagId) async {
    final tag = await isar.tagModels.get(tagId);
    await tag!.siblings.load();

    return {for (final sibling in tag.siblings) sibling.id};
  }

  Future<void> relate(int tagId, List<int> siblingIds) async {
    final result = await repository.saveTagSiblings(tagId, siblingIds);

    expect(result, isA<DataSuccess>(), reason: 'no se pudo guardar');
  }

  group('la relación', () {
    test('queda en los dos lados', () async {
      await relate(1, [3]);

      expect(await siblingsOf(1), {3});
      expect(await siblingsOf(3), {1});
    });

    test('quitarla la quita en los dos', () async {
      await relate(1, [3]);
      await relate(1, const []);

      expect(await siblingsOf(1), isEmpty);
      expect(await siblingsOf(3), isEmpty);
    });

    test('quitar una no se lleva a las demás', () async {
      await relate(1, [3, 4]);
      await relate(1, [4]);

      expect(await siblingsOf(1), {4});
      expect(await siblingsOf(3), isEmpty);
      expect(await siblingsOf(4), {1});
    });

    // Una etiqueta hermana de sí misma se pondría dos veces y no significaría
    // nada.
    test('una etiqueta no es hermana de sí misma', () async {
      await relate(1, [1, 3]);

      expect(await siblingsOf(1), {3});
    });

    test('una etiqueta que no existe no se puede relacionar', () async {
      expect(
        await repository.saveTagSiblings(99, [1]),
        isA<DataException>(),
      );
    });

    test('las que no existen se ignoran', () async {
      await relate(1, [3, 99]);

      expect(await siblingsOf(1), {3});
    });
  });

  group('al etiquetar', () {
    Future<Set<int>> relativesOf(int tagId) async {
      final tag = await isar.tagModels.get(tagId);
      final expanded = await hierarchy.withRelatives([tag!]);

      return {for (final one in expanded) one.id};
    }

    test('con la etiqueta van sus hermanas', () async {
      await relate(1, [3]);

      expect(await relativesOf(1), {1, 3});
    });

    // Encadenarlas convertiría una etiqueta en media biblioteca, y nadie sabría
    // por qué un contenido acabó con veinte.
    test('pero no las hermanas de sus hermanas', () async {
      await relate(1, [3]);
      await relate(3, [1, 4]);

      expect(await relativesOf(1), {1, 3});
    });

    test('y con todas van sus madres', () async {
      // 2 es madre de 3: relacionar 1 con 3 tiene que traerse también a 2.
      final parent = await isar.tagModels.get(2);
      final child = await isar.tagModels.get(3);

      await isar.writeTxn(() async {
        parent!.children.add(child!);
        await parent.children.save();
      });

      await relate(1, [3]);

      expect(await relativesOf(1), {1, 2, 3});
    });

    test('sin hermanas, lo de siempre', () async {
      expect(await relativesOf(1), {1});
    });
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
