// Resolver un grupo de repetidos.
//
// Es la única parte de la función que destruye algo, así que lo que se prueba
// aquí es sobre todo el orden y lo que pasa cuando algo falla a media faena: que
// no se tire nada antes de haber recogido lo que valía, y que un grupo que no se
// pudo vaciar siga apareciendo en vez de darse por hecho.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/duplicates/domain/repositories/duplicate_repository.dart';
import 'package:Fern/features/duplicates/domain/usecases/apply_duplicate_group_usecase.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:flutter_test/flutter_test.dart';

MediaEntity _media(
  int id, {
  List<TagEntity>? tags,
  String creator = 'Unknown',
  bool favorite = false,
}) =>
    MediaEntity(
      id: id,
      path: 'C:/$id.jpg',
      downloaded: DateTime(2026),
      creator: CreatorEntity(id: id, name: creator),
      tags: tags,
      isFavorite: favorite,
    );

TagEntity _tag(int id) => TagEntity(id: id, name: 'etiqueta-$id', children: []);

void main() {
  late _FakeMedia media;
  late _FakeDuplicates duplicates;
  late _FakeFernies fernies;
  late ApplyDuplicateGroupUseCase apply;

  setUp(() {
    media = _FakeMedia();
    duplicates = _FakeDuplicates();
    fernies = _FakeFernies();
    apply = ApplyDuplicateGroupUseCase(
      media: media,
      duplicates: duplicates,
      fernies: fernies,
    );
  });

  Future<DataState<bool>> run({
    bool merge = true,
    List<MediaEntity>? discarded,
    MediaEntity? keeper,
  }) {
    return apply(
      params: ApplyDuplicateGroupParams(
        groupId: 7,
        keeper: keeper ?? _media(1),
        discarded: discarded ?? [_media(2)],
        mergeMetadata: merge,
      ),
    );
  }

  group('lo normal', () {
    test('la copia que queda se lleva lo de las otras', () async {
      await run(
        keeper: _media(1, tags: [_tag(1)]),
        discarded: [_media(2, tags: [_tag(2)], creator: 'Rin', favorite: true)],
      );

      final saved = media.saved.single;
      expect(saved.tags?.map((one) => one.id), [1, 2]);
      expect(saved.creator.name, 'Rin');
      expect(saved.isFavorite, isTrue);
    });

    test('las descartadas van a la papelera, no al borrado', () async {
      await run(discarded: [_media(2), _media(3)]);

      // Siete días de margen: esta pantalla es donde más fácil es equivocarse.
      expect(media.trashed, [2, 3]);
      expect(media.purged, isEmpty);
    });

    test('el grupo queda por visto', () async {
      final result = await run();

      expect(duplicates.resolved, [7]);
      expect(result, isA<DataSuccess<bool>>());
    });

    test('se fusiona antes de tirar nada', () async {
      await run();

      // Al revés se perderían las etiquetas de la copia que se va justo cuando
      // se estaban recogiendo.
      expect(media.order, ['save', 'trash']);
    });

    test('sin fusionar no se toca la que se queda', () async {
      await run(merge: false);

      expect(media.saved, isEmpty);
      expect(media.trashed, [2]);
      expect(duplicates.resolved, [7]);
    });

    test('un grupo de uno se da por visto sin tirar nada', () async {
      await run(discarded: const []);

      expect(media.trashed, isEmpty);
      expect(duplicates.resolved, [7]);
    });
  });

  group('las marcas de fernies', () {
    FernieRegionEntity region({
      int id = 1,
      int mediaId = 2,
      int fernieId = 10,
      double x = 0.1,
    }) {
      return FernieRegionEntity(
        id: id,
        mediaId: mediaId,
        fernieId: fernieId,
        x: x,
        y: 0.2,
        w: 0.3,
        h: 0.4,
      );
    }

    // Las regiones apuntan al contenido desde fuera, así que se van con la copia
    // descartada cuando la papelera se vacíe. Y son rectángulos dibujados a
    // mano: no hay de dónde recuperarlos.
    test('las de la descartada acaban en la que se queda', () async {
      fernies.regions[2] = [region()];

      await run();

      expect(fernies.added, hasLength(1));
      expect(fernies.added.single.mediaId, 1);
    });

    test('sin fusionar no se tocan, como el resto de los datos', () async {
      fernies.regions[2] = [region()];

      await run(merge: false);

      expect(fernies.added, isEmpty);
    });

    test('lo que ya estaba marcado en la que se queda no se repite', () async {
      fernies.regions[1] = [region(mediaId: 1)];
      fernies.regions[2] = [region(mediaId: 2)];

      await run();

      expect(fernies.added, isEmpty);
    });

    // Es lo menos grave de la fusión: las regiones de las descartadas siguen
    // donde están mientras la papelera no se vacíe, así que hay siete días para
    // volver a intentarlo. Parar aquí dejaría el grupo sin resolver con las
    // etiquetas ya fusionadas, que es un estado a medias peor.
    test('si no se pueden leer, el grupo se resuelve igual', () async {
      fernies.isBroken = true;

      final result = await run();

      expect(result, isA<DataSuccess>());
      expect(duplicates.resolved, contains(7));
    });

    // Con el fake devolviendo un error en vez de lanzarlo, esta comprobación no
    // pasaba por el `catch` y quitarlo la dejaba en verde igual: lo destapó la
    // verificación por inyección.
    test('si reventar al leerlas, el grupo se resuelve igual', () async {
      fernies.throwsOnRead = true;

      final result = await run();

      expect(result, isA<DataSuccess>());
      expect(duplicates.resolved, contains(7));
    });

    test('si no se pueden guardar, el grupo se resuelve igual', () async {
      fernies.regions[2] = [region()];
      fernies.throwsOnAdd = true;

      final result = await run();

      expect(result, isA<DataSuccess>());
      expect(duplicates.resolved, contains(7));
    });
  });

  group('lo que sale mal', () {
    test('si no se puede guardar la fusión, no se tira nada', () async {
      media.brokenSave = true;

      final result = await run();

      expect(result, isA<DataException>());
      expect(media.trashed, isEmpty);
      expect(duplicates.resolved, isEmpty);
    });

    test('si no se puede vaciar, el grupo sigue apareciendo', () async {
      media.brokenTrash = true;

      final result = await run();

      // Darlo por visto lo haría desaparecer dejando los duplicados donde
      // estaban, y nadie volvería a mirarlo.
      expect(result, isA<DataException>());
      expect(duplicates.resolved, isEmpty);
    });

    test('sin decir qué grupo, no se hace nada', () async {
      expect(await apply(), isA<DataException>());
      expect(media.trashed, isEmpty);
    });
  });

  group('no son duplicados', () {
    test('el grupo se descarta y no vuelve', () async {
      final result = await DismissDuplicateGroupUseCase(duplicates)(params: 7);

      expect(duplicates.dismissed, [7]);
      expect(result, isA<DataSuccess<bool>>());
    });

    test('sin grupo no se descarta nada', () async {
      expect(await DismissDuplicateGroupUseCase(duplicates)(), isA<DataException>());
      expect(duplicates.dismissed, isEmpty);
    });
  });
}

class _FakeMedia implements LocalMediaRepository {
  final saved = <MediaEntity>[];
  final trashed = <int>[];
  final purged = <int>[];
  final order = <String>[];

  var brokenSave = false;
  var brokenTrash = false;

  @override
  Future<DataState> saveMedia(MediaEntity media) async {
    if (brokenSave) return DataException(Exception('roto'));

    order.add('save');
    saved.add(media);

    return const DataSuccess(null);
  }

  @override
  Future<DataState> markMediaListAsDeleted(List<int> ids) async {
    if (brokenTrash) return DataException(Exception('roto'));

    order.add('trash');
    trashed.addAll(ids);

    return const DataSuccess(null);
  }

  @override
  Future<DataState> deleteMediaList(List<int> ids, {bool deleteFiles = false}) async {
    purged.addAll(ids);

    return const DataSuccess(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeDuplicates implements DuplicateRepository {
  final resolved = <int>[];
  final dismissed = <int>[];

  @override
  Future<DataState<bool>> markResolved(int groupId) async {
    resolved.add(groupId);

    return const DataSuccess(true);
  }

  @override
  Future<DataState<bool>> markDismissed(int groupId) async {
    dismissed.add(groupId);

    return const DataSuccess(true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// Las regiones que hay marcadas y las que se han añadido.
class _FakeFernies implements FernieRepository {
  final Map<int, List<FernieRegionEntity>> regions = {};
  final List<FernieRegionEntity> added = [];

  /// Devuelve un error al leer las regiones.
  bool isBroken = false;

  /// Revienta al leer las regiones. Es distinto de lo anterior y hay que
  /// probarlo aparte: un error devuelto se mira, uno lanzado hay que atraparlo,
  /// y sólo el segundo pasa por el `catch` que impide que esto tumbe el aplicar.
  bool throwsOnRead = false;

  @override
  Future<DataState<List<FernieRegionEntity>>> getRegionsOfMedia(int mediaId) async {
    if (throwsOnRead) throw StateError('sin fernies');
    if (isBroken) return DataException(Exception('roto'));

    return DataSuccess(regions[mediaId] ?? const []);
  }

  /// Revienta al guardarlas.
  bool throwsOnAdd = false;

  @override
  Future<DataState<List<FernieRegionEntity>>> addRegions(
    List<FernieRegionEntity> toAdd,
  ) async {
    if (throwsOnAdd) throw StateError('no se pueden guardar');

    added.addAll(toAdd);

    return DataSuccess(toAdd);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}
