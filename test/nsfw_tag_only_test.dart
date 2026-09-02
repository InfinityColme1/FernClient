// La marca que se queda en la etiqueta.
//
// Hasta ahora, una sola etiqueta marcada escondia el contenido entero. Eso esta
// bien cuando lo delicado es el contenido, y de mas cuando lo delicado es solo
// lo que la etiqueta **dice** de el: una imagen normal etiquetada con algo que
// no se quiere leer por encima del hombro.
//
// Con el ajuste apagado, el contenido se queda en la rejilla con sus otras
// etiquetas y de la marcada no queda ni el nombre. Lo que hay que sostener:
//
// - **El contenido se ve, la etiqueta no.** Las dos mitades: una sin la otra es
//   o no haber hecho nada, o lo de siempre.
// - **Guardar desde el panel no la borra.** Al panel llega una lista sin ella y
//   se escribe la lista tal cual: es el fallo que borraba las direcciones de una
//   etiqueta al guardarle el nombre, y aqui borraria la etiqueta.
// - **El registro tampoco la cuenta.** Una linea que diga "se puso Nami" dice el
//   nombre igual de bien que la pildora.
// - **Lo demas no cambia**: lo marcado a mano y lo de un creador marcado se
//   siguen escondiendo, porque ahi lo delicado no es el nombre.

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
import 'package:Fern/features/media/data/services/nsfw_index.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/nsfw/data/services/password_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/recognition/data/models/model_fernie_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

/// El contenido normal con una etiqueta marcada y otra que no.
const taggedId = 1;

/// El que alguien marco el mismo.
const byHandId = 2;

/// El de un creador marcado.
const ofCreatorId = 3;

const commonTagId = 1;
const markedTagId = 2;
const markedCreatorId = 9;

/// Uno sin marcar, que es el que puede traer una etiqueta marcada consigo: uno
/// marcado no se devuelve, asi que no llega a poder enseñar nada.
const plainCreatorId = 8;

void main() {
  late Directory directory;
  late Isar isar;
  late LocalMediaRepositoryImpl repository;
  late NsfwIndex index;
  late NsfwModeService mode;

  /// El ajuste que se prueba: si una etiqueta marcada esconde su contenido.
  late bool hidesTaggedMedia;

  /// Cuantas veces el indice ha avisado de que se ha rehecho.
  late int rebuilds;

  final isarLibrary = _isarLibrary();

  setUpAll(() async {
    if (isarLibrary == null) {
      throw StateError(
        'No se encuentra isar.dll. Se coge de la compilacion de la aplicacion '
        '(flutter build windows --debug) o del paquete isar_flutter_libs.',
      );
    }

    await Isar.initializeIsarCore(libraries: {Abi.windowsX64: isarLibrary});
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fern_tag_only');
    final avatars = await Directory(p.join(directory.path, 'avatars')).create();

    isar = await Isar.open(
      [
        TagModelSchema,
        PersonaModelSchema,
        CreatorModelSchema,
        MediaSummaryModelSchema,
        MediaModelSchema,
        MediaTagLogModelSchema,
        FernieModelSchema,
        FernieRegionModelSchema,
        RecognitionModelModelSchema,
        ModelFernieModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    final settings = _Settings(avatarsPath: avatars.path);
    final hierarchy = TagHierarchy(database: isar);

    hidesTaggedMedia = false;
    rebuilds = 0;

    index = NsfwIndex(
      database: isar,
      hierarchy: hierarchy,
      hidesTaggedMedia: () => hidesTaggedMedia,
      onRebuilt: () => rebuilds++,
    );

    // Pocas vueltas al derivar: aqui no se prueba lo que cuesta una contrasena.
    mode = NsfwModeService(
      storage: _MemoryStorage(),
      passwords: PasswordService(iterations: 64),
    );

    repository = LocalMediaRepositoryImpl(
      shuffle: ShuffleSeed(),
      appDatabase: isar,
      fileOrganizer: MediaFileOrganizer(settingsRepository: settings),
      avatarStorage: AvatarStorageService(settingsRepository: settings),
      registry: MediaRegistry(database: isar, tagHierarchy: hierarchy),
      tagHierarchy: hierarchy,
      visibility: NsfwVisibility(index: index, mode: mode),
      onNsfwChanged: index.rebuild,
    );

    await _seed(isar);
    await index.rebuild();

    // Con contrasena puesta y el bloqueo cerrado, que es la unica situacion en
    // la que esto esconde algo: sin contrasena no se esconde nada a proposito.
    await mode.configure(password: 'la buena');
    mode.lock();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  Future<List<int>> listed() async {
    final result = await repository.getMediaList();

    return [for (final one in (result as DataSuccess).data!) one.id];
  }

  Future<MediaEntity> details(int id) async {
    final result = await repository.getMediaDetails(id);

    return (result as DataSuccess<MediaEntity>).data!;
  }

  group('con el ajuste apagado', () {
    test('el contenido de una etiqueta marcada se sigue viendo', () async {
      expect(await listed(), contains(taggedId));
    });

    test('pero de la etiqueta no queda ni el nombre', () async {
      final tags = (await details(taggedId)).tags!;

      expect([for (final tag in tags) tag.id], [commonTagId]);
    });

    // Las dos mitades tienen que ir juntas: ensenar el contenido con la
    // etiqueta puesta es no haber escondido nada.
    test('y las demas etiquetas siguen ahi', () async {
      final tags = (await details(taggedId)).tags!;

      expect(tags.single.name, 'paisajes');
    });

    // Al panel le llega la lista sin la marcada y el escribe la lista entera:
    // sin la guarda, guardar el contenido la borraba de la base.
    test('guardar desde el panel no la borra', () async {
      final shown = await details(taggedId);

      await repository.saveMedia(shown);

      final stored = await isar.mediaModels.get(taggedId);
      await stored!.tags.load();

      expect(
        [for (final tag in stored.tags) tag.id]..sort(),
        [commonTagId, markedTagId],
      );
    });

    // El registro dice el nombre de lo que se puso, asi que ensenar su linea
    // cuenta lo que la marca tapaba.
    test('el registro tampoco la nombra', () async {
      final result = await repository.getMediaTagLog(taggedId);
      final entries = (result as DataSuccess).data!.entries;

      expect(
        entries.every((entry) => entry.tagId != markedTagId),
        isTrue,
        reason: 'la marcada no puede salir en el registro',
      );
    });

    // La rejilla de la etiqueta es la puerta de atras: el contenido se puede
    // ensenar, pero pedirlo *por esa etiqueta* es pedirle a la marca que
    // conteste, y la marca esta puesta.
    test('y su rejilla no contesta por ella', () async {
      final result = await repository.getMediaByTag(markedTagId);

      expect((result as DataSuccess).data, isEmpty);
    });

    test('lo marcado a mano se sigue escondiendo', () async {
      expect(await listed(), isNot(contains(byHandId)));
    });

    // Un creador marcado esconde lo suyo igual: ahi lo delicado no es el
    // nombre, es la galeria entera.
    test('y lo de un creador marcado tambien', () async {
      expect(await listed(), isNot(contains(ofCreatorId)));
    });

    // Con el bloqueo abierto no se esconde nada, ni el contenido ni el nombre.
    test('con el bloqueo abierto la etiqueta vuelve', () async {
      await mode.unlock('la buena');

      final tags = (await details(taggedId)).tags!;

      expect(
        [for (final tag in tags) tag.id]..sort(),
        [commonTagId, markedTagId],
      );
    });
  });

  // Un creador puede traer etiquetas consigo, y una de ellas puede estar
  // marcada: su nombre sale en la ficha del creador y en el dialogo que lo
  // asigna, que es por donde se escapan estas cosas.
  group('las etiquetas de un creador', () {
    setUp(() async {
      await isar.writeTxn(() async {
        final creator = await isar.creatorModels.get(plainCreatorId);
        final tags = await isar.tagModels.getAll([commonTagId, markedTagId]);

        await creator!.tags.update(link: tags.nonNulls.toList());
      });
    });

    test('de la marcada no queda ni el nombre', () async {
      final result = await repository.getCreator(plainCreatorId);
      final creator = (result as DataSuccess).data!;

      expect([for (final tag in creator.tags) tag.id], [commonTagId]);
    });

    // Al dialogo le llega la lista sin la marcada y el escribe la lista entera:
    // sin la guarda, guardarla la borraba de la base.
    test('y guardarlas no la borra', () async {
      await repository.saveCreatorTags(plainCreatorId, [commonTagId]);

      final creator = await isar.creatorModels.get(plainCreatorId);
      await creator!.tags.load();

      expect(
        [for (final tag in creator.tags) tag.id]..sort(),
        [commonTagId, markedTagId],
      );
    });
  });

  // Marcar algo esconde contenido **sin tocar una sola fila de contenido**, asi
  // que quien guarde una biblioteca ya leida no puede enterarse por la base: se
  // avisa desde aqui. Sin el aviso, volver a la biblioteca despues de marcar
  // devolvia la guardada, con lo que se acababa de esconder todavia dentro.
  test('rehacer el indice se cuenta', () async {
    final before = rebuilds;

    await index.rebuild();

    expect(rebuilds, greaterThan(before));
  });

  group('con el ajuste encendido, lo de siempre', () {
    setUp(() async {
      hidesTaggedMedia = true;
      await index.rebuild();
    });

    test('la etiqueta marcada esconde su contenido entero', () async {
      expect(await listed(), isNot(contains(taggedId)));
    });

    test('y abrirlo por identificador tampoco lo devuelve', () async {
      expect(await repository.getMediaDetails(taggedId), isA<DataException>());
    });
  });
}

Future<void> _seed(Isar isar) async {
  final common = TagModel(id: commonTagId, name: 'paisajes');
  final marked = TagModel(id: markedTagId, name: 'prohibida')..isNsfw = true;

  final creator = CreatorModel(id: markedCreatorId, name: 'escondido')
    ..isNsfw = true;

  final plain = CreatorModel(id: plainCreatorId, name: 'a la vista');

  await isar.writeTxn(() async {
    await isar.tagModels.putAll([common, marked]);
    await isar.creatorModels.putAll([creator, plain]);

    for (final (id, isNsfw) in [
      (taggedId, false),
      (byHandId, true),
      (ofCreatorId, false),
    ]) {
      final summary = MediaSummaryModel()
        ..id = id
        ..path = 'C:/media/$id.jpg'
        ..isImported = true
        ..isNsfw = isNsfw;

      final details = MediaModel(id: id, path: 'C:/media/$id.jpg')
        ..downloaded = DateTime(2026, 1, id)
        ..isFavorite = false;

      await isar.mediaSummaryModels.put(summary);
      await isar.mediaModels.put(details);

      summary.details.value = details;
      await summary.details.save();

      if (id == taggedId) await details.tags.update(link: [common, marked]);

      if (id == ofCreatorId) {
        details.creator.value = creator;
        await details.creator.save();
      }
    }
  });
}

class _MemoryStorage implements NsfwStorage {
  final Map<String, String> values = {};

  @override
  String? read(String key) => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
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

/// La primera `isar.dll` que haya a mano: la de la aplicacion compilada o, si
/// todavia no se ha compilado, la que trae el paquete.
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
