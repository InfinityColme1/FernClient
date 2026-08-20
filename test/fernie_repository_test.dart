// Qué guarda y qué borra el repositorio de fernies.
//
// Se prueba contra una base de datos de verdad, como el de borrado de
// contenido: lo que importa aquí es que las regiones queden enlazadas a su
// fernie y que borrar no deje huérfanos, y eso sólo lo demuestra Isar.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/recognition/data/repositories/fernie_repository_impl.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory directory;
  late Directory avatars;
  late Isar isar;
  late FernieRepositoryImpl repository;

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
    directory = await Directory.systemTemp.createTemp('fern_fernies_test');
    avatars = await Directory(p.join(directory.path, 'avatars')).create();

    isar = await Isar.open(
      [
        TagModelSchema,
        PersonaModelSchema,
        CreatorModelSchema,
        MediaSummaryModelSchema,
        MediaModelSchema,
        FernieModelSchema,
        FernieRegionModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    repository = FernieRepositoryImpl(
      database: isar,
      avatarStorage:
          AvatarStorageService(settingsRepository: _Settings(avatars.path)),
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  /// Da de alta un contenido, que es lo que las regiones necesitan tener
  /// delante para poder apuntar a algo.
  Future<int> addMedia(String path) async {
    final summary = MediaSummaryModel.fromEntity(
      MediaSummaryEntity(id: Isar.autoIncrement, path: path),
    );

    await isar.writeTxn(() => isar.mediaSummaryModels.put(summary));
    return summary.id;
  }

  Future<FernieEntity> addFernie(String name) async {
    final result = await repository.saveFernie(
      FernieEntity(id: unsavedId, name: name),
    );

    expect(result, isA<DataSuccess>());
    return result.data!;
  }

  FernieRegionEntity region(int mediaId, int fernieId, {int? frameMs}) {
    return FernieRegionEntity(
      id: unsavedId,
      mediaId: mediaId,
      fernieId: fernieId,
      x: 0.1,
      y: 0.2,
      w: 0.3,
      h: 0.4,
      frameMs: frameMs,
    );
  }

  group('alta y edición', () {
    test('un fernie nuevo nace sin regiones y sin enlace', () async {
      final fernie = await addFernie('Marinette');

      expect(fernie.id, isNot(unsavedId));
      expect(fernie.name, 'Marinette');
      expect(fernie.regionCount, 0);
      expect(fernie.mediaCount, 0);
      expect(fernie.linkKind, FernieLinkKind.none);
    });

    test('el enlace pasa de etiqueta a creador sin quedarse los dos', () async {
      final fernie = await addFernie('Adrien');

      final linked = await repository.updateFernie(
        fernie.copyWith(linkedTagId: 5),
      );
      expect(linked.data!.linkedTagId, 5);
      expect(linked.data!.linkedCreatorId, isNull);
      expect(linked.data!.linkKind, FernieLinkKind.tag);

      final relinked = await repository.updateFernie(
        linked.data!.copyWith(linkedCreatorId: 9),
      );
      expect(relinked.data!.linkedCreatorId, 9);
      expect(relinked.data!.linkedTagId, isNull,
          reason: 'los dos enlaces a la vez no tienen sentido');
    });

    test('la búsqueda no distingue mayúsculas y con texto vacío no da nada',
        () async {
      await addFernie('Marinette');

      final found = await repository.searchFernies('mari');
      expect(found.data, hasLength(1));

      final empty = await repository.searchFernies('   ');
      expect(empty.data, isEmpty);
    });
  });

  group('regiones', () {
    test('las regiones se guardan de una vez y quedan enlazadas', () async {
      final media = await addMedia(p.join(directory.path, 'uno.jpg'));
      final fernie = await addFernie('Marinette');

      final saved = await repository.addRegions([
        region(media, fernie.id),
        region(media, fernie.id, frameMs: 12000),
      ]);

      expect(saved.data, hasLength(2));
      expect(saved.data!.every((r) => r.fernieId == fernie.id), isTrue);

      final ofMedia = await repository.getRegionsOfMedia(media);
      expect(ofMedia.data, hasLength(2));
      expect(ofMedia.data!.map((r) => r.frameMs), containsAll([null, 12000]));
    });

    test('los recuentos cuentan regiones y contenidos distintos', () async {
      final uno = await addMedia(p.join(directory.path, 'uno.jpg'));
      final dos = await addMedia(p.join(directory.path, 'dos.jpg'));
      final fernie = await addFernie('Marinette');

      await repository.addRegions([
        region(uno, fernie.id),
        region(uno, fernie.id),
        region(dos, fernie.id),
      ]);

      final read = await repository.getFernie(fernie.id);
      expect(read.data!.regionCount, 3);
      expect(read.data!.mediaCount, 2,
          reason: 'tres regiones, pero sólo dos contenidos distintos');
    });

    test('cada región da una celda, también las del mismo contenido', () async {
      final media = await addMedia(p.join(directory.path, 'uno.jpg'));
      final fernie = await addFernie('Marinette');

      await repository.addRegions([
        region(media, fernie.id),
        region(media, fernie.id),
      ]);

      final grid = await repository.getMediaOfFernie(fernie.id);
      expect(grid.data, hasLength(2));
      expect(grid.data!.every((entry) => entry.media.id == media), isTrue);
    });

    test('una región no se guarda si su fernie no existe', () async {
      final media = await addMedia(p.join(directory.path, 'uno.jpg'));

      final saved = await repository.addRegions([region(media, 12345)]);

      expect(saved.data, isEmpty);
      expect(await isar.fernieRegionModels.count(), 0);
    });

    test('reasignar una región la pasa al otro fernie', () async {
      final media = await addMedia(p.join(directory.path, 'uno.jpg'));
      final uno = await addFernie('Marinette');
      final dos = await addFernie('Adrien');

      final saved = await repository.addRegions([region(media, uno.id)]);
      final original = saved.data!.single;

      await repository.updateRegion(original.copyWith(fernieId: dos.id));

      expect((await repository.getRegionsOfFernie(uno.id)).data, isEmpty);
      expect((await repository.getRegionsOfFernie(dos.id)).data, hasLength(1));
    });

    test('los fernies de un contenido son los que tienen algo marcado en él',
        () async {
      final uno = await addMedia(p.join(directory.path, 'uno.jpg'));
      final dos = await addMedia(p.join(directory.path, 'dos.jpg'));
      final marcado = await addFernie('Marinette');
      await addFernie('Nadie');

      await repository.addRegions([region(uno, marcado.id)]);

      final ofUno = await repository.getFerniesOfMedia(uno);
      expect(ofUno.data!.map((f) => f.name), ['Marinette']);

      final ofDos = await repository.getFerniesOfMedia(dos);
      expect(ofDos.data, isEmpty);
    });
  });

  group('borrado', () {
    test('borrar un fernie se lleva sus regiones y no deja huérfanas',
        () async {
      final media = await addMedia(p.join(directory.path, 'uno.jpg'));
      final fernie = await addFernie('Marinette');
      final otro = await addFernie('Adrien');

      await repository.addRegions([
        region(media, fernie.id),
        region(media, fernie.id),
        region(media, otro.id),
      ]);

      await repository.deleteFernie(fernie.id);

      expect(await isar.fernieModels.get(fernie.id), isNull);
      // Sólo se va lo suyo: la del otro fernie sigue donde estaba.
      expect(await isar.fernieRegionModels.count(), 1);
      expect((await repository.getRegionsOfFernie(otro.id)).data, hasLength(1));
    });

    test('borrar las regiones de un contenido no toca al fernie', () async {
      final uno = await addMedia(p.join(directory.path, 'uno.jpg'));
      final dos = await addMedia(p.join(directory.path, 'dos.jpg'));
      final fernie = await addFernie('Marinette');

      await repository.addRegions([
        region(uno, fernie.id),
        region(dos, fernie.id),
      ]);

      final removed = await repository.deleteRegionsOfMedia([uno]);
      expect(removed.data, 1);

      final read = await repository.getFernie(fernie.id);
      expect(read.data!.regionCount, 1);
      expect((await repository.getRegionsOfMedia(uno)).data, isEmpty);
      expect((await repository.getRegionsOfMedia(dos)).data, hasLength(1));
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

/// Los únicos ajustes que hacen falta: dónde está la carpeta de avatares, que es
/// lo que decide si una imagen es nuestra y se puede borrar.
class _Settings implements SettingsRepository {
  final String avatarsPath;

  _Settings(this.avatarsPath);

  @override
  AppSettingsEntity getSettings() => AppSettingsEntity(
        avatarsPath: avatarsPath,
        recognitionPath: avatarsPath,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
