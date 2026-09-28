// El alta de contenido, y a quién avisa.
//
// `MediaRegistry.register()` es el único sitio por el que pasan todos los
// contenidos: el escaneo del equipo, las plataformas remotas y el navegador
// acaban los tres ahí. Por eso es donde se engancha lo que tenga que ocurrirles
// a todos —hoy, mandarlos a reconocer— y por eso el aviso tiene que ser exacto:
// uno por contenido nuevo, ninguno por lo que ya se conocía.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media_tag_log_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory directory;
  late Isar isar;
  late List<int> announced;
  late MediaRegistry registry;

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
    directory = await Directory.systemTemp.createTemp('fern_registry_test');

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

    announced = [];
    registry = MediaRegistry(
      database: isar,
      tagHierarchy: TagHierarchy(database: isar),
      onRegistered: announced.add,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  Future<void> register(String path) => registry.register(
        path: path,
        source: ImportSource.local,
      );

  group('el aviso', () {
    test('un contenido nuevo avisa una vez, con su identificador', () async {
      await register('C:/media/uno.jpg');

      expect(announced, [registry.idOf('C:/media/uno.jpg')]);
    });

    test('cada contenido avisa por su cuenta', () async {
      await register('C:/media/uno.jpg');
      await register('C:/media/dos.jpg');

      expect(announced.length, 2);
      expect(announced.toSet().length, 2);
    });

    test('lo que ya se conocía no avisa', () async {
      await register('C:/media/uno.jpg');
      announced.clear();

      await register('C:/media/uno.jpg');

      // Volver a escanear la misma carpeta es lo normal, y avisar otra vez
      // mandaría a reconocer lo que ya se reconoció.
      expect(announced, isEmpty);
    });

    test('avisa con el contenido ya guardado', () async {
      final seen = <int, bool>{};

      final registry = MediaRegistry(
        database: isar,
        tagHierarchy: TagHierarchy(database: isar),
        // Quien escuche va a querer leerlo: avisar antes de guardar le daría un
        // identificador que todavía no existe en la base.
        onRegistered: (id) =>
            seen[id] = isar.mediaSummaryModels.getSync(id) != null,
      );

      await registry.register(
        path: 'C:/media/tres.jpg',
        source: ImportSource.local,
      );

      expect(seen.values, [true]);
    });
  });

  group('sin nadie escuchando', () {
    test('el alta funciona igual', () async {
      final registry = MediaRegistry(
        database: isar,
        tagHierarchy: TagHierarchy(database: isar),
      );

      final summary = await registry.register(
        path: 'C:/media/cuatro.jpg',
        source: ImportSource.local,
      );

      expect(summary, isNotNull);
      expect(summary!.isImported, isFalse);
    });
  });

  // Vincular a un creador el enlace de su perfil de Pixiv y que el contenido que
  // llega de ahi salga con el puesto. Es lo que fallaba: FeRN pone en el
  // contenido `pixiv.net/users/123`, y el enlace que da el navegador trae el
  // idioma delante o la pestaña detras, asi que no casaba con nada y todo
  // entraba con el creador desconocido.
  group('lo que se pone solo por la direccion', () {
    /// Un creador con [url] vinculada, tal cual la escribiria el usuario.
    Future<CreatorModel> addCreator(String name, String url) async {
      final creator = CreatorModel(id: 0, name: name)..sourceUrls = [url];

      await isar.writeTxn(() async {
        creator.id = await isar.creatorModels.put(creator);
      });

      return creator;
    }

    Future<TagModel> addTag(String name, String url) async {
      final tag = TagModel(id: 0, name: name)..sourceUrls = [url];

      await isar.writeTxn(() async {
        tag.id = await isar.tagModels.put(tag);
      });

      return tag;
    }

    /// Lo que FeRN pone como direcciones de una obra de Pixiv.
    List<String> pixivWork(String authorId, String workId) => [
          'https://www.pixiv.net/users/$authorId',
          'https://www.pixiv.net/artworks/$workId',
        ];

    Future<String?> creatorOf(String path) async {
      final media = await isar.mediaModels
          .filter()
          .pathEqualTo(path)
          .findFirst();
      await media?.creator.load();

      return media?.creator.value?.name;
    }

    Future<List<String>> tagsOf(String path) async {
      final media = await isar.mediaModels
          .filter()
          .pathEqualTo(path)
          .findFirst();
      await media?.tags.load();

      return [for (final tag in media?.tags ?? const <TagModel>[]) tag.name]
        ..sort();
    }

    test('el perfil tal cual asigna el creador', () async {
      await addCreator('Alguien', 'https://www.pixiv.net/users/123');

      await registry.register(
        path: 'C:/media/uno.jpg',
        source: ImportSource.pixiv,
        sourceUrls: pixivWork('123', '987'),
      );

      expect(await creatorOf('C:/media/uno.jpg'), 'Alguien');
    });

    // Lo que copia el navegador con la interfaz en ingles.
    test('y con el idioma delante tambien', () async {
      await addCreator('Alguien', 'https://www.pixiv.net/en/users/123');

      await registry.register(
        path: 'C:/media/dos.jpg',
        source: ImportSource.pixiv,
        sourceUrls: pixivWork('123', '987'),
      );

      expect(await creatorOf('C:/media/dos.jpg'), 'Alguien');
    });

    // Y lo que copia al estar mirando su galeria.
    test('y con la pestaña detras', () async {
      await addCreator('Alguien', 'https://www.pixiv.net/users/123/artworks');

      await registry.register(
        path: 'C:/media/tres.jpg',
        source: ImportSource.pixiv,
        sourceUrls: pixivWork('123', '987'),
      );

      expect(await creatorOf('C:/media/tres.jpg'), 'Alguien');
    });

    test('otro artista no se lleva nada', () async {
      await addCreator('Alguien', 'https://www.pixiv.net/en/users/123');

      await registry.register(
        path: 'C:/media/cuatro.jpg',
        source: ImportSource.pixiv,
        sourceUrls: pixivWork('999', '987'),
      );

      expect(await creatorOf('C:/media/cuatro.jpg'), isNot('Alguien'));
    });

    // Las etiquetas van por el mismo camino, asi que tenian el mismo problema.
    test('las etiquetas se ponen igual', () async {
      await addTag('Ese artista', 'https://www.pixiv.net/en/users/123');

      await registry.register(
        path: 'C:/media/cinco.jpg',
        source: ImportSource.pixiv,
        sourceUrls: pixivWork('123', '987'),
      );

      expect(await tagsOf('C:/media/cinco.jpg'), ['Ese artista']);
    });

    // Una regla de Reddit no puede empezar a recoger cosas que no son suyas.
    test('y una comunidad sigue recogiendo lo suyo y nada mas', () async {
      await addTag('Gifs', 'https://www.reddit.com/r/gifs');

      await registry.register(
        path: 'C:/media/seis.jpg',
        source: ImportSource.reddit,
        sourceUrls: const [
          'https://www.reddit.com/r/gifs/comments/abc/un_titulo/',
        ],
      );

      await registry.register(
        path: 'C:/media/siete.jpg',
        source: ImportSource.reddit,
        sourceUrls: const ['https://www.reddit.com/r/otracosa/comments/x/y/'],
      );

      expect(await tagsOf('C:/media/seis.jpg'), ['Gifs']);
      expect(await tagsOf('C:/media/siete.jpg'), isEmpty);
    });
  });

  // La misma pregunta que contesta `register` al devolver `null` —«esto ya
  // estaba»—, pero hecha con la clave que se conoce **antes de descargar**. Es
  // lo que evita bajarse entera una cuenta que ya está importada para acabar
  // tirándolo todo.
  group('lo que ya está dado de alta', () {
    test('sale por su identificador en la fuente', () async {
      await registry.register(
        path: 'C:/descargas/reddit/abc.jpg',
        source: ImportSource.reddit,
        remoteId: 'abc',
      );

      expect(await registry.registeredIdsOf(ImportSource.reddit), {'abc'});
    });

    test('cada fuente responde por lo suyo', () async {
      await registry.register(
        path: 'C:/descargas/reddit/abc.jpg',
        source: ImportSource.reddit,
        remoteId: 'abc',
      );

      expect(await registry.registeredIdsOf(ImportSource.pixiv), isEmpty);
    });

    // Lo que entró antes de que el identificador se guardara no lo lleva. En lo
    // remoto el nombre del fichero **es** el identificador, así que se recupera
    // de la ruta: sin esto, una biblioteca anterior al cambio se volvería a
    // descargar de arriba abajo.
    test('lo que no lo guardó se recupera del nombre del fichero', () async {
      await registry.register(
        path: 'C:/descargas/pixiv/999_111_p0.png',
        source: ImportSource.pixiv,
      );

      expect(
        await registry.registeredIdsOf(ImportSource.pixiv),
        {'999_111_p0'},
      );
    });

    // El que la biblioteca renombró al colocarlo junto a otro con el mismo
    // nombre. Sin quitarle el sufijo, ese contenido concreto se volvería a bajar
    // en cada importación.
    test('y al recuperarlo se le quita el desempate de la biblioteca', () async {
      await registry.register(
        path: 'C:/biblioteca/Arte/999_111_p0 (2).png',
        source: ImportSource.pixiv,
      );

      expect(
        await registry.registeredIdsOf(ImportSource.pixiv),
        {'999_111_p0'},
      );
    });

    // Mientras su fila esté, ese contenido se conoce: volver a bajarlo no
    // aporta nada, ni cuando está esperando revisión ni cuando está en la
    // papelera.
    test('también lo que sigue pendiente de revisar', () async {
      await registry.register(
        path: 'C:/descargas/danbooru/555.jpg',
        source: ImportSource.danbooru,
        remoteId: '555',
      );

      final summary = await isar.mediaSummaryModels
          .filter()
          .pathEqualTo('C:/descargas/danbooru/555.jpg')
          .findFirst();
      expect(summary!.isImported, isFalse);

      expect(await registry.registeredIdsOf(ImportSource.danbooru), {'555'});
    });
  });

  // Lo que hay que hacer con el fichero que `register` rechaza por conocido: sin
  // su fila no lo nombra nadie y en la carpeta de descargas sólo ocupa. Con una
  // excepción que importa más que la limpieza.
  group('el fichero que no da de alta nada', () {
    test('se tira si no lo nombra ninguna fila', () async {
      final file = File(p.join(directory.path, 'sobra.jpg'));
      await file.writeAsString('contenido');

      await registry.discardUnusedFile(file.path);

      expect(await file.exists(), isFalse);
    });

    // Un contenido pendiente de revisar vive en la carpeta de descargas hasta
    // que se da por definitivo, y también se rechaza por conocido: borrar su
    // fichero sería borrar contenido de la biblioteca.
    test('pero no el del contenido que sigue esperando revisión', () async {
      final file = File(p.join(directory.path, 'pendiente.jpg'));
      await file.writeAsString('contenido');

      await registry.register(path: file.path, source: ImportSource.pixiv);

      await registry.discardUnusedFile(file.path);

      expect(await file.exists(), isTrue);
    });

    // El mismo fichero bajado otra vez cuando el contenido ya se movió a la
    // biblioteca: la fila existe, pero apunta a otro sitio.
    test('y sí la copia de lo que ya se colocó en la biblioteca', () async {
      final file = File(p.join(directory.path, 'movido.jpg'));
      await file.writeAsString('contenido');

      await registry.register(path: file.path, source: ImportSource.pixiv);

      await isar.writeTxn(() async {
        final row = await isar.mediaSummaryModels
            .filter()
            .pathEqualTo(file.path)
            .findFirst();
        row!.path = 'C:/biblioteca/movido.jpg';
        await isar.mediaSummaryModels.put(row);
      });

      await registry.discardUnusedFile(file.path);

      expect(await file.exists(), isFalse);
    });
  });
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
