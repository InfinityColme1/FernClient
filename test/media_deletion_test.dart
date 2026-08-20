// Qué pasa en el disco cuando algo sale de la base de datos.
//
// Se prueba contra una base de datos y ficheros de verdad porque es lo único
// que demuestra lo que importa aquí: que el fichero se ha borrado, o que sigue
// donde estaba. Un repositorio que devuelve bien no dice ninguna de las dos
// cosas.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
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
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory directory;
  late Directory avatars;
  late Isar isar;
  late LocalMediaRepositoryImpl repository;

  // La misma biblioteca nativa que usa la aplicación; sin ella no hay base de
  // datos que probar.
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
    directory = await Directory.systemTemp.createTemp('fern_deletion_test');
    avatars = await Directory(p.join(directory.path, 'avatars')).create();

    isar = await Isar.open(
      [
        TagModelSchema,
        PersonaModelSchema,
        CreatorModelSchema,
        MediaSummaryModelSchema,
        MediaModelSchema,
        // El borrado definitivo se lleva por delante las regiones de fernie, así
        // que la base de datos de la prueba tiene que conocerlas.
        FernieModelSchema,
        FernieRegionModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    final settings = _Settings(avatarsPath: avatars.path);
    final hierarchy = TagHierarchy(database: isar);

    repository = LocalMediaRepositoryImpl(
      appDatabase: isar,
      fileOrganizer: MediaFileOrganizer(settingsRepository: settings),
      avatarStorage: AvatarStorageService(settingsRepository: settings),
      registry: MediaRegistry(database: isar, tagHierarchy: hierarchy),
      tagHierarchy: hierarchy,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  /// Un fichero de verdad en [directory], para poder mirar si sigue ahí.
  Future<File> newFile(String name, {Directory? inside}) {
    return File(p.join((inside ?? directory).path, name))
        .writeAsString('contenido');
  }

  Future<TagEntity> newTag(String name, {String? picturePath}) async {
    final result = await repository.saveTag(
      TagEntity(
        id: unsavedId,
        name: name,
        picturePath: picturePath,
        children: const [],
      ),
    );

    return (result as DataSuccess<TagEntity>).data!;
  }

  /// Un contenido con su sumario, que es donde está la ruta que se mira al
  /// borrar. Se escribe a mano: guardarlo por el repositorio pasa por la
  /// gestión de ficheros, que no es lo que se prueba aquí.
  Future<int> newMedia(File file, {bool isDeleted = false}) {
    return isar.writeTxn(() async {
      final id = await isar.mediaModels.put(
        MediaModel(path: file.path)
          ..downloaded = DateTime(2026)
          ..isFavorite = false,
      );

      await isar.mediaSummaryModels.put(
        MediaSummaryModel()
          ..id = id
          ..path = file.path
          ..isDeleted = isDeleted
          ..deletedAt = isDeleted ? DateTime(2026) : null,
      );

      return id;
    });
  }

  group('el avatar de una etiqueta', () {
    test('se borra con ella', () async {
      final picture = await newFile('avatar.png', inside: avatars);
      final tag = await newTag('Con avatar', picturePath: picture.path);

      await repository.deleteTag(tag.id);

      expect(await picture.exists(), isFalse);
    });

    test('no se toca si está fuera de la carpeta de avatares', () async {
      // Es lo que queda guardado cuando la copia no se pudo hacer: una imagen
      // del usuario, en su sitio, que no es nuestra para borrarla.
      final picture = await newFile('original.png');
      final tag = await newTag('Avatar ajeno', picturePath: picture.path);

      await repository.deleteTag(tag.id);

      expect(await picture.exists(), isTrue);
    });

    test('una etiqueta sin avatar se borra igual', () async {
      final tag = await newTag('Sin avatar');

      final result = await repository.deleteTag(tag.id);

      expect(result, isA<DataSuccess>());
      expect(await isar.tagModels.get(tag.id), isNull);
    });
  });

  group('descartar contenido', () {
    test('deja su fichero donde está', () async {
      final file = await newFile('descartado.jpg');
      final id = await newMedia(file);

      await repository.deleteMediaList([id]);

      expect(await file.exists(), isTrue);
      expect(await isar.mediaSummaryModels.get(id), isNull);
    });

    test('se lo lleva cuando se pide', () async {
      final file = await newFile('descartado.jpg');
      final id = await newMedia(file);

      await repository.deleteMediaList([id], deleteFiles: true);

      expect(await file.exists(), isFalse);
      expect(await isar.mediaSummaryModels.get(id), isNull);
    });

    test('el fichero que ya no está no impide la baja', () async {
      final file = await newFile('fantasma.jpg');
      final id = await newMedia(file);
      await file.delete();

      final result = await repository.deleteMediaList([id], deleteFiles: true);

      expect(result, isA<DataSuccess>());
      expect(await isar.mediaSummaryModels.get(id), isNull);
    });
  });

  group('marcar como favorita una selección', () {
    Future<List<bool>> favoritesOf(List<int> ids) async {
      final models = await isar.mediaModels.getAll(ids);
      return [for (final model in models.nonNulls) model.isFavorite];
    }

    test('marca todos los indicados', () async {
      final first = await newMedia(await newFile('uno.jpg'));
      final second = await newMedia(await newFile('dos.jpg'));

      await repository.setMediaListFavorite([first, second], isFavorite: true);

      expect(await favoritesOf([first, second]), [true, true]);
    });

    test('no toca lo que no está en la lista', () async {
      final marked = await newMedia(await newFile('uno.jpg'));
      final other = await newMedia(await newFile('dos.jpg'));

      await repository.setMediaListFavorite([marked], isFavorite: true);

      expect(await favoritesOf([marked, other]), [true, false]);
    });

    test('el que ya lo era se queda como está', () async {
      final id = await newMedia(await newFile('uno.jpg'));
      await repository.setMediaListFavorite([id], isFavorite: true);

      final result =
          await repository.setMediaListFavorite([id], isFavorite: true);

      expect(result, isA<DataSuccess>());
      expect(await favoritesOf([id]), [true]);
    });
  });

  group('vaciar la papelera', () {
    test('deja los ficheros donde están', () async {
      final file = await newFile('marcado.jpg');
      final id = await newMedia(file, isDeleted: true);

      await repository.purgeDeletedMedia();

      expect(await file.exists(), isTrue);
      expect(await isar.mediaSummaryModels.get(id), isNull);
    });

    test('se los lleva cuando se pide', () async {
      final file = await newFile('marcado.jpg');
      final id = await newMedia(file, isDeleted: true);

      await repository.purgeDeletedMedia(deleteFiles: true);

      expect(await file.exists(), isFalse);
      expect(await isar.mediaSummaryModels.get(id), isNull);
    });

    test('no toca el fichero de lo que no está marcado', () async {
      final kept = await newFile('vivo.jpg');
      await newMedia(kept);
      final purged = await newFile('marcado.jpg');
      await newMedia(purged, isDeleted: true);

      await repository.purgeDeletedMedia(deleteFiles: true);

      expect(await kept.exists(), isTrue);
      expect(await purged.exists(), isFalse);
    });

    test('desde el visor se borra uno solo y el resto se queda', () async {
      // Es lo que hace el botón de borrar del visor cuando lo que se está
      // viendo ya estaba marcado: el mismo borrado, pero de uno en uno.
      final purged = await newFile('visto.jpg');
      final purgedId = await newMedia(purged, isDeleted: true);
      final kept = await newFile('otro.jpg');
      final keptId = await newMedia(kept, isDeleted: true);

      await repository.deleteMediaList([purgedId], deleteFiles: true);

      expect(await purged.exists(), isFalse);
      expect(await isar.mediaSummaryModels.get(purgedId), isNull);
      expect(await kept.exists(), isTrue);
      expect(await isar.mediaSummaryModels.get(keptId), isNotNull);
    });
  });
}

/// La primera `isar.dll` que haya a mano: la de la aplicación compilada o, si
/// todavía no se ha compilado, la que trae el paquete.
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

/// Los únicos ajustes que hacen falta: dónde está la carpeta de avatares, que es
/// lo que decide si una imagen es nuestra y se puede borrar.
class _Settings implements SettingsRepository {
  final String avatarsPath;

  _Settings({required this.avatarsPath});

  @override
  AppSettingsEntity getSettings() => AppSettingsEntity(
        avatarsPath: avatarsPath,
        recognitionPath: 'recognition',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
