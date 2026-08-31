// Buscar por varias cosas a la vez.
//
// Contra base de datos de verdad porque lo que hay que sostener son las consultas:
// una pastilla sola tiene que devolver **lo mismo que devolvía el buscador de
// antes**, agrupado igual, y dos o más tienen que cruzarse —lo que cumple las
// dos, no lo que cumple alguna— y venir en un solo grupo.
//
// Y el nombre de fichero, que antes no se buscaba en ningún sitio: la consulta va
// por la ruta entera porque es lo único que sabe filtrar Isar, así que hay que
// comprobar que las carpetas de la biblioteca no cuentan como coincidencia. Sin
// eso, buscar «Users» devolvería la biblioteca completa.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/shuffle_seed.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media_tag_log_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/data/repositories/local_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/media/domain/entities/search/media_search_section_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_criterion_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory directory;
  late Isar isar;
  late LocalMediaRepositoryImpl repository;

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

  /// Da de alta un contenido ya definitivo, con sus etiquetas y su creador.
  Future<void> addMedia(
    int id, {
    required String path,
    String? description,
    List<int> tags = const [],
    int? creator,
  }) async {
    await isar.writeTxn(() async {
      final summary = MediaSummaryModel()
        ..id = id
        ..path = path
        ..isImported = true
        ..importSource = 'local';

      final details = MediaModel(id: id, path: path)
        ..downloaded = DateTime(2024)
        ..isFavorite = false
        ..description = description;

      await isar.mediaSummaryModels.put(summary);
      await isar.mediaModels.put(details);

      if (tags.isNotEmpty) {
        await details.tags
            .update(link: (await isar.tagModels.getAll(tags)).nonNulls);
      }
      if (creator != null) {
        details.creator.value = await isar.creatorModels.get(creator);
        await details.creator.save();
      }

      summary.details.value = details;
      await summary.details.save();
    });
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fern_criteria_test');
    final avatars = await Directory(p.join(directory.path, 'avatars')).create();

    isar = await Isar.open(
      [
        TagModelSchema,
        PersonaModelSchema,
        CreatorModelSchema,
        MediaSummaryModelSchema,
        MediaModelSchema,
        MediaTagLogModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

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

    await isar.writeTxn(() async {
      await isar.tagModels.putAll([
        TagModel(id: 1, name: 'ladybug'),
        TagModel(id: 2, name: 'paisaje'),
      ]);
      await isar.creatorModels.putAll([
        CreatorModel(id: 10, name: 'Pompeu'),
        CreatorModel(id: 11, name: 'Otro'),
      ]);
    });

    // 100: ladybug + Pompeu     101: ladybug + Otro
    // 102: paisaje + Pompeu     103: nada, con descripción
    await addMedia(100, path: r'C:\biblioteca\uno.png', tags: [1], creator: 10);
    await addMedia(101, path: r'C:\biblioteca\dos.png', tags: [1], creator: 11);
    await addMedia(102, path: r'C:\biblioteca\tres.png', tags: [2], creator: 10);
    await addMedia(
      103,
      path: r'C:\biblioteca\cuatro.png',
      description: 'una ladybug de perfil',
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  Future<List<MediaSearchSectionEntity>> search(
    List<SearchCriterionEntity> criteria,
  ) async {
    final result = await repository.searchMediaByCriteria(criteria);
    expect(result, isA<DataSuccess>());

    return result.data ?? const [];
  }

  /// Todo lo que sale, sin repetir y sin importar en qué grupo.
  Future<Set<int>> found(List<SearchCriterionEntity> criteria) async {
    final sections = await search(criteria);

    return {
      for (final section in sections)
        for (final media in section.media) media.id,
    };
  }

  const ladybug = SearchCriterionEntity(
    kind: SearchCriterionKind.tag,
    id: 1,
    label: 'ladybug',
  );
  const pompeu = SearchCriterionEntity(
    kind: SearchCriterionKind.creator,
    id: 10,
    label: 'Pompeu',
  );

  group('sin pastillas', () {
    test('no se busca nada', () async {
      expect(await search(const []), isEmpty);
    });

    test('una pastilla vacía tampoco cuenta', () async {
      expect(await search([const SearchCriterionEntity.text('   ')]), isEmpty);
    });
  });

  group('una sola pastilla', () {
    test('la de una etiqueta trae su contenido, en su grupo', () async {
      final sections = await search([ladybug]);

      expect(sections, hasLength(1));
      expect(sections.single.type, SearchResultType.tag);
      expect(sections.single.title, 'ladybug');
      expect({for (final m in sections.single.media) m.id}, {100, 101});
    });

    // El comportamiento de siempre: escribir devolvía las coincidencias por
    // texto y además un grupo por cada etiqueta y creador cuyo nombre encajara.
    test('la de texto libre sigue trayendo los grupos de antes', () async {
      final sections = await search([const SearchCriterionEntity.text('ladybug')]);

      // El grupo del texto (por la descripción de 103) y el de la etiqueta.
      expect(sections.map((s) => s.type), [
        SearchResultType.media,
        SearchResultType.tag,
      ]);
      expect(await found([const SearchCriterionEntity.text('ladybug')]),
          {100, 101, 103});
    });

    test('y el grupo de texto lleva por título lo escrito', () async {
      final sections = await search([const SearchCriterionEntity.text('ladybug')]);

      expect(sections.first.title, 'ladybug');
    });
  });

  group('cruzando pastillas', () {
    test('sale lo que cumple las dos, no lo que cumple alguna', () async {
      expect(await found([ladybug, pompeu]), {100});
    });

    test('en un solo grupo y sin cabecera', () async {
      final sections = await search([ladybug, pompeu]);

      expect(sections, hasLength(1));
      expect(sections.single.title, isEmpty);
      expect(sections.single.type, SearchResultType.media);
    });

    test('sin nada en común no sale nada', () async {
      const paisaje = SearchCriterionEntity(
        kind: SearchCriterionKind.tag,
        id: 2,
        label: 'paisaje',
      );
      const otro = SearchCriterionEntity(
        kind: SearchCriterionKind.creator,
        id: 11,
        label: 'Otro',
      );

      expect(await found([paisaje, otro]), isEmpty);
    });

    test('el texto libre se cruza como una más', () async {
      // «uno» sólo encaja con el nombre de fichero de 100.
      expect(
        await found([ladybug, const SearchCriterionEntity.text('uno')]),
        {100},
      );
    });

    test('tres pastillas siguen cruzándose', () async {
      expect(
        await found([
          ladybug,
          pompeu,
          const SearchCriterionEntity.text('uno'),
        ]),
        {100},
      );
    });

    // El contenido no puede salir dos veces aunque encaje por varios sitios.
    test('sin repetidos', () async {
      final sections = await search([
        const SearchCriterionEntity.text('ladybug'),
        ladybug,
      ]);

      final ids = [
        for (final section in sections)
          for (final media in section.media) media.id,
      ];

      expect(ids, ids.toSet().toList());
    });
  });

  group('el nombre de fichero', () {
    test('cuenta como coincidencia', () async {
      expect(
        await found([const SearchCriterionEntity.text('tres')]),
        {102},
      );
    });

    // La consulta va por la ruta entera porque es lo único que sabe filtrar
    // Isar. Si lo que sobra no se cayera, buscar el nombre de una carpeta
    // devolvería la biblioteca completa.
    test('pero la carpeta no', () async {
      expect(await found([const SearchCriterionEntity.text('biblioteca')]),
          isEmpty);
    });

    test('ni la unidad', () async {
      expect(await found([const SearchCriterionEntity.text('C:')]), isEmpty);
    });
  });

  group('la descripción', () {
    test('sigue contando', () async {
      expect(await found([const SearchCriterionEntity.text('perfil')]), {103});
    });
  });

  test('una entidad que ya no está no devuelve nada', () async {
    const borrada = SearchCriterionEntity(
      kind: SearchCriterionKind.tag,
      id: 99,
      label: 'la que fue',
    );

    expect(await found([borrada, pompeu]), isEmpty);
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
