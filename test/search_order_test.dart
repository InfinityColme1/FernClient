// Ordenar los resultados de una búsqueda.
//
// Buscar «Nami» devolvía todo lo que encaja y ahí se acababa: no había forma de
// mirarlo por lo último que llegó, ni al azar, ni por descripción. Con una
// búsqueda que trae doscientos contenidos eso es tanto contenido como la
// biblioteca entera, así que era la única pantalla donde había que mirar lo que
// saliera en el orden que saliera.
//
// El orden se aplica **dentro de cada grupo**: los grupos son de qué va cada
// coincidencia —esta etiqueta, este creador— y eso no es una ordenación.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/shuffle_seed.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/media_tag_log_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/data/repositories/local_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/media/domain/entities/media_sort_order.dart';
import 'package:Fern/features/media/domain/entities/search/media_search_section_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_criterion_entity.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

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

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fern_search_order');

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

    repository = LocalMediaRepositoryImpl(
      shuffle: ShuffleSeed(),
      appDatabase: isar,
      fileOrganizer: _NoFiles(),
      avatarStorage: _NoAvatars(),
      registry: MediaRegistry(
        database: isar,
        tagHierarchy: TagHierarchy(database: isar),
      ),
      tagHierarchy: TagHierarchy(database: isar),
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  /// Un contenido definitivo con su descripción y su fecha.
  Future<void> addMedia(int id, String description, DateTime at) async {
    final summary = MediaSummaryModel()
      ..id = id
      ..path = 'C:/media/$id.jpg'
      ..isImported = true;

    final details = MediaModel(id: id, path: 'C:/media/$id.jpg')
      ..downloaded = at
      ..isFavorite = false
      ..description = description;

    await isar.writeTxn(() async {
      await isar.mediaSummaryModels.put(summary);
      await isar.mediaModels.put(details);
      summary.details.value = details;
      await summary.details.save();
    });
  }

  Future<List<int>> search(String term, MediaSortOrder order) async {
    final result = await repository.searchMediaByCriteria(
      [SearchCriterionEntity.text(term)],
      order: order,
    );

    final sections =
        (result as DataSuccess<List<MediaSearchSectionEntity>>).data!;

    return [
      for (final section in sections)
        for (final media in section.media) media.id,
    ];
  }

  group('el orden de los resultados', () {
    setUp(() async {
      await addMedia(1, 'nami primera', DateTime(2026, 1, 1));
      await addMedia(2, 'nami segunda', DateTime(2026, 6, 1));
      await addMedia(3, 'nami tercera', DateTime(2026, 3, 1));
    });

    test('lo más nuevo primero', () async {
      expect(await search('nami', MediaSortOrder.newestFirst), [2, 3, 1]);
    });

    test('y lo más viejo primero', () async {
      expect(await search('nami', MediaSortOrder.oldestFirst), [1, 3, 2]);
    });

    test('o por lo que dice su descripción', () async {
      expect(await search('nami', MediaSortOrder.description), [1, 2, 3]);
    });

    // Que salga en un orden u otro es lo de menos: lo que no puede pasar es que
    // se pierda o se repita contenido por ordenarlo.
    test('al azar están todos y una sola vez', () async {
      final shuffled = await search('nami', MediaSortOrder.random);

      expect(shuffled..sort(), [1, 2, 3]);
    });

    test('sin decir nada, lo más nuevo', () async {
      final result = await repository.searchMediaByCriteria(
        [SearchCriterionEntity.text('nami')],
      );

      final sections =
          (result as DataSuccess<List<MediaSearchSectionEntity>>).data!;

      expect([for (final media in sections.single.media) media.id], [2, 3, 1]);
    });
  });

  // Con dos pastillas el resultado es un grupo único con el cruce, y ahí el
  // orden importa igual.
  group('cruzando pastillas', () {
    test('el cruce también sale ordenado', () async {
      await addMedia(1, 'nami una', DateTime(2026, 1, 1));
      await addMedia(2, 'nami otra', DateTime(2026, 6, 1));

      final tag = TagModel(id: 1, name: 'grupo');
      await isar.writeTxn(() async {
        await isar.tagModels.put(tag);

        for (final id in [1, 2]) {
          final media = await isar.mediaModels.get(id);
          await media!.tags.update(link: [tag]);
        }
      });

      final result = await repository.searchMediaByCriteria(
        [
          SearchCriterionEntity.text('nami'),
          const SearchCriterionEntity(
            kind: SearchCriterionKind.tag,
            id: 1,
            label: 'grupo',
          ),
        ],
        order: MediaSortOrder.oldestFirst,
      );

      final sections =
          (result as DataSuccess<List<MediaSearchSectionEntity>>).data!;

      expect([for (final media in sections.single.media) media.id], [1, 2]);
    });
  });
}

/// Ni ficheros ni avatares: buscar no toca el disco.
class _NoFiles implements MediaFileOrganizer {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _NoAvatars implements AvatarStorageService {
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
