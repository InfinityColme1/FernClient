// En qué orden sale la biblioteca.
//
// Hasta ahora salía en el orden de los identificadores, y como el identificador
// es el hash de la ruta, ese orden no significaba nada: ni cuándo llegó, ni
// cómo se llama, ni de qué tipo es. Parecía aleatorio sin la ventaja de serlo,
// porque era siempre el mismo.
//
// Contra base de datos de verdad porque dos de los órdenes se resuelven en la
// consulta —cuándo llegó y qué dice la descripción viven en los detalles, no en
// el sumario— y lo que hay que comprobar es justo que esos dos casen.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/resources/data_state.dart';
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
import 'package:Fern/features/media/domain/entities/media_sort_order.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:Fern/core/services/shuffle_seed.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late LocalMediaRepositoryImpl repository;
  late ShuffleSeed shuffle;

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
    directory = await Directory.systemTemp.createTemp('fern_sort_test');
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

    shuffle = ShuffleSeed();

    repository = LocalMediaRepositoryImpl(
      shuffle: shuffle,
      appDatabase: isar,
      fileOrganizer: MediaFileOrganizer(settingsRepository: settings),
      avatarStorage: AvatarStorageService(settingsRepository: settings),
      registry: MediaRegistry(database: isar, tagHierarchy: hierarchy),
      tagHierarchy: hierarchy,
    );

    await _seed(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  Future<List<int>> idsIn(MediaSortOrder order) async {
    final result = await repository.getMediaList(order: order);

    return [for (final one in (result as DataSuccess).data!) one.id as int];
  }

  group('por cuándo llegó', () {
    test('lo último primero', () async {
      expect(await idsIn(MediaSortOrder.newestFirst), [4, 3, 2, 1]);
    });

    test('y al revés', () async {
      expect(await idsIn(MediaSortOrder.oldestFirst), [1, 2, 3, 4]);
    });

    test('es el de fábrica', () async {
      final result = await repository.getMediaList();

      expect(
        [for (final one in (result as DataSuccess).data!) one.id],
        [4, 3, 2, 1],
      );
    });
  });

  test('por nombre de fichero, sin mirar la carpeta', () async {
    // Con la biblioteca organizada por la aplicación todas las rutas empiezan
    // igual: ordenar por la ruta entera sería ordenar por subcarpeta.
    expect(await idsIn(MediaSortOrder.fileName), [3, 2, 4, 1]);
  });

  group('por descripción', () {
    test('las que la tienen, por ella', () async {
      final ids = await idsIn(MediaSortOrder.description);

      expect(ids.take(2), [2, 1]);
    });

    // Un bloque de contenido sin describir abriendo la rejilla es lo mismo que
    // no haber ordenado nada.
    test('y lo que no la tiene, al final', () async {
      final ids = await idsIn(MediaSortOrder.description);

      expect(ids.skip(2).toSet(), {3, 4});
    });
  });

  test('por tipo: imágenes, GIF y vídeos', () async {
    final ids = await idsIn(MediaSortOrder.kind);

    expect(ids, [1, 2, 3, 4]);
  });

  group('al azar', () {
    test('no pierde ni repite nada', () async {
      expect((await idsIn(MediaSortOrder.random)).toSet(), {1, 2, 3, 4});
    });

    // Si cambiara en cada consulta, la rejilla se recolocaría al desplazarse y
    // al volver del visor: se vería contenido dos veces y contenido ninguna.
    test('sale igual mientras nadie vuelva a barajar', () async {
      expect(
        await idsIn(MediaSortOrder.random),
        await idsIn(MediaSortOrder.random),
      );
    });

    // Y la otra mitad: con una semilla fija para siempre, «al azar» saldría una
    // vez y a partir de ahí sería un orden fijo más. Quien pulsa el botón espera
    // otro orden, y baraja de nuevo.
    test('y cambia en cuanto se vuelve a barajar', () async {
      final antes = await idsIn(MediaSortOrder.random);

      // Con cuatro contenidos, una baraja puede caer igual por casualidad: se
      // insiste unas cuantas veces antes de darlo por roto.
      var haCambiado = false;
      for (var i = 0; i < 20 && !haCambiado; i++) {
        shuffle.renew();
        haCambiado = !const ListEquality<int>()
            .equals(antes, await idsIn(MediaSortOrder.random));
      }

      expect(haCambiado, isTrue);
    });
  });

  test('el orden no cambia lo que se enseña', () async {
    // Lo que está en la papelera o pendiente de revisar sigue fuera, ordene
    // como ordene.
    for (final order in MediaSortOrder.values) {
      expect((await idsIn(order)).toSet(), {1, 2, 3, 4}, reason: order.id);
    }
  });
}

/// Cuatro contenidos: uno de cada tipo, con fechas, nombres y descripciones que
/// dan un orden distinto en cada criterio.
///
/// Distinto a propósito: si dos criterios dieran el mismo orden, media prueba
/// pasaría sin comprobar nada.
Future<void> _seed(Isar isar) async {
  Future<void> add(
    int id, {
    required String path,
    required DateTime downloaded,
    String? description,
    bool isImported = true,
    bool isDeleted = false,
  }) async {
    final details = MediaModel(id: id, path: path)
      ..downloaded = downloaded
      ..isFavorite = false
      ..description = description;

    await isar.writeTxn(() async {
      await isar.mediaModels.put(details);
      await isar.mediaSummaryModels.put(
        MediaSummaryModel()
          ..id = id
          ..path = path
          ..isImported = isImported
          ..isDeleted = isDeleted,
      );
    });
  }

  await add(1, path: 'C:/media/z.jpg', downloaded: DateTime(2026, 1, 1), description: 'beta');
  await add(2, path: 'C:/media/b.gif', downloaded: DateTime(2026, 2, 1), description: 'alfa');
  await add(3, path: 'C:/media/a.mp4', downloaded: DateTime(2026, 3, 1));
  await add(4, path: 'C:/otra/c.mp4', downloaded: DateTime(2026, 4, 1));

  // Y dos que no se enseñan nunca, para que ordenar no los cuele.
  await add(5, path: 'C:/media/pendiente.jpg',
      downloaded: DateTime(2026, 5, 1), isImported: false);
  await add(6, path: 'C:/media/borrada.jpg',
      downloaded: DateTime(2026, 6, 1), isDeleted: true);
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
