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
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

/// La jerarquía de etiquetas contra una base de datos de verdad.
///
/// Es lo único que prueba que un cambio en los enlaces se ha escrito: el
/// repositorio devuelve bien aunque la baja no llegue a la base de datos, y eso
/// sólo se ve volviendo a leer.
void main() {
  late Directory directory;
  late Isar isar;
  late LocalMediaRepositoryImpl repository;

  // La biblioteca nativa que usa Isar fuera de la aplicación. Se coge la que la
  // propia aplicación se lleva a su carpeta al compilar, para no depender de
  // descargarla; sin ella no hay base de datos que probar y las pruebas se
  // saltan en lugar de fallar.
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
    directory = await Directory.systemTemp.createTemp('fern_tags_test');
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

    repository = LocalMediaRepositoryImpl(
      appDatabase: isar,
      fileOrganizer: MediaFileOrganizer(settingsRepository: _NoSettings()),
      avatarStorage: AvatarStorageService(settingsRepository: _NoSettings()),
      registry: MediaRegistry(database: isar),
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  Future<TagEntity> newTag(String name, {TagEntity? parent}) async {
    final result = await repository.saveTag(
      TagEntity(id: unsavedId, name: name, children: const []),
      parent: parent,
    );

    return (result as DataSuccess<TagEntity>).data!;
  }

  Future<List<TagEntity>> tree() async {
    final result = await repository.getTagTree();
    return (result as DataSuccess<List<TagEntity>>).data!;
  }

  test('una etiqueta nueva cuelga de su padre', () async {
    final parent = await newTag('Padre');
    await newTag('Hija', parent: parent);

    final roots = await tree();

    expect(roots.map((tag) => tag.name), ['Padre']);
    expect(roots.single.children.map((tag) => tag.name), ['Hija']);
  });

  test('quitarle el padre la deja como raíz al volver a leer', () async {
    final parent = await newTag('Padre');
    final child = await newTag('Hija', parent: parent);

    await repository.updateTag(
      TagEntity(id: child.id, name: child.name, children: const []),
      parent: null,
    );

    final roots = await tree();

    expect(roots.map((tag) => tag.name), ['Hija', 'Padre']);
    expect(roots.every((tag) => tag.children.isEmpty), isTrue);
  });

  test('cambiar de padre la saca de las hijas del anterior', () async {
    final first = await newTag('Primero');
    final second = await newTag('Segundo');
    final child = await newTag('Hija', parent: first);

    await repository.updateTag(
      TagEntity(id: child.id, name: child.name, children: const []),
      parent: second,
    );

    final roots = await tree();

    expect(roots.map((tag) => tag.name), ['Primero', 'Segundo']);
    expect(roots.first.children, isEmpty);
    expect(roots.last.children.map((tag) => tag.name), ['Hija']);
  });

  test('guardar el resto de los datos no le quita las hijas', () async {
    final parent = await newTag('Padre');
    await newTag('Hija', parent: parent);

    await repository.updateTag(
      TagEntity(id: parent.id, name: 'Padre renombrado', children: const []),
      parent: null,
    );

    final roots = await tree();

    expect(roots.map((tag) => tag.name), ['Padre renombrado']);
    expect(roots.single.children.map((tag) => tag.name), ['Hija']);
  });

  test('borrar una etiqueta deja a sus hijas como raíces', () async {
    final parent = await newTag('Padre');
    await newTag('Hija', parent: parent);

    await repository.deleteTag(parent.id);

    final roots = await tree();

    expect(roots.map((tag) => tag.name), ['Hija']);
  });

  test('no puede colgar de sí misma', () async {
    final tag = await newTag('Sola');

    await repository.updateTag(
      TagEntity(id: tag.id, name: tag.name, children: const []),
      parent: tag,
    );

    final roots = await tree();

    expect(roots.map((tag) => tag.name), ['Sola']);
    expect(roots.single.children, isEmpty);
  });

  test('no puede colgar de una de sus hijas', () async {
    final parent = await newTag('Padre');
    final child = await newTag('Hija', parent: parent);

    await repository.updateTag(
      TagEntity(id: parent.id, name: parent.name, children: const []),
      parent: child,
    );

    // La jerarquía se queda como estaba: la hija sigue colgando del padre y el
    // padre sigue siendo la raíz.
    final roots = await tree();

    expect(roots.map((tag) => tag.name), ['Padre']);
    expect(roots.single.children.map((tag) => tag.name), ['Hija']);
  });

  test('no puede colgar de la hija de una de sus hijas', () async {
    final grandparent = await newTag('Abuela');
    final parent = await newTag('Madre', parent: grandparent);
    final child = await newTag('Hija', parent: parent);

    await repository.updateTag(
      TagEntity(id: grandparent.id, name: grandparent.name, children: const []),
      parent: child,
    );

    final roots = await tree();

    expect(roots.map((tag) => tag.name), ['Abuela']);
    expect(roots.single.children.single.children.map((tag) => tag.name), ['Hija']);
  });

  test('el intento de cerrar el círculo no la suelta de su padre', () async {
    final grandparent = await newTag('Abuela');
    final parent = await newTag('Madre', parent: grandparent);
    final child = await newTag('Hija', parent: parent);

    // «Madre» no puede colgar de «Hija», así que se queda colgando de «Abuela»,
    // que es donde estaba.
    await repository.updateTag(
      TagEntity(id: parent.id, name: parent.name, children: const []),
      parent: child,
    );

    final roots = await tree();

    expect(roots.map((tag) => tag.name), ['Abuela']);
    expect(roots.single.children.map((tag) => tag.name), ['Madre']);
    expect(roots.single.children.single.children.map((tag) => tag.name), ['Hija']);
  });

  test('el intento de cerrar el círculo no impide guardar el resto', () async {
    final parent = await newTag('Padre');
    final child = await newTag('Hija', parent: parent);

    await repository.updateTag(
      TagEntity(id: parent.id, name: 'Padre renombrado', children: const []),
      parent: child,
    );

    final roots = await tree();

    expect(roots.map((tag) => tag.name), ['Padre renombrado']);
    expect(roots.single.children.map((tag) => tag.name), ['Hija']);
  });

  /// Un contenido con las etiquetas que se le pasen, escrito a mano: guardarlo
  /// por el repositorio pasa por los ajustes de ficheros, que aquí no hay.
  Future<int> newMedia(String path, List<TagEntity> tags) async {
    return isar.writeTxn(() async {
      final model = MediaModel(path: path)
        ..downloaded = DateTime(2026)
        ..isFavorite = false;

      final id = await isar.mediaModels.put(model);

      final tagModels = await isar.tagModels.getAll(tags.map((t) => t.id).toList());
      model.tags.addAll(tagModels.nonNulls);
      await model.tags.save();

      return id;
    });
  }

  Future<List<String>> tagsOf(int mediaId) async {
    final model = await isar.mediaModels.get(mediaId);
    await model!.tags.load();

    return model.tags.map((tag) => tag.name).toList();
  }

  test('quitarle una etiqueta a un contenido le deja las demás', () async {
    final removed = await newTag('Quitada');
    final kept = await newTag('Queda');
    final mediaId = await newMedia('uno.jpg', [removed, kept]);

    await repository.removeTagFromMedia(removed.id, [mediaId]);

    expect(await tagsOf(mediaId), ['Queda']);
  });

  test('borrar una etiqueta se la quita a sus contenidos', () async {
    final deleted = await newTag('Borrada');
    final kept = await newTag('Queda');
    final mediaId = await newMedia('uno.jpg', [deleted, kept]);

    await repository.deleteTag(deleted.id);

    expect(await tagsOf(mediaId), ['Queda']);
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

/// Los ajustes no se usan en nada de lo que se prueba aquí: la jerarquía de
/// etiquetas no toca el disco.
class _NoSettings implements SettingsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
