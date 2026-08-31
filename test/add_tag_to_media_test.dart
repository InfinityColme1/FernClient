// Poner la misma etiqueta a un puñado de contenidos.
//
// Es lo que hace falta para etiquetar en tanda —arrastrando a una etiqueta del
// menú, o desde el menú del botón derecho—: hasta ahora la única forma de poner
// la misma etiqueta a treinta contenidos era abrirlos uno a uno.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/entities/tag_log_entry_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/usecases/add_tag_to_media_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeRepository repository;
  late AddTagToMediaUseCase addTag;

  setUp(() {
    repository = _FakeRepository();
    addTag = AddTagToMediaUseCase(repository);
  });

  Future<int> tag(List<int> mediaIds, {int tagId = 7}) async {
    final result = await addTag(
      params: AddTagToMediaParams(tagId: tagId, mediaIds: mediaIds),
    );

    return (result as DataSuccess<int>).data!;
  }

  test('se la pone a todos', () async {
    expect(await tag([1, 2, 3]), 3);

    // Uno por contenido, y siempre la misma etiqueta.
    expect([for (final call in repository.calls) call.$1], [1, 2, 3]);
    expect(
      repository.calls.every((call) => call.$2.single == 7),
      isTrue,
    );
  });

  test('sin contenidos no hace nada', () async {
    expect(await tag(const []), 0);
    expect(repository.calls, isEmpty);
  });

  // En una tanda de treinta, que uno se haya quedado sin fila por medio no puede
  // costar los otros veintinueve.
  test('uno que falla no para a los demás', () async {
    repository.failing = {2};

    expect(await tag([1, 2, 3]), 2);
    expect(repository.calls, hasLength(3));
  });

  test('si fallan todos, lo dice', () async {
    repository.failing = {1, 2};

    expect(await tag([1, 2]), 0);
  });
}

class _FakeRepository implements LocalMediaRepository {
  final calls = <(int, List<int>)>[];

  /// Los contenidos que no aceptan la etiqueta.
  Set<int> failing = const {};

  @override
  Future<DataState<int>> addTagsToMedia(
    int mediaId,
    List<int> tagIds, {
    TagLogReason reason = TagLogReason.manual,
    String? detail,
  }) async {
    calls.add((mediaId, tagIds));

    if (failing.contains(mediaId)) {
      return DataException(Exception('no existe'));
    }

    return DataSuccess(tagIds.length);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
