// Lo que el panel enseña después de que un fernie le ponga etiquetas por detrás.
//
// El fallo: se rellenaba el panel —un creador, unas cuantas etiquetas—, se
// marcaba una región de un fernie y todo eso desaparecía. Al salir del modo
// fernie se releía el contenido de la base y se **sustituía** lo del panel con
// lo leído, y lo del panel todavía no estaba en la base: sólo estaba en
// pantalla, esperando al botón de guardar.
//
// Se mide aquí y no sobre el `MediaBloc` porque montarlo son treinta y pico
// casos de uso, y lo que hay que sostener es esta regla, no el bloc.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/services/refreshed_media.dart';
import 'package:flutter_test/flutter_test.dart';

TagEntity _tag(int id, String name) =>
    TagEntity(id: id, name: name, children: const []);

MediaEntity _media({
  List<TagEntity>? tags,
  CreatorEntity? creator,
  String? description,
}) =>
    MediaEntity(
      id: 1,
      path: 'C:/media/1.jpg',
      downloaded: DateTime(2026),
      description: description,
      creator: creator ?? unknownCreator,
      tags: tags,
    );

void main() {
  group('las etiquetas', () {
    test('las del panel sin guardar se quedan', () {
      final result = refreshedMedia(
        _media(tags: [_tag(1, 'Nami'), _tag(2, 'One Piece')]),
        _media(tags: [_tag(3, 'Marinette')]),
      );

      expect(
        [for (final tag in result.tags!) tag.name],
        ['Nami', 'One Piece', 'Marinette'],
      );
    });

    test('y lo que el fernie acaba de poner entra', () {
      final result = refreshedMedia(
        _media(tags: const []),
        _media(tags: [_tag(3, 'Marinette')]),
      );

      expect([for (final tag in result.tags!) tag.id], [3]);
    });

    // La que ya estaba puesta en los dos sitios no se cuenta dos veces.
    test('lo que está en las dos listas sale una vez', () {
      final result = refreshedMedia(
        _media(tags: [_tag(1, 'Nami')]),
        _media(tags: [_tag(1, 'Nami'), _tag(3, 'Marinette')]),
      );

      expect([for (final tag in result.tags!) tag.id], [1, 3]);
    });

    // Quitar una etiqueta desde el panel se escribe en el momento, así que lo
    // que ya no está en la base tampoco está en el panel: sumar no la resucita.
    test('sumar no devuelve lo que se acaba de quitar', () {
      final result = refreshedMedia(
        _media(tags: [_tag(1, 'Nami')]),
        _media(tags: [_tag(1, 'Nami')]),
      );

      expect([for (final tag in result.tags!) tag.id], [1]);
    });
  });

  group('el creador', () {
    test('el que se acaba de elegir y no está guardado se queda', () {
      final result = refreshedMedia(
        _media(creator: const CreatorEntity(id: 7, name: 'Uukkaa')),
        _media(creator: const CreatorEntity(id: 9, name: 'Otro')),
      );

      expect(result.creator.id, 7);
    });

    // El fernie pone el suyo cuando falta, y ahí sí hay que enseñarlo: es lo
    // que acaba de pasar.
    test('pero sin ninguno puesto se coge el de la base', () {
      final result = refreshedMedia(
        _media(),
        _media(creator: const CreatorEntity(id: 9, name: 'Uukkaa')),
      );

      expect(result.creator.id, 9);
    });
  });

  // Lo que no son etiquetas ni creador no se toca: releer el contenido entero
  // era justo lo que se llevaba por delante una descripción a medio escribir.
  test('lo demás del panel se queda como estaba', () {
    final result = refreshedMedia(
      _media(description: 'a medio escribir'),
      _media(description: 'lo de la base'),
    );

    expect(result.description, 'a medio escribir');
  });
}
