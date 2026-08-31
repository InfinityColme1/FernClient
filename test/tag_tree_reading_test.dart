// Lo que el árbol de etiquetas trae consigo, y lo que guardar una etiqueta NO
// puede llevarse por delante.
//
// Contra base de datos de verdad porque el fallo que esto protege era de
// lectura: `getTagTree` armaba cada `TagEntity` a mano y se dejaba fuera las
// direcciones vinculadas y las hermanas. La ficha de la pantalla de gestión se
// pinta con eso, así que nacía con las dos listas vacías, y como `updateTag`
// escribía lo que se le daba, **guardar el nombre de una etiqueta le borraba las
// direcciones**. Lo mismo al arrastrarla en la lista para colgarla de otra, que
// manda la entidad del árbol tal cual.
//
// El arreglo tiene dos mitades y las dos se comprueban aquí: el árbol trae los
// campos, y `updateTag` ya no toca las direcciones pase lo que pase.

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
    directory = await Directory.systemTemp.createTemp('fern_tag_tree_test');
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
        TagModel(
          id: 1,
          name: 'ladybug',
          sourceUrls: const ['reddit.com/r/miraculous'],
        ),
        TagModel(id: 2, name: 'serie'),
        TagModel(id: 3, name: 'akumatizados'),
      ]);
    });
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  /// La etiqueta [id] tal y como la ve la pantalla de gestión: del árbol, que es
  /// de donde la saca `TagsBloc`.
  Future<TagEntity> fromTree(int id) async {
    final result = await repository.getTagTree();
    expect(result, isA<DataSuccess>());

    TagEntity? find(List<TagEntity> tags) {
      for (final tag in tags) {
        if (tag.id == id) return tag;
        final found = find(tag.children);
        if (found != null) return found;
      }
      return null;
    }

    final tag = find(result.data ?? const []);
    expect(tag, isNotNull, reason: 'la etiqueta $id no está en el árbol');

    return tag!;
  }

  /// Las direcciones guardadas de [id], leídas de la fila y no de la entidad.
  Future<List<String>> storedUrls(int id) async =>
      (await isar.tagModels.get(id))!.sourceUrls;

  Future<Set<int>> storedSiblings(int id) async {
    final tag = await isar.tagModels.get(id);
    await tag!.siblings.load();

    return {for (final sibling in tag.siblings) sibling.id};
  }

  group('el árbol', () {
    test('trae las direcciones de cada etiqueta', () async {
      expect((await fromTree(1)).sourceUrls, ['reddit.com/r/miraculous']);
    });

    // El caso del enunciado: la relación se crea desde una y se tiene que ver
    // desde las dos.
    test('trae las hermanas, se creara la relación desde donde se creara',
        () async {
      await repository.saveTagSiblings(1, both([2]));

      expect((await fromTree(1)).siblings.map((tag) => tag.name), ['serie']);
      expect((await fromTree(2)).siblings.map((tag) => tag.name), ['ladybug']);
    });

    test('las hermanas llegan planas, sin las suyas', () async {
      await repository.saveTagSiblings(1, both([2]));
      await repository.saveTagSiblings(2, both([1, 3]));

      final siblings = (await fromTree(1)).siblings;

      expect(siblings.map((tag) => tag.name), ['serie']);
      expect(siblings.single.siblings, isEmpty);
      expect(siblings.single.children, isEmpty);
    });
  });

  group('guardar una etiqueta', () {
    test('no toca sus direcciones', () async {
      final tag = await fromTree(1);

      final result = await repository.updateTag(
        TagEntity(id: tag.id, name: 'ladybug renombrada', children: const []),
      );
      expect(result, isA<DataSuccess>());

      expect(await storedUrls(1), ['reddit.com/r/miraculous']);
    });

    // Arrastrar una etiqueta sobre otra manda la entidad del árbol tal cual a
    // `updateTag`. Con las direcciones dentro de esa escritura, arrastrar las
    // borraba sin que nadie tocara el formulario.
    test('colgarla de otra tampoco', () async {
      final dragged = await fromTree(1);
      final target = await fromTree(2);

      final result = await repository.updateTag(dragged, parent: target);
      expect(result, isA<DataSuccess>());

      expect(await storedUrls(1), ['reddit.com/r/miraculous']);
      expect((await fromTree(1)).sourceUrls, ['reddit.com/r/miraculous']);
    });

    // Ni siquiera pasándole una entidad con las direcciones vacías a propósito:
    // el campo tiene su propia escritura y ésta no es.
    test('ni aunque se le pase una entidad sin direcciones', () async {
      final result = await repository.updateTag(
        const TagEntity(id: 1, name: 'ladybug', children: [], sourceUrls: []),
      );
      expect(result, isA<DataSuccess>());

      expect(await storedUrls(1), ['reddit.com/r/miraculous']);
    });
  });

  // Es lo que hace la pantalla de gestión al soltar una etiqueta sobre otra
  // eligiendo «relacionar»: parte de las hermanas que trae la entidad y añade la
  // nueva. Con el árbol leyéndolas vacías, ese conjunto era siempre el de la
  // nueva a secas, y la escritura sustituía en vez de sumar.
  test('relacionar por arrastre suma, no sustituye', () async {
    await repository.saveTagSiblings(1, both([2]));

    final dragged = await fromTree(1);
    final ids = {for (final each in dragged.siblings) each.id}..add(3);

    final result = await repository.saveTagSiblings(1, both(ids));
    expect(result, isA<DataSuccess>());

    expect(await storedSiblings(1), {2, 3});
    expect(await storedSiblings(2), {1});
    expect(await storedSiblings(3), {1});
  });
  // Las direcciones marcadas como no aptas: un subconjunto de las de siempre.
  //
  // La decision de fondo es que esconder no es apagar, igual que con los fernies
  // y los modelos: una direccion marcada no se enseña con el bloqueo cerrado,
  // pero sigue etiquetando al importar. Aqui se comprueba lo que se guarda; que
  // siga etiquetando lo sostiene `MediaRegistry`, que lee `sourceUrls` entera y
  // no sabe nada de marcas.
  group('las direcciones marcadas', () {
    test('se guardan como subconjunto de las de siempre', () async {
      await repository.saveTagSourceUrls(
        1,
        ['reddit.com/r/uno', 'reddit.com/r/dos'],
        nsfwUrls: ['reddit.com/r/dos'],
      );

      final tag = (await isar.tagModels.get(1))!;

      expect(tag.sourceUrls, ['reddit.com/r/uno', 'reddit.com/r/dos']);
      expect(tag.nsfwSourceUrls, ['reddit.com/r/dos']);
    });

    // Una marca de una direccion que ya no esta no esconde nada, y volveria a
    // aplicarse sola si alguien escribiera otra vez esa direccion.
    test('una marca sin su direccion no se queda', () async {
      await repository.saveTagSourceUrls(
        1,
        ['reddit.com/r/uno', 'reddit.com/r/dos'],
        nsfwUrls: ['reddit.com/r/dos'],
      );

      await repository.saveTagSourceUrls(
        1,
        ['reddit.com/r/uno'],
        nsfwUrls: ['reddit.com/r/dos'],
      );

      expect((await isar.tagModels.get(1))!.nsfwSourceUrls, isEmpty);
    });

    test('la etiqueta marcada entera las da todas por marcadas', () async {
      const tag = TagEntity(
        id: 1,
        name: 'ladybug',
        children: [],
        sourceUrls: ['reddit.com/r/uno'],
        isNsfw: true,
      );

      expect(tag.marksLink('reddit.com/r/uno'), isTrue);
    });

    test('sin marca ni en la etiqueta ni en ella, no esta marcada', () async {
      const tag = TagEntity(
        id: 1,
        name: 'ladybug',
        children: [],
        sourceUrls: ['reddit.com/r/uno'],
      );

      expect(tag.marksLink('reddit.com/r/uno'), isFalse);
    });

    // Lo que el arbol devuelve es lo que pinta la ficha: sin esto, la marca no
    // se veria y guardar la perderia.
    test('el arbol las trae', () async {
      await repository.saveTagSourceUrls(
        1,
        ['reddit.com/r/uno', 'reddit.com/r/dos'],
        nsfwUrls: ['reddit.com/r/dos'],
      );

      final tag = await fromTree(1);

      expect(tag.marksLink('reddit.com/r/dos'), isTrue);
      expect(tag.marksLink('reddit.com/r/uno'), isFalse);
    });
  });

  // La separacion entre personas y etiquetas: un campo mas, aditivo. Lo que ya
  // hay en la base sigue siendo una etiqueta normal, que es lo correcto:
  // separarlas es cosa del usuario, una a una.
  group('las personas', () {
    test('lo que ya estaba guardado no es una persona', () async {
      expect((await fromTree(1)).isPerson, isFalse);
    });

    test('convertir una etiqueta la marca, y el arbol lo trae', () async {
      final tag = await fromTree(1);

      final result = await repository.updateTag(tag.copyWith(isPerson: true));
      expect(result, isA<DataSuccess>());

      expect((await isar.tagModels.get(1))!.isPerson, isTrue);
      expect((await fromTree(1)).isPerson, isTrue);
    });

    test('y se puede deshacer', () async {
      await repository.updateTag((await fromTree(1)).copyWith(isPerson: true));
      await repository.updateTag((await fromTree(1)).copyWith(isPerson: false));

      expect((await fromTree(1)).isPerson, isFalse);
    });

    // Convertirla no le quita nada de lo suyo: sigue siendo la misma etiqueta,
    // con su contenido, sus direcciones y su sitio en el arbol.
    test('convertir no toca lo demas', () async {
      await repository.saveTagSiblings(1, both([2]));

      final tag = await fromTree(1);
      await repository.updateTag(tag.copyWith(isPerson: true));

      final after = await fromTree(1);

      expect(after.sourceUrls, ['reddit.com/r/miraculous']);
      expect(after.siblings.map((each) => each.name), ['serie']);
      expect(after.name, 'ladybug');
    });

    test('una persona nueva nace marcada', () async {
      final result = await repository.saveTag(
        const TagEntity(
          id: unsavedId,
          name: 'marinette',
          children: [],
          isPerson: true,
        ),
      );

      expect(result, isA<DataSuccess>());
      expect(result.data!.isPerson, isTrue);
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
