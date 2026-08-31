// Por qué un contenido acabó con lo que tiene puesto.
//
// La aplicación etiqueta sola por cinco caminos —la dirección de la que se bajó,
// la etiqueta que traía la plataforma, lo que arrastran la rama y las hermanas,
// lo que propone un modelo y lo que enlaza un fernie— y en el panel todos se ven
// igual: una etiqueta más. Cuando aparece una que nadie esperaba, la pregunta es
// de dónde salió, y no había ningún sitio donde mirarlo.
//
// Lo que hay que sostener:
//
// - **Se distingue lo pedido de lo heredado.** Es justo lo que no se puede
//   adivinar mirando el panel, y lo que dice qué corregir para que no vuelva a
//   pasar.
// - **No se apunta dos veces lo mismo.** Aceptar dos veces la misma sugerencia
//   no puede dejar dos líneas diciendo que se puso dos veces.
// - **Se va con el contenido.** El identificador es el hash de la ruta, así que
//   el mismo fichero importado otra vez heredaría el registro del anterior.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/features/duplicates/data/models/duplicate_group_model.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/media_tag_log_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/data/repositories/local_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/media_tag_log.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/media/domain/entities/tag_log_entry_entity.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/core/services/shuffle_seed.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late LocalMediaRepositoryImpl repository;
  late MediaTagLog log;

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
    directory = await Directory.systemTemp.createTemp('fern_tag_log_test');

    isar = await Isar.open(
      [
        TagModelSchema,
        PersonaModelSchema,
        CreatorModelSchema,
        MediaSummaryModelSchema,
        MediaModelSchema,
        MediaTagLogModelSchema,
        // Los mira el borrado de contenido: sin ellas, la prueba que comprueba
        // que el registro se va con el contenido no llega ni a borrarlo.
        FernieModelSchema,
        FernieRegionModelSchema,
        DuplicateGroupModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    log = MediaTagLog(isar);

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

  Future<int> addMedia({int id = 1}) async {
    final summary = MediaSummaryModel()
      ..id = id
      ..path = 'C:/media/$id.jpg';

    final media = MediaModel(id: id, path: 'C:/media/$id.jpg')
      ..downloaded = DateTime(2026)
      ..isFavorite = false;

    await isar.writeTxn(() async {
      await isar.mediaSummaryModels.put(summary);
      await isar.mediaModels.put(media);
    });

    return id;
  }

  var nextTag = 1;

  Future<TagModel> addTag(String name, {TagModel? parent}) async {
    final tag = TagModel(id: nextTag++, name: name);

    await isar.writeTxn(() async {
      await isar.tagModels.put(tag);

      if (parent != null) await parent.children.update(link: [tag]);
    });

    return tag;
  }

  Future<TagModel> relate(TagModel one, TagModel other) async {
    await isar.writeTxn(() async {
      await one.siblings.update(link: [other]);
      await other.siblings.update(link: [one]);
    });

    return one;
  }

  /// Lo apuntado de un contenido, por etiqueta.
  Future<Map<String, TagLogEntryEntity>> entriesOf(int mediaId) async {
    return {for (final entry in await log.of(mediaId)) entry.label: entry};
  }

  group('lo que se apunta', () {
    test('la etiqueta que se pide, con el motivo de quien la pide', () async {
      final rombo = await addTag('Rombo');
      final media = await addMedia();

      await repository.addTagsToMedia(
        media,
        [rombo.id],
        reason: TagLogReason.recognition,
      );

      expect((await entriesOf(media))['Rombo']?.reason,
          TagLogReason.recognition);
    });

    // Lo que no se puede adivinar mirando el panel: allí «Rombo» y «Figuras» se
    // ven igual, y sólo una de las dos se pidió.
    test('y la de encima como heredada, diciendo de cuál', () async {
      final figuras = await addTag('Figuras');
      final rombo = await addTag('Rombo', parent: figuras);
      final media = await addMedia();

      await repository.addTagsToMedia(media, [rombo.id]);

      final entries = await entriesOf(media);

      expect(entries['Figuras']?.reason, TagLogReason.ancestor);
      expect(entries['Figuras']?.detail, 'Rombo');
      expect(entries['Rombo']?.reason, TagLogReason.manual);
    });

    test('una hermana se apunta como tal', () async {
      final rombo = await addTag('Rombo');
      final cuadrado = await addTag('Cuadrado');
      await relate(rombo, cuadrado);

      final media = await addMedia();

      await repository.addTagsToMedia(media, [rombo.id]);

      final entries = await entriesOf(media);

      expect(entries['Cuadrado']?.reason, TagLogReason.sibling);
      expect(entries['Cuadrado']?.detail, 'Rombo');
    });

    test('el detalle de quien lo pide se conserva', () async {
      final rombo = await addTag('Rombo');
      final media = await addMedia();

      await repository.addTagsToMedia(
        media,
        [rombo.id],
        reason: TagLogReason.fernie,
        detail: 'Marinette',
      );

      expect((await entriesOf(media))['Rombo']?.detail, 'Marinette');
    });

    test('y el creador también', () async {
      final media = await addMedia();
      final creator = CreatorModel(id: 7, name: 'Pompeu');

      await isar.writeTxn(() => isar.creatorModels.put(creator));

      await repository.setMediaCreator(
        media,
        7,
        reason: TagLogReason.recognition,
      );

      final entry = (await log.of(media)).single;

      expect(entry.isCreator, isTrue);
      expect(entry.label, 'Pompeu');
      expect(entry.reason, TagLogReason.recognition);
    });
  });

  group('lo que no se apunta', () {
    // Aceptar dos veces la misma sugerencia no puede dejar dos líneas diciendo
    // que se puso dos veces.
    test('una etiqueta que el contenido ya tenía', () async {
      final rombo = await addTag('Rombo');
      final media = await addMedia();

      await repository.addTagsToMedia(media, [rombo.id]);
      await repository.addTagsToMedia(media, [rombo.id]);

      expect(await log.of(media), hasLength(1));
    });

    test('ni una etiqueta que no existe', () async {
      final media = await addMedia();

      await repository.addTagsToMedia(media, [404]);

      expect(await log.of(media), isEmpty);
    });
  });

  group('el registro', () {
    test('lo más nuevo va primero', () async {
      final uno = await addTag('Uno');
      final dos = await addTag('Dos');
      final media = await addMedia();

      await repository.addTagsToMedia(media, [uno.id]);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await repository.addTagsToMedia(media, [dos.id]);

      expect((await log.of(media)).first.label, 'Dos');
    });

    // Reconocer la biblioteca entera varias veces deja decenas de líneas por
    // contenido, y de un registro así nadie lee más que el final.
    test('tiene tope y se cae lo más viejo', () async {
      final small = MediaTagLog(isar, limit: 2);
      final media = await addMedia();

      for (var each = 1; each <= 4; each++) {
        await isar.writeTxn(() => small.writeInside([
              TagLogEntryEntity(
                mediaId: media,
                reason: TagLogReason.manual,
                label: 'Etiqueta $each',
                at: DateTime(2026, 1, each),
              ),
            ]));
      }

      final kept = [for (final entry in await small.of(media)) entry.label];

      expect(kept, ['Etiqueta 4', 'Etiqueta 3']);
    });

    test('distingue no tener nada de ser anterior al registro', () async {
      final media = await addMedia();

      expect(await log.has(media), isFalse);

      final rombo = await addTag('Rombo');
      await repository.addTagsToMedia(media, [rombo.id]);

      expect(await log.has(media), isTrue);
    });

    // El identificador de un contenido es el hash de su ruta, así que el mismo
    // fichero importado otra vez vuelve con el mismo: heredaría el registro del
    // anterior.
    test('se va con el contenido al borrarlo', () async {
      final rombo = await addTag('Rombo');
      final media = await addMedia();

      await repository.addTagsToMedia(media, [rombo.id]);
      await repository.deleteMediaList([media]);

      expect(await log.of(media), isEmpty);
    });
  });

  group('leerlo', () {
    // La imagen no se guarda con la línea, al revés que el nombre: es cómo se
    // reconoce una etiqueta de un vistazo, así que tiene que ser la de ahora y
    // no la que tuviera el día que se puso.
    test('cada línea trae el avatar de ahora', () async {
      final rombo = await addTag('Rombo');
      final media = await addMedia();

      await repository.addTagsToMedia(media, [rombo.id]);

      // Se le pone el avatar **después** de haberla puesto en el contenido.
      await isar.writeTxn(() async {
        rombo.picturePath = 'C:/avatares/rombo.png';
        await isar.tagModels.put(rombo);
      });

      final view = (await repository.getMediaTagLog(media)).data!;

      expect(view.entries.single.imagePath, 'C:/avatares/rombo.png');
    });

    // La etiqueta puede haberse borrado: la línea sigue contando lo que pasó, y
    // la pantalla pinta su icono de reserva.
    test('y sin ella, la línea se queda igual', () async {
      final rombo = await addTag('Rombo');
      final media = await addMedia();

      await repository.addTagsToMedia(media, [rombo.id]);
      await isar.writeTxn(() => isar.tagModels.delete(rombo.id));

      final view = (await repository.getMediaTagLog(media)).data!;

      expect(view.entries.single.label, 'Rombo');
      expect(view.entries.single.imagePath, isNull);
    });

    test('con líneas apuntadas, no se deduce nada', () async {
      final rombo = await addTag('Rombo');
      final media = await addMedia();

      await repository.addTagsToMedia(media, [rombo.id]);

      final view = (await repository.getMediaTagLog(media)).data!;

      expect(view.isGuess, isFalse);
      expect(view.entries, hasLength(1));
    });

    // El caso que se escapaba: un contenido de siempre al que hoy se le pone una
    // etiqueta tendría una línea de verdad y diecinueve etiquetas sin explicar, y
    // devolver sólo la primera escondería justo lo que se ha ido a mirar.
    test('lo apuntado y lo deducido se mezclan', () async {
      final vieja = await addTag('Vieja');
      final nueva = await addTag('Nueva');
      final media = await addMedia();

      final model = await isar.mediaModels.get(media);
      await isar.writeTxn(() => model!.tags.update(link: [vieja]));

      await repository.addTagsToMedia(media, [nueva.id]);

      final view = (await repository.getMediaTagLog(media)).data!;
      final byLabel = {for (final entry in view.entries) entry.label: entry};

      expect(view.isGuess, isTrue);
      expect(byLabel['Nueva']?.isGuess, isFalse);
      expect(byLabel['Vieja']?.isGuess, isTrue);
    });

    // Todo lo que estaba en la biblioteca antes de esto no tiene ninguna línea,
    // y son casi todos: decir que no se le puso nada sería mentir.
    test('sin ellas se deduce, y se dice que es deducido', () async {
      final figuras = await addTag('Figuras');
      final rombo = await addTag('Rombo', parent: figuras);
      final media = await addMedia();

      final model = await isar.mediaModels.get(media);
      await isar.writeTxn(() => model!.tags.update(link: [figuras, rombo]));

      final view = (await repository.getMediaTagLog(media)).data!;

      expect(view.isGuess, isTrue);
      expect(
        [for (final entry in view.entries) entry.label]..sort(),
        ['Figuras', 'Rombo'],
      );
    });
  });
}

/// Ni ficheros ni avatares: apuntar por qué se puso una etiqueta no toca el
/// disco, y si algún día lo tocara, esto lo diría en vez de dejarlo pasar.
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
