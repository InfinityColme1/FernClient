// Lo que se puede deducir del contenido anterior al registro.
//
// Todo lo que ya estaba en la biblioteca no tiene ninguna línea apuntada, y ésos
// son casi todos: si el registro sólo supiera contestar de lo nuevo, no serviría
// de nada el primer día. La mayor parte se puede reconstruir mirando los datos.
//
// Lo que hay que sostener:
//
// - **No se inventa.** Lo que no encaja en ningún camino sale como «no consta»,
//   que es información: esa etiqueta es justo la que se está buscando.
// - **El orden de los caminos.** Una etiqueta puede ser a la vez la de la
//   plataforma y madre de otra; lo que explica de dónde salió es lo primero.
// - **Se dice de quién viene.** «Heredada» a secas no sirve para nada;
//   «heredada de Miraculous» dice qué mirar.

import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_log_entry_entity.dart';
import 'package:Fern/features/media/domain/services/tag_log_guess.dart';
import 'package:flutter_test/flutter_test.dart';

TagEntity _tag(
  int id,
  String name, {
  List<TagEntity> children = const [],
  List<TagEntity> siblings = const [],
  List<String> sourceUrls = const [],
  List<String> nsfwSourceUrls = const [],
}) =>
    TagEntity(
      id: id,
      name: name,
      children: children,
      siblings: siblings,
      sourceUrls: sourceUrls,
      nsfwSourceUrls: nsfwSourceUrls,
    );

Map<String, TagLogEntryEntity> _guess(
  List<TagEntity> tags, {
  List<String> urls = const [],
  TagEntity? platform,
  Map<int, String> byFernie = const {},
}) {
  final entries = guessTagLog(
    mediaId: 1,
    tags: tags,
    at: DateTime(2026),
    mediaUrls: urls,
    platformTag: platform,
    byFernie: byFernie,
  );

  return {for (final entry in entries) entry.label: entry};
}

void main() {
  group('de dónde sale cada una', () {
    test('la de la plataforma se reconoce', () {
      final reddit = _tag(1, 'Reddit');

      expect(
        _guess([reddit], platform: reddit)['Reddit']?.reason,
        TagLogReason.platform,
      );
    });

    test('la que casa con una dirección del contenido', () {
      final tag = _tag(1, 'Ladybug', sourceUrls: ['reddit.com/r/ladybug']);

      final entry = _guess(
        [tag],
        urls: ['reddit.com/r/ladybug/comments/abc'],
      )['Ladybug'];

      expect(entry?.reason, TagLogReason.sourceUrl);
    });

    // Esconder una dirección es no enseñarla, no dejar de etiquetar por ella.
    test('y también si la dirección está marcada', () {
      final tag = _tag(1, 'Ladybug', nsfwSourceUrls: ['reddit.com/r/ladybug']);

      expect(
        _guess([tag], urls: ['reddit.com/r/ladybug'])['Ladybug']?.reason,
        TagLogReason.sourceUrl,
      );
    });

    test('la que está por encima de otra que también tiene', () {
      final rombo = _tag(2, 'Rombo');
      final figuras = _tag(1, 'Figuras', children: [rombo]);

      final entry = _guess([figuras, rombo])['Figuras'];

      expect(entry?.reason, TagLogReason.ancestor);
      expect(entry?.detail, 'Rombo');
    });

    test('y a cualquier profundidad', () {
      final simple = _tag(3, 'Rombo simple');
      final rombo = _tag(2, 'Rombo', children: [simple]);
      final figuras = _tag(1, 'Figuras', children: [rombo]);

      expect(
        _guess([figuras, simple])['Figuras']?.reason,
        TagLogReason.ancestor,
      );
    });

    test('la hermana de otra que tiene', () {
      final rombo = _tag(2, 'Rombo');
      final cuadrado = _tag(1, 'Cuadrado', siblings: [rombo]);

      final entry = _guess([cuadrado, rombo])['Cuadrado'];

      expect(entry?.reason, TagLogReason.sibling);
      expect(entry?.detail, 'Rombo');
    });

    test('la que enlaza un fernie marcado, con su nombre', () {
      final tag = _tag(1, 'Marinette');

      final entry = _guess([tag], byFernie: {1: 'Marinette'})['Marinette'];

      expect(entry?.reason, TagLogReason.fernie);
      expect(entry?.detail, 'Marinette');
    });

    // No inventarse nada es lo que hace útil a esto: una etiqueta sin
    // explicación es exactamente la que se está buscando al abrir el registro.
    test('y la que no encaja en ninguno sale sin explicación', () {
      expect(
        _guess([_tag(1, 'Suelta')])['Suelta']?.reason,
        TagLogReason.unknown,
      );
    });
  });

  group('cuando encajan varias', () {
    // Lo que explica de dónde salió es lo primero: la de la plataforma llegó por
    // ser la plataforma, aunque además tenga hijas puestas.
    test('manda la plataforma sobre la herencia', () {
      final rombo = _tag(2, 'Rombo');
      final reddit = _tag(1, 'Reddit', children: [rombo]);

      expect(
        _guess([reddit, rombo], platform: reddit)['Reddit']?.reason,
        TagLogReason.platform,
      );
    });

    test('y la dirección sobre el fernie', () {
      final tag = _tag(1, 'Ladybug', sourceUrls: ['reddit.com/r/ladybug']);

      expect(
        _guess([tag], urls: ['reddit.com/r/ladybug'], byFernie: {1: 'Lady'})[
                'Ladybug']
            ?.reason,
        TagLogReason.sourceUrl,
      );
    });
  });

  group('lo que se mira', () {
    // La madre explica a la hija sólo si la hija está puesta: si no lo está, esa
    // etiqueta no la arrastró nadie y decir que sí sería inventar.
    test('sólo cuenta lo que el contenido tiene de verdad', () {
      final rombo = _tag(2, 'Rombo');
      final figuras = _tag(1, 'Figuras', children: [rombo]);

      expect(
        _guess([figuras])['Figuras']?.reason,
        TagLogReason.unknown,
      );
    });

    test('sin etiquetas no hay nada que deducir', () {
      expect(guessTagLog(mediaId: 1, tags: const [], at: DateTime(2026)),
          isEmpty);
    });

    test('todas salen, encajen o no', () {
      final entries = _guess([_tag(1, 'Una'), _tag(2, 'Otra')]);

      expect(entries.keys, containsAll(['Una', 'Otra']));
    });
  });
}
