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
import 'package:Fern/features/media/domain/services/sibling_direction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:Fern/core/services/shuffle_seed.dart';

/// Las hermanas con la dirección de fábrica: las dos se ponen la una a la otra,
/// que es lo que hacían todas antes de poder elegirlo.
Map<int, SiblingDirection> both(Iterable<int> ids) =>
    {for (final id in ids) id: SiblingDirection.both};

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
    final result = await repository.saveTagSiblings(tagId, both(siblingIds));

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
        await repository.saveTagSiblings(99, both([1])),
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

  // Ser hermanas dice que van juntas; la dirección dice qué pasa al poner una.
  //
  // El caso que lo pedía: «ladybug» es «Marinette», así que poner «ladybug»
  // tiene que poner «Marinette»; pero poner «Marinette» no tiene por qué poner
  // «ladybug», que es sólo uno de sus trajes.
  group('la dirección', () {
    Future<void> relateWith(
      int tagId,
      Map<int, SiblingDirection> siblings,
    ) async {
      final result = await repository.saveTagSiblings(tagId, siblings);

      expect(result, isA<DataSuccess>(), reason: 'no se pudo guardar');
    }

    Future<Set<int>> relativesOf(int tagId) async {
      final tag = await isar.tagModels.get(tagId);
      final expanded = await hierarchy.withRelatives([tag!]);

      return {for (final one in expanded) one.id};
    }

    // Lo que ya está en la base: nadie eligió nada, así que las dos se ponen.
    test('de fábrica, cada una pone la otra', () async {
      await relate(3, [1]);

      expect(await relativesOf(3), {3, 1});
      expect(await relativesOf(1), {1, 3});
    });

    test('de ida, sólo una de las dos', () async {
      await relateWith(3, {1: SiblingDirection.forward});

      expect(await relativesOf(3), {3, 1}, reason: 'ladybug pone Marinette');
      expect(await relativesOf(1), {1}, reason: 'Marinette no pone ladybug');
    });

    test('y de vuelta, la otra', () async {
      await relateWith(3, {1: SiblingDirection.backward});

      expect(await relativesOf(3), {3});
      expect(await relativesOf(1), {1, 3});
    });

    // La relación se queda, y eso es lo que la distingue de no relacionarlas:
    // sigue estando escrito que van juntas.
    test('sin dirección, siguen relacionadas pero no se ponen', () async {
      await relateWith(3, {1: SiblingDirection.none});

      expect(await siblingsOf(3), {1});
      expect(await siblingsOf(1), {3});

      expect(await relativesOf(3), {3});
      expect(await relativesOf(1), {1});
    });

    test('se puede cambiar de opinión', () async {
      await relateWith(3, {1: SiblingDirection.forward});
      await relateWith(3, {1: SiblingDirection.both});

      expect(await relativesOf(1), {1, 3});
    });

    // Cada pareja va por su cuenta.
    test('la de una hermana no toca a las demás', () async {
      await relateWith(3, {
        1: SiblingDirection.forward,
        4: SiblingDirection.both,
      });

      expect(await relativesOf(1), {1});
      expect(await relativesOf(4), {4, 3});
    });

    // Sin esto, un silencio sobreviviría a la relación y reaparecería el día que
    // alguien las volviera a relacionar: la pareja nacería muda sin motivo.
    test('quitar la relación se lleva su dirección', () async {
      await relateWith(3, {1: SiblingDirection.none});
      await relateWith(3, const {});

      // Y al volver a relacionarlas, de fábrica.
      await relate(3, [1]);

      expect(await relativesOf(3), {3, 1});
      expect(await relativesOf(1), {1, 3});
    });

    // Guardar desde un lado escribe en los dos, así que la otra etiqueta tiene
    // que ver lo mismo al abrir su propia ficha.
    test('la ve igual quien la mire desde el otro lado', () async {
      await relateWith(3, {1: SiblingDirection.forward});

      final marinette = (await repository.getTag(1)).data!;
      final ladybug = (await repository.getTag(3)).data!;

      expect(
        siblingDirectionBetween(
          tag: ladybug,
          sibling: ladybug.siblings.single,
        ),
        SiblingDirection.forward,
      );
      expect(
        siblingDirectionBetween(
          tag: marinette,
          sibling: marinette.siblings.single,
        ),
        SiblingDirection.backward,
      );
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
