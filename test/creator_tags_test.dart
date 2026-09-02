// Las etiquetas que trae un creador.
//
// Es la otra mitad de las direcciones vinculadas, dicha desde el creador:
// aquellas dicen de donde sale lo suyo, estas que lleva puesto lo suyo. Un
// artista que solo dibuja una serie llevaba su etiqueta puesta a mano una por
// una, sabiendo de antemano cual iba a ser.
//
// Lo que hay que sostener:
//
// - **Entran por donde sea que se ponga el creador.** A mano, en tanda o al
//   importar: si cada camino decidiera por su cuenta, el mismo creador daria
//   resultados distintos segun por donde se le pusiera. Es el fallo que ya tuvo
//   una vez el etiquetado por hermanas.
// - **Con lo que ellas arrastran**, igual que al ponerlas a mano.
// - **No reescriben lo que ya hay.** Relacionar una etiqueta con un creador de
//   cuatrocientos contenidos no puede etiquetar cuatrocientos contenidos.
// - **El desconocido no trae nada**: es el de reserva con el que nace lo que
//   llega sin saber de quien es, y etiquetar por el seria etiquetar por no
//   saber.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
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
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_log_entry_entity.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

import 'support/settings_stub.dart';

/// "Uukkaa", el que trae etiquetas.
const creatorId = 1;

/// El desconocido, que no trae ninguna.
const unknownId = 2;

/// "One Piece", colgando de "manga".
const seriesTagId = 1;
const parentTagId = 2;

/// Una etiqueta cualquiera que ya tiene el contenido.
const otherTagId = 3;

void main() {
  late Directory directory;
  late Isar isar;
  late LocalMediaRepositoryImpl repository;
  late MediaRegistry registry;

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
    directory = await Directory.systemTemp.createTemp('fern_creator_tags');
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

    final settings = SettingsStub(avatarsPath: avatars.path);
    final hierarchy = TagHierarchy(database: isar);

    registry = MediaRegistry(database: isar, tagHierarchy: hierarchy);

    repository = LocalMediaRepositoryImpl(
      shuffle: ShuffleSeed(),
      appDatabase: isar,
      fileOrganizer: MediaFileOrganizer(settingsRepository: settings),
      avatarStorage: AvatarStorageService(settingsRepository: settings),
      registry: registry,
      tagHierarchy: hierarchy,
    );

    await _seed(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  /// Las etiquetas que tiene puestas el contenido [id], por identificador.
  Future<List<int>> tagsOf(int id) async {
    final media = await isar.mediaModels.get(id);
    await media!.tags.load();

    return [for (final tag in media.tags) tag.id]..sort();
  }

  Future<void> relate(List<int> tagIds) async {
    await repository.saveCreatorTags(creatorId, tagIds);
  }

  group('las etiquetas del creador', () {
    test('se guardan y vuelven con el', () async {
      await relate([seriesTagId]);

      final result = await repository.getCreator(creatorId);
      final creator = (result as DataSuccess<CreatorEntity?>).data!;

      expect([for (final tag in creator.tags) tag.id], [seriesTagId]);
    });

    // `reset`, no sumar: sin el no habria forma de quitarle una.
    test('guardarlas de nuevo sustituye a las de antes', () async {
      await relate([seriesTagId]);
      await relate([otherTagId]);

      final result = await repository.getCreator(creatorId);
      final creator = (result as DataSuccess<CreatorEntity?>).data!;

      expect([for (final tag in creator.tags) tag.id], [otherTagId]);
    });

    // Un cambio aqui vale para lo siguiente. Etiquetar de golpe lo que ya
    // estaba puesto seria reescribir la biblioteca por un ajuste.
    test('relacionarlas no reetiqueta lo que ya hay', () async {
      await relate([seriesTagId]);

      expect(await tagsOf(10), [otherTagId]);
    });
  });

  group('al ponerle el creador a un contenido', () {
    test('entran sus etiquetas', () async {
      await relate([seriesTagId]);

      await repository.setMediaCreator(10, creatorId);

      // Con la madre de la serie, que viene con ella; y sin perder la que el
      // contenido ya llevaba.
      expect(await tagsOf(10), [seriesTagId, parentTagId, otherTagId]);
    });

    // Con lo que ellas arrastran, como al ponerlas a mano: si no, la misma
    // etiqueta daria dos resultados segun por donde entrara.
    test('y con lo que ellas arrastran', () async {
      await relate([seriesTagId]);

      await repository.setMediaCreator(11, creatorId);

      expect(await tagsOf(11), [seriesTagId, parentTagId]);
    });

    test('lo que ya tenia se queda', () async {
      await relate([seriesTagId]);

      await repository.setMediaCreator(10, creatorId);

      expect(await tagsOf(10), contains(otherTagId));
    });

    // El de reserva con el que nace lo que llega sin saber de quien es.
    test('el desconocido no trae nada', () async {
      await isar.writeTxn(() async {
        final unknown = await isar.creatorModels.get(unknownId);
        final tag = await isar.tagModels.get(seriesTagId);
        await unknown!.tags.update(link: [tag!]);
      });

      await repository.setMediaCreator(11, unknownId);

      expect(await tagsOf(11), isEmpty);
    });

    // La linea dice de donde salio la etiqueta, que es todo el motivo de que el
    // registro exista.
    test('el registro dice que las trajo el creador', () async {
      await relate([seriesTagId]);

      await repository.setMediaCreator(11, creatorId);

      final result = await repository.getMediaTagLog(11);
      final entries = (result as DataSuccess).data!.entries;

      final line = entries.firstWhere((entry) => entry.tagId == seriesTagId);

      expect(line.reason, TagLogReason.creator);
      expect(line.detail, 'Uukkaa');
    });
  });

  // La tanda va por el mismo sitio que el de uno solo: es lo que hace que haga
  // exactamente lo mismo sin que este escrito en dos lados.
  group('a toda una seleccion', () {
    test('se lo pone a todos', () async {
      await relate([seriesTagId]);

      final result = await repository.setMediaListCreator([10, 11], creatorId);

      expect((result as DataSuccess<int>).data, 2);
      expect(await tagsOf(10), contains(seriesTagId));
      expect(await tagsOf(11), contains(seriesTagId));
    });

    test('y pisa el creador que hubiera', () async {
      await repository.setMediaCreator(10, unknownId);
      await repository.setMediaListCreator([10], creatorId);

      final media = await isar.mediaModels.get(10);
      await media!.creator.load();

      expect(media.creator.value?.id, creatorId);
    });
  });

  // Al importar, el creador sale de las direcciones vinculadas; lo suyo tiene
  // que entrar igual que si se pusiera a mano.
  group('al importar', () {
    test('el contenido nace con las etiquetas del creador', () async {
      await relate([seriesTagId]);

      await isar.writeTxn(() async {
        final creator = await isar.creatorModels.get(creatorId);
        creator!.sourceUrls = ['pixiv.net/users/1234'];
        await isar.creatorModels.put(creator);
      });

      final summary = await registry.register(
        path: 'C:/media/nuevo.jpg',
        source: ImportSource.local,
        sourceUrls: ['https://www.pixiv.net/en/users/1234/artworks'],
      );

      expect(summary, isNotNull);
      expect(await tagsOf(summary!.id), [seriesTagId, parentTagId]);
    });
  });
}

Future<void> _seed(Isar isar) async {
  final parent = TagModel(id: parentTagId, name: 'manga');
  final series = TagModel(id: seriesTagId, name: 'One Piece');
  final other = TagModel(id: otherTagId, name: 'paisajes');

  final creator = CreatorModel(id: creatorId, name: 'Uukkaa');
  final unknown = CreatorModel(id: unknownId, name: unknownCreator.name);

  await isar.writeTxn(() async {
    await isar.tagModels.putAll([parent, series, other]);
    await isar.creatorModels.putAll([creator, unknown]);

    await parent.children.update(link: [series]);

    // El 10 ya lleva una etiqueta suya; el 11 esta limpio.
    for (final id in [10, 11]) {
      final summary = MediaSummaryModel()
        ..id = id
        ..path = 'C:/media/$id.jpg'
        ..isImported = true;

      final details = MediaModel(id: id, path: 'C:/media/$id.jpg')
        ..downloaded = DateTime(2026, 1, 1)
        ..isFavorite = false;

      await isar.mediaSummaryModels.put(summary);
      await isar.mediaModels.put(details);

      summary.details.value = details;
      await summary.details.save();

      if (id == 10) await details.tags.update(link: [other]);
    }
  });
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
