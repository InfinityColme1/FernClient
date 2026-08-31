// Los nombres de etiqueta son únicos.
//
// Dos etiquetas llamadas igual no se pueden distinguir en el menú, ni en el
// buscador, ni al arrastrarles contenido encima: quien las ve no tiene forma de
// saber cuál es cuál, y quien las creó tampoco.
//
// Se comprueba en el repositorio y no en el formulario porque es el punto único
// por el que pasan crear y renombrar: un guardián en la pantalla deja fuera
// cualquier otro camino que llegue a guardar.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
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
import 'package:Fern/features/media/domain/entities/duplicate_tag_name.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
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
    directory = await Directory.systemTemp.createTemp('fern_tag_name_test');

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

  TagEntity nueva(String name) => TagEntity(
        id: unsavedId,
        name: name,
        children: const [],
        sourceUrls: const [],
      );

  Future<DataState<TagEntity>> crear(String name) =>
      repository.saveTag(nueva(name));

  Future<int> cuantas() async => isar.tagModels.count();

  group('al crear', () {
    test('la primera pasa', () async {
      expect(await crear('Paisajes'), isA<DataSuccess<TagEntity>>());
      expect(await cuantas(), 1);
    });

    test('la segunda con el mismo nombre, no', () async {
      await crear('Paisajes');
      final segunda = await crear('Paisajes');

      expect(segunda.exception, isA<DuplicateTagNameException>());
      expect(await cuantas(), 1, reason: 'no se ha guardado nada');
    });

    test('las mayúsculas no hacen una etiqueta distinta', () async {
      await crear('Paisajes');

      expect((await crear('paisajes')).exception,
          isA<DuplicateTagNameException>());
    });

    test('los espacios de los extremos tampoco', () async {
      await crear('Paisajes');

      expect((await crear('  Paisajes ')).exception,
          isA<DuplicateTagNameException>());
    });

    test('el nombre se guarda sin los espacios de los extremos', () async {
      final creada = await crear('  Paisajes ');

      expect(creada.data?.name, 'Paisajes');
    });

    test('un nombre distinto sí pasa', () async {
      await crear('Paisajes');

      expect(await crear('Retratos'), isA<DataSuccess<TagEntity>>());
      expect(await cuantas(), 2);
    });
  });

  group('al renombrar', () {
    test('ponerle el nombre de otra, no', () async {
      await crear('Paisajes');
      final otra = (await crear('Retratos')).data!;

      final renombrada = await repository.updateTag(
        TagEntity(
          id: otra.id,
          name: 'Paisajes',
          children: const [],
          sourceUrls: const [],
        ),
      );

      expect(renombrada.exception, isA<DuplicateTagNameException>());
      expect((await isar.tagModels.get(otra.id))?.name, 'Retratos');
    });

    test('dejarle el suyo, sí', () async {
      // Lo que un guardián mal hecho rompe: guardar la ficha sin tocar el nombre
      // contaría como repetirlo, y no se podría cambiar el avatar de nada.
      final tag = (await crear('Paisajes')).data!;

      final guardada = await repository.updateTag(
        TagEntity(
          id: tag.id,
          name: 'Paisajes',
          children: const [],
          sourceUrls: const [],
        ),
      );

      expect(guardada, isA<DataSuccess<TagEntity>>());
    });
  });
}

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
      '${Platform.environment['LOCALAPPDATA']}\Pub\Cache';

  final candidates = [
    r'build\windows\x64\runner\Debug\isar.dll',
    r'build\windows\x64\runner\Release\isar.dll',
    '$pubCache\hosted\pub.dev\isar_flutter_libs-3.1.0+1\windows\isar.dll',
  ];

  for (final candidate in candidates) {
    if (File(candidate).existsSync()) return candidate;
  }

  return null;
}
