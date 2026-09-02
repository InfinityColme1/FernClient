// Ponerle un creador a un contenido desde el panel.
//
// Dos reglas y las dos habian fallado:
//
// - **Que trae el creador.** `GetTagRelativesUseCase` contesta solo lo que viene
//   *con* las etiquetas que se le dan, sin ellas. Dandolas por hechas, poner un
//   creador ponia la madre de su etiqueta y no la etiqueta: el autoetiquetado
//   por creador no se notaba.
// - **Donde va.** El dialogo mandaba el contenido entero tal y como estaba al
//   abrirlo, asi que confirmar devolvia esa foto al panel y se llevaba por
//   delante todo lo tocado mientras.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/services/refreshed_media.dart';
import 'package:Fern/features/media/domain/usecases/get_tag_relatives_usecase.dart';
import 'package:Fern/features/media/presentation/widgets/creator_tags.dart';
import 'package:flutter_test/flutter_test.dart';

TagEntity _tag(int id, String name) =>
    TagEntity(id: id, name: name, children: const []);

CreatorEntity _creator(List<TagEntity> tags) =>
    CreatorEntity(id: 7, name: 'Uukkaa', tags: tags);

MediaEntity _media(List<TagEntity>? tags, {String? description}) => MediaEntity(
      id: 1,
      path: 'C:/media/1.jpg',
      downloaded: DateTime(2026),
      description: description,
      creator: const CreatorEntity(id: 0, name: 'Unknown'),
      tags: tags,
    );

void main() {
  group('lo que trae el creador', () {
    late List<TagEntity> relatives;

    setUp(() async {
      await getIt.reset();
      relatives = const [];
      getIt.registerSingleton<GetTagRelativesUseCase>(
        _Relatives(() => relatives),
      );
      addTearDown(getIt.reset);
    });

    // El fallo: se daban por hechas y se ponia solo lo que arrastraban.
    test('las suyas, para empezar', () async {
      final brings = await tagsOfCreator(_creator([_tag(1, 'One Piece')]));

      expect([for (final tag in brings) tag.id], [1]);
    });

    test('y lo que ellas arrastran, detras', () async {
      relatives = [_tag(2, 'manga')];

      final brings = await tagsOfCreator(_creator([_tag(1, 'One Piece')]));

      expect([for (final tag in brings) tag.id], [1, 2]);
    });

    test('sin repetir', () async {
      relatives = [_tag(1, 'One Piece'), _tag(2, 'manga')];

      final brings = await tagsOfCreator(_creator([_tag(1, 'One Piece')]));

      expect([for (final tag in brings) tag.id], [1, 2]);
    });

    // Un creador sin etiquetas no trae nada, y sobre todo no va a preguntar.
    test('un creador sin etiquetas no trae nada', () async {
      expect(await tagsOfCreator(_creator(const [])), isEmpty);
    });

    // Si no se puede leer lo que arrastran, al menos entran las suyas: quedarse
    // sin poner ninguna seria perder justo lo que se acaba de pedir.
    test('sin poder leer lo que arrastran, entran las suyas', () async {
      getIt.unregister<GetTagRelativesUseCase>();
      getIt.registerSingleton<GetTagRelativesUseCase>(const _Failing());

      final brings = await tagsOfCreator(_creator([_tag(1, 'One Piece')]));

      expect([for (final tag in brings) tag.id], [1]);
    });
  });

  group('donde va', () {
    test('el creador se pone', () {
      final result = mediaWithCreator(
        _media(const []),
        _creator(const []),
        const [],
      );

      expect(result.creator.id, 7);
    });

    test('y lo que trae se suma', () {
      final result = mediaWithCreator(
        _media([_tag(9, 'paisajes')]),
        _creator(const []),
        [_tag(1, 'One Piece')],
      );

      expect([for (final tag in result.tags!) tag.id], [9, 1]);
    });

    // Lo que el panel llevara sin guardar no puede perderse por elegir un
    // creador: es lo que pasaba mandando el contenido entero.
    test('sin quitar nada de lo que ya llevaba', () {
      final result = mediaWithCreator(
        _media([_tag(9, 'paisajes')], description: 'a medio escribir'),
        _creator(const []),
        [_tag(1, 'One Piece')],
      );

      expect(result.description, 'a medio escribir');
      expect([for (final tag in result.tags!) tag.id], contains(9));
    });

    test('lo que ya estaba puesto no se repite', () {
      final result = mediaWithCreator(
        _media([_tag(1, 'One Piece')]),
        _creator(const []),
        [_tag(1, 'One Piece'), _tag(2, 'manga')],
      );

      expect([for (final tag in result.tags!) tag.id], [1, 2]);
    });

    test('y un contenido sin etiquetas se queda con las que traiga', () {
      final result = mediaWithCreator(
        _media(null),
        _creator(const []),
        [_tag(1, 'One Piece')],
      );

      expect([for (final tag in result.tags!) tag.id], [1]);
    });
  });
}

class _Relatives implements GetTagRelativesUseCase {
  final List<TagEntity> Function() _answer;

  const _Relatives(this._answer);

  @override
  Future<DataState<List<TagEntity>>> call({List<TagEntity>? params}) async =>
      DataSuccess(_answer());

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Failing implements GetTagRelativesUseCase {
  const _Failing();

  @override
  Future<DataState<List<TagEntity>>> call({List<TagEntity>? params}) async =>
      DataException(Exception('no se pudo leer'));

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
