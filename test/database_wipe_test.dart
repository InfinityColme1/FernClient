// Vaciar la base de datos entera.
//
// Es lo único de la aplicación que destruye sin poder deshacerse, así que las
// dos cosas que hay que sostener son opuestas: que **no ocurra** mientras la
// frase no esté escrita exactamente, y que cuando ocurra **se lleve todo**, sin
// dejar una biblioteca a medias con etiquetas que ya no señalan a nada.
//
// Y una tercera que no es obvia: las marcas de importación se van con ella. Son
// preferencias, no base de datos, pero dicen «de aquí para atrás ya está
// traído», y con la base vacía eso es mentira: dejarlas puestas haría que la
// siguiente importación «desde la última vez» no trajera nada y pareciera que la
// fuente está rota.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/services/shuffle_seed.dart';
import 'package:Fern/features/duplicates/data/models/duplicate_group_model.dart';
import 'package:Fern/features/media/data/repositories/local_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/nsfw_index.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/model_fernie_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/domain/services/database_wipe_options.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/data/models/blocked_import_model.dart';
import 'package:Fern/features/media/data/services/blocked_imports.dart';
import 'package:Fern/features/media/domain/services/collapsed_tags.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media_tag_log_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/settings/data/services/database_maintenance_service.dart';
import 'package:Fern/features/settings/domain/services/database_wipe_phrase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('la frase de confirmación', () {
    const phrase = 'Eliminar Base de Datos';

    bool confirmed(String typed) =>
        isDatabaseWipeConfirmed(typed: typed, phrase: phrase);

    test('escrita tal cual, vale', () {
      expect(confirmed('Eliminar Base de Datos'), isTrue);
    });

    test('con espacios de más a los lados, también', () {
      // Copiar y pegar arrastra un espacio con una facilidad pasmosa, y eso no
      // es un accidente: es la frase entera escrita.
      expect(confirmed('  Eliminar Base de Datos '), isTrue);
    });

    group('y lo que no vale', () {
      test('otra cosa parecida', () {
        expect(confirmed('eliminar base de datos'), isFalse);
        expect(confirmed('Eliminar Base de Dato'), isFalse);
        expect(confirmed('Eliminar  Base de Datos'), isFalse);
      });

      test('nada', () {
        expect(confirmed(''), isFalse);
        expect(confirmed('   '), isFalse);
      });

      test('ni la frase suelta si no hay frase que pedir', () {
        // Si por lo que sea la frase llegara vacía, cualquier campo vacío la
        // cumpliría y el borrado saldría de no escribir nada.
        expect(isDatabaseWipeConfirmed(typed: '', phrase: ''), isFalse);
        expect(isDatabaseWipeConfirmed(typed: '  ', phrase: '  '), isFalse);
      });
    });
  });

  group('el borrado', () {
    late Directory directory;
    late Isar isar;
    late PreferencesService preferences;
    late BlockedImports blocked;
    late NsfwIndex nsfw;
    late LocalMediaRepositoryImpl media;
    late DatabaseMaintenanceService maintenance;

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
      directory = await Directory.systemTemp.createTemp('fern_wipe_test');

      isar = await Isar.open(
        [
          TagModelSchema,
          PersonaModelSchema,
          CreatorModelSchema,
          MediaSummaryModelSchema,
          MediaModelSchema,
          MediaTagLogModelSchema,
          BlockedImportModelSchema,
          // Los mira el borrado de contenido, que es por donde se va lo marcado
          // como no apto.
          FernieModelSchema,
          FernieRegionModelSchema,
          DuplicateGroupModelSchema,
          // El índice de lo no apto los mira para saber qué modelos y qué
          // fernies quedan escondidos.
          RecognitionModelModelSchema,
          ModelFernieModelSchema,
        ],
        directory: directory.path,
        inspector: false,
      );

      SharedPreferences.setMockInitialValues({});
      preferences =
          PreferencesService(await SharedPreferences.getInstance());

      blocked = BlockedImports(database: isar);
      await blocked.rebuild();

      nsfw = NsfwIndex(
        database: isar,
        hierarchy: TagHierarchy(database: isar),
      );
      await nsfw.rebuild();

      media = LocalMediaRepositoryImpl(
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

      maintenance = DatabaseMaintenanceService(
        database: isar,
        preferences: preferences,
        blocked: blocked,
        collapsedTags: CollapsedTags(preferences: preferences),
        media: media,
        nsfw: nsfw,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
      if (directory.existsSync()) directory.deleteSync(recursive: true);
    });

    /// Deja la base de datos con algo de cada cosa.
    Future<void> fill() async {
      await isar.writeTxn(() async {
        await isar.tagModels.put(TagModel(id: 1, name: 'paisajes'));
        await isar.creatorModels.put(CreatorModel(id: 1, name: 'alguien'));
        await isar.mediaSummaryModels.put(
          MediaSummaryModel()
            ..id = 1
            ..path = 'C:/media/uno.jpg',
        );
        await isar.mediaModels.put(
          MediaModel(id: 1, path: 'C:/media/uno.jpg')
            ..downloaded = DateTime(2026)
            ..isFavorite = false,
        );
      });
    }

    /// Cuántas filas quedan en total.
    Future<int> rows() async =>
        await isar.tagModels.count() +
        await isar.creatorModels.count() +
        await isar.mediaSummaryModels.count() +
        await isar.mediaModels.count();

    test('se lleva todas las colecciones, no sólo los contenidos', () async {
      await fill();
      expect(await rows(), greaterThan(0));

      await maintenance.wipe();

      // A medias quedaría una biblioteca con etiquetas que no señalan a nada y
      // contenidos sin la ficha que los describe, que es peor que las dos
      // cosas.
      expect(await rows(), 0);
    });

    test('y la base sigue sirviendo después', () async {
      await fill();
      await maintenance.wipe();

      // Vaciarla no es cerrarla: se sigue usando la misma, sin reiniciar.
      await isar.writeTxn(
        () => isar.tagModels.put(TagModel(id: 2, name: 'nueva')),
      );

      expect(await isar.tagModels.count(), 1);
    });

    test('olvida por dónde iban las importaciones', () async {
      await preferences.setLastImport(ImportSource.reddit, DateTime(2026, 8));
      await preferences.setLastImportMarker(ImportSource.reddit, 'abc123');

      await maintenance.wipe();

      expect(preferences.getLastImport(ImportSource.reddit), isNull);
      expect(preferences.getLastImportMarker(ImportSource.reddit), isNull);
    });

    group('lo que se dijo que no se volviera a importar', () {
      test('se va con todo lo demás', () async {
        await blocked.block(source: 'reddit', remoteId: 'abc');

        await maintenance.wipe();

        expect(await blocked.all(), isEmpty);
      });

      // El que de verdad importa: durante una importación quien contesta es la
      // memoria, no la base. Sin releerla se seguiría saltando contenido cuyo
      // bloqueo ya no existe en ninguna parte —ni siquiera en la lista desde la
      // que se podría deshacer—, y eso no habría forma de desatascarlo.
      test('y deja de saltarse esas piezas', () async {
        await blocked.block(source: 'reddit', remoteId: 'abc');
        expect(blocked.blocks('reddit', 'abc'), isTrue);

        await maintenance.wipe();

        expect(blocked.blocks('reddit', 'abc'), isFalse);
      });
    });

    test('pero no se lleva por delante el resto de los ajustes', () async {
      await preferences.setRootPath('C:/biblioteca');
      await preferences.setLastImportSource(ImportSource.pixiv);

      await maintenance.wipe();

      // La carpeta de la biblioteca no es la base de datos: sin ella, después
      // de vaciar habría que volver a configurar la aplicación entera.
      expect(preferences.getRootPath(), 'C:/biblioteca');
      expect(preferences.getLastImportSource(), ImportSource.pixiv);
    });
  });

  // Lo que se elige antes de vaciar: cuanto se lleva por delante y si los
  // ficheros se van tambien del disco.
  //
  // Lo primero es lo que hace esto usable: dejar de tener guardado lo que no se
  // quiere tener guardado no deberia costar empezar la biblioteca de cero.
  group('con opciones', () {
    late Directory directory;
    late Isar isar;
    late NsfwIndex nsfw;
    late LocalMediaRepositoryImpl media;
    late DatabaseMaintenanceService maintenance;

    final isarLibrary = _isarLibrary();

    setUpAll(() async {
      if (isarLibrary == null) return;
      await Isar.initializeIsarCore(libraries: {Abi.windowsX64: isarLibrary});
    });

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('fern_wipe_options');

      isar = await Isar.open(
        [
          TagModelSchema,
          PersonaModelSchema,
          CreatorModelSchema,
          MediaSummaryModelSchema,
          MediaModelSchema,
          MediaTagLogModelSchema,
          BlockedImportModelSchema,
          FernieModelSchema,
          FernieRegionModelSchema,
          DuplicateGroupModelSchema,
          RecognitionModelModelSchema,
          ModelFernieModelSchema,
        ],
        directory: directory.path,
        inspector: false,
      );

      SharedPreferences.setMockInitialValues({});
      final preferences = PreferencesService(
        await SharedPreferences.getInstance(),
      );

      final blocked = BlockedImports(database: isar);
      await blocked.rebuild();

      nsfw = NsfwIndex(
        database: isar,
        hierarchy: TagHierarchy(database: isar),
      );
      await nsfw.rebuild();

      media = LocalMediaRepositoryImpl(
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

      maintenance = DatabaseMaintenanceService(
        database: isar,
        preferences: preferences,
        blocked: blocked,
        collapsedTags: CollapsedTags(preferences: preferences),
        media: media,
        nsfw: nsfw,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
      if (directory.existsSync()) directory.deleteSync(recursive: true);
    });

    /// Un contenido, marcado a mano como no apto si se dice.
    Future<void> addMedia(int id, {bool isNsfw = false, int? tagId}) async {
      final path = 'C:/media/$id.jpg';

      final summary = MediaSummaryModel()
        ..id = id
        ..path = path
        ..isNsfw = isNsfw;

      final details = MediaModel(id: id, path: path)
        ..downloaded = DateTime(2026)
        ..isFavorite = false;

      await isar.writeTxn(() async {
        await isar.mediaSummaryModels.put(summary);
        await isar.mediaModels.put(details);

        if (tagId != null) {
          final tag = await isar.tagModels.get(tagId);
          if (tag != null) await details.tags.update(link: [tag]);
        }
      });
    }

    Future<void> addTag(int id, String name, {bool isNsfw = false}) async {
      await isar.writeTxn(() async {
        await isar.tagModels.put(TagModel(id: id, name: name)..isNsfw = isNsfw);
      });
    }

    Future<List<int>> remainingMedia() async {
      final rows = await isar.mediaSummaryModels.where().findAll();

      return [for (final row in rows) row.id]..sort();
    }

    group('solo lo no apto', () {
      test('se lleva lo marcado a mano y deja lo demas', () async {
        await addMedia(1);
        await addMedia(2, isNsfw: true);
        await nsfw.rebuild();

        await maintenance.wipe(
          const DatabaseWipeOptions(scope: DatabaseWipeScope.nsfwOnly),
        );

        expect(await remainingMedia(), [1]);
      });

      // Lo que cuelga de una etiqueta marcada esta igual de escondido: dejarlo
      // fuera vaciaria a medias justo lo que se pidio vaciar.
      test('y tambien lo que hereda de una etiqueta marcada', () async {
        await addTag(1, 'adultos', isNsfw: true);
        await addMedia(1);
        await addMedia(2, tagId: 1);
        await nsfw.rebuild();

        await maintenance.wipe(
          const DatabaseWipeOptions(scope: DatabaseWipeScope.nsfwOnly),
        );

        expect(await remainingMedia(), [1]);
      });

      // Lo que se borra es contenido, no la biblioteca.
      test('las etiquetas y los creadores se quedan', () async {
        await addTag(1, 'adultos', isNsfw: true);
        await isar.writeTxn(
          () => isar.creatorModels.put(CreatorModel(id: 1, name: 'alguien')),
        );
        await addMedia(1, isNsfw: true);
        await nsfw.rebuild();

        await maintenance.wipe(
          const DatabaseWipeOptions(scope: DatabaseWipeScope.nsfwOnly),
        );

        expect(await isar.tagModels.count(), 1);
        expect(await isar.creatorModels.count(), 1);
      });

      test('sin nada marcado no borra nada', () async {
        await addMedia(1);
        await nsfw.rebuild();

        final paths = await maintenance.wipe(
          const DatabaseWipeOptions(scope: DatabaseWipeScope.nsfwOnly),
        );

        expect(paths, isEmpty);
        expect(await remainingMedia(), [1]);
      });

      // El indice se relee: sin eso seguiria diciendo que hay contenido
      // bloqueado que ya no existe.
      test('y el indice se queda al dia', () async {
        await addMedia(1, isNsfw: true);
        await nsfw.rebuild();

        await maintenance.wipe(
          const DatabaseWipeOptions(scope: DatabaseWipeScope.nsfwOnly),
        );

        expect(nsfw.media, isEmpty);
      });
    });

    group('los ficheros', () {
      // No se borran aqui: se devuelven para que quien lo pidio los mande a la
      // cola. Miles de ficheros son minutos, y hacerlo aqui dejaria la ventana
      // bloqueada sin poder decir por donde va.
      test('se devuelven para borrarlos fuera', () async {
        await addMedia(1);
        await addMedia(2);

        final paths = await maintenance.wipe(
          const DatabaseWipeOptions(deletesFiles: true),
        );

        expect(paths, hasLength(2));
        expect(paths, contains('C:/media/1.jpg'));
      });

      // Sin pedirlo, los ficheros se quedan donde estan: es lo que hace que
      // vaciar la base sea reversible con un escaneo.
      test('sin pedirlo no se devuelve ninguno', () async {
        await addMedia(1);

        expect(await maintenance.wipe(), isEmpty);
      });

      test('los de lo no apto salen solo de lo que se borra', () async {
        await addMedia(1);
        await addMedia(2, isNsfw: true);
        await nsfw.rebuild();

        final paths = await maintenance.wipe(
          const DatabaseWipeOptions(
            scope: DatabaseWipeScope.nsfwOnly,
            deletesFiles: true,
          ),
        );

        expect(paths, ['C:/media/2.jpg']);
      });

      // Las rutas salen de las filas, asi que hay que leerlas antes de
      // vaciarlas: despues no habria de donde.
      test('las de todo se leen antes de vaciar', () async {
        await addMedia(1);

        final paths = await maintenance.wipe(
          const DatabaseWipeOptions(deletesFiles: true),
        );

        expect(paths, ['C:/media/1.jpg']);
        expect(await remainingMedia(), isEmpty);
      });
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


/// Ni ficheros ni avatares: vaciar la base no los toca, y las rutas que hay que
/// borrar se devuelven para que las mande a la cola quien lo pidio.
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

