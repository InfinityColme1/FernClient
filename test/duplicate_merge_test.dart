// Elegir qué copia se queda y no perder por el camino lo que hay en las otras.
//
// Es la parte que borra cosas, y lo que se borra se lleva con ello el trabajo
// que alguien hizo encima: las etiquetas puestas a mano, el creador que sólo
// tenía una copia, el corazón, la nota escrita. Todo eso tiene que estar en la
// superviviente **antes** de que las demás se vayan a la papelera, porque
// después ya no hay de dónde sacarlo.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/duplicates/domain/services/duplicate_merge.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:flutter_test/flutter_test.dart';

TagEntity _tag(int id) => TagEntity(id: id, name: 'etiqueta-$id', children: const []);

MediaEntity _media(
  int id, {
  List<TagEntity>? tags,
  CreatorEntity? creator,
  bool isFavorite = false,
  String? description,
}) {
  return MediaEntity(
    id: id,
    path: 'C:/media/$id.jpg',
    downloaded: DateTime(2026),
    creator: creator ?? unknownCreator,
    tags: tags,
    isFavorite: isFavorite,
    description: description,
  );
}

DuplicateCandidate _candidate(
  int id, {
  int? width,
  int? height,
  int? bytes,
  int tags = 0,
  DateTime? downloaded,
}) {
  return DuplicateCandidate(
    mediaId: id,
    width: width,
    height: height,
    sizeInBytes: bytes,
    tagCount: tags,
    downloaded: downloaded,
  );
}

void main() {
  group('cuál se queda', () {
    test('la que tiene más píxeles', () {
      final best = bestCopyOf([
        _candidate(1, width: 640, height: 360, bytes: 900000, tags: 12),
        _candidate(2, width: 1920, height: 1080, bytes: 100),
      ]);

      // Lo que se pierde al quedarse con la pequeña no se recupera; lo que sobra
      // en la grande, sí. Manda por encima del peso y de las etiquetas.
      expect(best?.mediaId, 2);
    });

    test('a igual tamaño, la que pesa más', () {
      final best = bestCopyOf([
        _candidate(1, width: 800, height: 600, bytes: 90000),
        _candidate(2, width: 800, height: 600, bytes: 400000),
      ]);

      expect(best?.mediaId, 2);
    });

    test('a igual imagen, la que ya está etiquetada', () {
      final best = bestCopyOf([
        _candidate(1, width: 800, height: 600, bytes: 1000, tags: 0),
        _candidate(2, width: 800, height: 600, bytes: 1000, tags: 7),
      ]);

      expect(best?.mediaId, 2);
    });

    test('y si todo empata, la más antigua', () {
      final best = bestCopyOf([
        _candidate(1, width: 800, height: 600, downloaded: DateTime(2026, 8)),
        _candidate(2, width: 800, height: 600, downloaded: DateTime(2024, 1)),
      ]);

      // Es la que aparece en lo que el usuario recuerde de ella.
      expect(best?.mediaId, 2);
    });

    test('con todo igual propone siempre la misma', () {
      final copies = [_candidate(9), _candidate(3), _candidate(7)];

      // Dos ejecuciones sobre el mismo grupo no pueden proponer cosas distintas.
      expect(bestCopyOf(copies)?.mediaId, 3);
      expect(bestCopyOf(copies.reversed.toList())?.mediaId, 3);
    });

    test('sin copias no hay ninguna', () {
      expect(bestCopyOf(const []), isNull);
    });

    test('sin datos de imagen no revienta', () {
      // Pasa con un fichero que no se pudo medir: se elige igual, por lo demás.
      expect(bestCopyOf([_candidate(5), _candidate(2)])?.mediaId, 2);
    });
  });

  group('qué se lleva la que se queda', () {
    test('las etiquetas de las otras', () {
      final keeper = _media(1, tags: [_tag(10)]);
      final other = _media(2, tags: [_tag(20), _tag(30)]);

      final merged = mergeInto(keeper, [other]);

      expect([for (final tag in merged.tags!) tag.id]..sort(), [10, 20, 30]);
    });

    test('sin repetir las que ya tenía', () {
      final keeper = _media(1, tags: [_tag(10), _tag(20)]);
      final other = _media(2, tags: [_tag(20)]);

      expect(mergeInto(keeper, [other]).tags, hasLength(2));
    });

    test('no pierde las suyas', () {
      final keeper = _media(1, tags: [_tag(10)]);
      final other = _media(2, tags: const []);

      // Fusionar sólo suma. Que la otra no tenga nada no puede vaciar ésta.
      expect(mergeInto(keeper, [other]).tags, hasLength(1));
    });

    test('el creador, si ella no lo tenía', () {
      final rin = CreatorEntity(id: 5, name: 'Rin');

      final keeper = _media(1);
      final other = _media(2, creator: rin);

      // «Unknown» no es un creador: es no haberlo puesto. El que sí está lo puso
      // alguien a mano.
      expect(mergeInto(keeper, [other]).creator.name, 'Rin');
    });

    test('pero no le cambia el que ya tenía', () {
      final rin = CreatorEntity(id: 5, name: 'Rin');
      final otro = CreatorEntity(id: 6, name: 'Nil');

      final keeper = _media(1, creator: rin);
      final other = _media(2, creator: otro);

      expect(mergeInto(keeper, [other]).creator.name, 'Rin');
    });

    test('el favorito, si lo era alguna', () {
      final keeper = _media(1);
      final other = _media(2, isFavorite: true);

      // Marcar un favorito es una decisión, y perderla por elegir la copia
      // equivocada es perderla del todo.
      expect(mergeInto(keeper, [other]).isFavorite, isTrue);
    });

    test('y no lo quita si ya lo era', () {
      final keeper = _media(1, isFavorite: true);
      final other = _media(2);

      expect(mergeInto(keeper, [other]).isFavorite, isTrue);
    });
  });

  group('las descripciones', () {
    test('la de la otra, si ella no tenía', () {
      final merged = mergeInto(_media(1), [_media(2, description: 'de la web')]);

      expect(merged.description, 'de la web');
    });

    test('las dos, si las dos tenían', () {
      final keeper = _media(1, description: 'la mía');
      final other = _media(2, description: 'la suya');

      // Son notas que escribió alguien: elegir una es tirar la otra, y eso no se
      // recupera. Limpiarlo después es un momento.
      expect(mergeInto(keeper, [other]).description, 'la mía\nla suya');
    });

    test('la misma dos veces no se repite', () {
      final keeper = _media(1, description: 'igual');
      final other = _media(2, description: '  igual  ');

      expect(mergeInto(keeper, [other]).description, 'igual');
    });

    test('sin ninguna se queda sin ninguna', () {
      expect(mergeInto(_media(1), [_media(2)]).description, isNull);
    });

    test('una vacía no cuenta', () {
      final keeper = _media(1, description: 'la mía');
      final other = _media(2, description: '   ');

      expect(mergeInto(keeper, [other]).description, 'la mía');
    });
  });

  group('sin nada que fusionar', () {
    test('la copia se queda como estaba', () {
      final keeper = _media(1, tags: [_tag(10)], description: 'nota');

      expect(mergeInto(keeper, const []), same(keeper));
    });
  });
}
