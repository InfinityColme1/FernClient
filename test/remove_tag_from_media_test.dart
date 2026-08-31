// Quitarle una etiqueta al contenido que se está viendo, desde su panel.
//
// Antes esto sólo se podía hacer desde la pantalla de gestión de etiquetas, y
// allí se le quita a **lo que esté marcado en la rejilla**, no al contenido que
// se está mirando.
//
// El fallo que esto protege es de los que no dan la cara: el panel guarda las
// etiquetas que lleva `currentMedia` **sustituyendo** las de la base
// (`saveMedia` usa `reset: true`). Escribir el borrado sin tocar el estado
// habría funcionado hasta que alguien pulsara Guardar, y entonces la etiqueta
// volvería sin que nada lo explicara.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/usecases/remove_tag_from_media_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

TagEntity _tag(int id, String name) =>
    TagEntity(id: id, name: name, children: const []);

MediaEntity _media(List<TagEntity> tags) => MediaEntity(
      id: 1,
      path: r'C:\biblioteca\uno.png',
      creator: const CreatorEntity(id: 10, name: 'alguien'),
      downloaded: DateTime(2024),
      tags: tags,
    );

void main() {
  late _FakeRepository repository;
  late RemoveTagFromMediaUseCase usecase;

  setUp(() {
    repository = _FakeRepository();
    usecase = RemoveTagFromMediaUseCase(repository);
  });

  /// Lo que hace el bloc al pulsar la cruz: escribe y recorta el contenido que
  /// se está viendo, las dos cosas.
  Future<MediaEntity> removeFrom(MediaEntity media, int tagId) async {
    final result = await usecase(
      params: RemoveTagFromMediaParams(tagId: tagId, mediaIds: [media.id]),
    );
    expect(result, isA<DataSuccess>());

    return media.copyWith(
      tags: [
        for (final tag in media.tags ?? const <TagEntity>[])
          if (tag.id != tagId) tag,
      ],
    );
  }

  test('se le quita a ese contenido y a ninguno mas', () async {
    await removeFrom(_media([_tag(1, 'ladybug')]), 1);

    // Campo a campo: dentro de un registro la lista se compara por identidad,
    // así que dos con el mismo contenido no son iguales.
    expect(repository.removed, hasLength(1));
    expect(repository.removed.single.tagId, 1);
    expect(repository.removed.single.mediaIds, [1]);
  });

  // La mitad que faltaba: sin esto, Guardar la devolveria.
  test('y desaparece de lo que se esta viendo', () async {
    final after = await removeFrom(
      _media([_tag(1, 'ladybug'), _tag(2, 'paisaje')]),
      1,
    );

    expect(after.tags!.map((tag) => tag.name), ['paisaje']);
  });

  // Entraron por su cuenta al elegir la hija, y quitarlas en cascada
  // sorprenderia a quien solo queria deshacer una.
  test('sus madres y sus hermanas se quedan', () async {
    final after = await removeFrom(
      _media([_tag(1, 'marinette'), _tag(2, 'miraculous'), _tag(3, 'serie')]),
      1,
    );

    expect(after.tags!.map((tag) => tag.name), ['miraculous', 'serie']);
  });

  test('quitar la ultima deja la lista vacia, no nula', () async {
    final after = await removeFrom(_media([_tag(1, 'ladybug')]), 1);

    expect(after.tags, isEmpty);
  });

  test('quitar una que no tiene no toca las demas', () async {
    final after = await removeFrom(_media([_tag(1, 'ladybug')]), 99);

    expect(after.tags!.map((tag) => tag.name), ['ladybug']);
  });
}

class _FakeRepository implements LocalMediaRepository {
  final removed = <({int tagId, List<int> mediaIds})>[];

  @override
  Future<DataState<void>> removeTagFromMedia(
    int tagId,
    List<int> mediaIds,
  ) async {
    removed.add((tagId: tagId, mediaIds: mediaIds));

    return const DataSuccess(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
