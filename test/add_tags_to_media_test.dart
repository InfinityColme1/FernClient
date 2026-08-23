// Poner etiquetas en un contenido sin darlo por revisado.
//
// Es el camino de la aceptación masiva de sugerencias, y tiene que dejar el
// contenido igual que si las etiquetas se hubieran puesto a mano: con las que se
// piden **y con las que están por encima de ellas**. Aceptar «Rombo simple» sin
// poner «Rombo» deja el contenido fuera de las búsquedas por la etiqueta padre,
// y la misma acción daría dos resultados distintos según por dónde se haga.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/data/repositories/local_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
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
    directory = await Directory.systemTemp.createTemp('fern_add_tags_test');

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

  /// Un contenido con las etiquetas que se le digan puestas.
  Future<int> addMedia({List<TagModel> tags = const []}) async {
    final summary = MediaSummaryModel()
      ..id = 1
      ..path = 'C:/media/1.jpg';

    final media = MediaModel(id: 1, path: 'C:/media/1.jpg')
      ..downloaded = DateTime(2026)
      ..isFavorite = false;

    await isar.writeTxn(() async {
      await isar.mediaSummaryModels.put(summary);
      await isar.mediaModels.put(media);

      if (tags.isNotEmpty) await media.tags.update(link: tags);
    });

    return 1;
  }

  var _nextTag = 1;

  /// Una etiqueta, colgando de [parent] si se dice.
  Future<TagModel> addTag(String name, {TagModel? parent}) async {
    final tag = TagModel(id: _nextTag++, name: name);

    await isar.writeTxn(() async {
      await isar.tagModels.put(tag);

      if (parent != null) await parent.children.update(link: [tag]);
    });

    return tag;
  }

  Future<List<String>> tagsOf(int mediaId) async {
    final media = await isar.mediaModels.get(mediaId);
    await media!.tags.load();

    return [for (final tag in media.tags) tag.name]..sort();
  }

  group('lo que pone', () {
    test('la etiqueta que se pide', () async {
      final rombo = await addTag('Rombo');
      final media = await addMedia();

      await repository.addTagsToMedia(media, [rombo.id]);

      expect(await tagsOf(media), ['Rombo']);
    });

    test('y las que están por encima de ella', () async {
      final figuras = await addTag('Figuras');
      final rombo = await addTag('Rombo', parent: figuras);
      final simple = await addTag('Rombo simple', parent: rombo);

      final media = await addMedia();

      await repository.addTagsToMedia(media, [simple.id]);

      // La cadena entera: sin esto el contenido no sale al buscar por «Figuras»
      // aunque lleve una etiqueta que cuelga de ella.
      expect(await tagsOf(media), ['Figuras', 'Rombo', 'Rombo simple']);
    });

    test('suma a lo que ya tenía', () async {
      final puesta = await addTag('A mano');
      final nueva = await addTag('Del modelo');

      final media = await addMedia(tags: [puesta]);

      // Con `reset` en vez de sumar, aceptar una sugerencia borraría las
      // etiquetas puestas a mano.
      await repository.addTagsToMedia(media, [nueva.id]);

      expect(await tagsOf(media), ['A mano', 'Del modelo']);
    });

    test('una que ya estaba no se duplica', () async {
      final rombo = await addTag('Rombo');
      final media = await addMedia(tags: [rombo]);

      await repository.addTagsToMedia(media, [rombo.id]);

      expect(await tagsOf(media), ['Rombo']);
    });
  });

  group('lo que no hace', () {
    test('no da el contenido por revisado', () async {
      final rombo = await addTag('Rombo');
      final media = await addMedia();

      await repository.addTagsToMedia(media, [rombo.id]);

      // Poner etiquetas y dar por revisado son dos cosas: en la pantalla de
      // importación hay un botón de confirmar justo al lado.
      expect((await isar.mediaSummaryModels.get(media))!.isImported, isFalse);
    });

    test('un contenido que no existe se dice', () async {
      final rombo = await addTag('Rombo');

      expect(
        await repository.addTagsToMedia(999, [rombo.id]),
        isA<DataException>(),
      );
    });

    test('una etiqueta que no existe no pone nada', () async {
      final media = await addMedia();

      final result = await repository.addTagsToMedia(media, [999]);

      expect(result.data, 0);
      expect(await tagsOf(media), isEmpty);
    });
  });
}

/// Ni ficheros ni avatares: poner una etiqueta no toca el disco, y si algún día
/// lo tocara, esto lo diría en vez de dejarlo pasar.
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
