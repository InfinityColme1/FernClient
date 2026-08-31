// Lo que el fernie enlaza se le pone al contenido al marcarle una región.
//
// Un fernie es «esto que sale aquí», y marcarlo en un contenido es decir que
// sale ahí. Si además enlaza una etiqueta, ponérsela es la consecuencia
// evidente — y no pasaba: marcar una región escribía la región y nada más, así
// que había que ir a poner la etiqueta a mano justo después de haber dicho de
// qué se trataba.
//
// La asimetría entre etiqueta y creador es la decisión que hay que sostener: una
// etiqueta más nunca estorba, pero el creador es uno solo y pisar el que alguien
// puso a mano sería que marcar una región cambiara un dato que nadie pidió
// cambiar.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/entities/tag_log_entry_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/apply_fernie_link_to_media_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

FernieEntity _fernie({int? tagId, int? creatorId}) => FernieEntity(
      id: 7,
      name: 'Marinette',
      linkedTagId: tagId,
      linkedCreatorId: creatorId,
    );

void main() {
  late _FakeRepository repository;
  late ApplyFernieLinkToMediaUseCase apply;

  setUp(() {
    repository = _FakeRepository();
    apply = ApplyFernieLinkToMediaUseCase(repository);
  });

  Future<FernieLinkApplied> on(
    FernieEntity fernie, {
    List<int> mediaIds = const [1],
  }) async {
    final result = await apply(
      params: ApplyFernieLinkParams(fernie: fernie, mediaIds: mediaIds),
    );

    expect(result, isA<DataSuccess>());

    return result.data!;
  }

  group('la etiqueta', () {
    test('se le pone al contenido', () async {
      final done = await on(_fernie(tagId: 3));

      // Campo a campo: dentro de un registro la lista se compara por identidad,
      // así que dos con el mismo contenido no son iguales.
      expect(repository.tagged, hasLength(1));
      expect(repository.tagged.single.mediaId, 1);
      expect(repository.tagged.single.tagIds, [3]);
      expect(done.tagged, 1);
    });

    test('a todos los que se digan', () async {
      await on(_fernie(tagId: 3), mediaIds: [1, 2, 5]);

      expect(
        repository.tagged.map((each) => each.mediaId),
        [1, 2, 5],
      );
    });

    // Se suma a lo que hubiera: `addTagsToMedia` no resetea, y expandir la
    // jerarquía es cosa suya. Aquí lo único que se decide es a quién pedírselo.
    test('sin enlazar ninguna, no se pone nada', () async {
      final done = await on(_fernie());

      expect(repository.tagged, isEmpty);
      expect(done.tagged, 0);
    });
  });

  group('el creador', () {
    // Sólo donde no hay ninguno o está el «desconocido»: pisar el que alguien
    // puso a mano sería cambiar un dato que nadie pidió cambiar.
    test('se pone sólo si falta', () async {
      await on(_fernie(creatorId: 9));

      expect(repository.credited.single.onlyIfMissing, isTrue);
    });

    test('y se cuenta sólo si ha llegado a ponerse', () async {
      repository.creatorChanges = false;

      final done = await on(_fernie(creatorId: 9));

      // Que ya tuviera uno suyo no es un fallo: no hay nada que decir.
      expect(done.credited, 0);
    });

    test('cuando sí, se cuenta', () async {
      final done = await on(_fernie(creatorId: 9));

      expect(done.credited, 1);
    });
  });

  // Un fernie enlaza una cosa o la otra, nunca las dos; pero si algún día
  // llegaran juntas, las dos tienen que pasar.
  test('con etiqueta y creador se hacen las dos', () async {
    final done = await on(_fernie(tagId: 3, creatorId: 9));

    expect(done.tagged, 1);
    expect(done.credited, 1);
  });

  test('sin contenidos no se pide nada', () async {
    final done = await on(_fernie(tagId: 3), mediaIds: const []);

    expect(repository.tagged, isEmpty);
    expect(done, (tagged: 0, credited: 0));
  });
}

class _FakeRepository implements LocalMediaRepository {
  final tagged = <({int mediaId, List<int> tagIds})>[];
  final credited = <({int mediaId, int creatorId, bool onlyIfMissing})>[];

  /// Si poner el creador llega a cambiar algo. En `false` es lo que contesta el
  /// repositorio cuando el contenido ya tenía uno puesto a mano.
  bool creatorChanges = true;

  @override
  Future<DataState<int>> addTagsToMedia(
    int mediaId,
    List<int> tagIds, {
    TagLogReason reason = TagLogReason.manual,
    String? detail,
  }) async {
    tagged.add((mediaId: mediaId, tagIds: tagIds));

    return DataSuccess(tagIds.length);
  }

  @override
  Future<DataState<bool>> setMediaCreator(
    int mediaId,
    int creatorId, {
    bool onlyIfMissing = false,
    TagLogReason reason = TagLogReason.manual,
  }) async {
    credited.add((
      mediaId: mediaId,
      creatorId: creatorId,
      onlyIfMissing: onlyIfMissing,
    ));

    return DataSuccess(creatorChanges);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
