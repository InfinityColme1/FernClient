// Lo que se enseña de cada copia al compararlas.
//
// Aquí no se decide nada nuevo: la heurística ya está probada aparte. Lo que se
// comprueba es que la pantalla le da los datos correctos —y que el tamaño y el
// peso, que salen del fichero y no de la base, llegan hasta ella—, porque
// pasarle el dato equivocado hace que se preseleccione la copia que no toca y
// que la otra acabe en la papelera sin que nadie lo mire.

import 'package:Fern/features/duplicates/domain/services/duplicate_detail.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:flutter_test/flutter_test.dart';

MediaEntity _media(int id, {List<TagEntity>? tags, DateTime? downloaded}) =>
    MediaEntity(
      id: id,
      path: 'C:/$id.jpg',
      downloaded: downloaded ?? DateTime(2026),
      creator: const CreatorEntity(id: 1, name: 'Unknown'),
      tags: tags,
    );

DuplicateCopy _copy(
  int id, {
  int? width,
  int? height,
  int? bytes,
  List<TagEntity>? tags,
  DateTime? downloaded,
}) =>
    DuplicateCopy(
      media: _media(id, tags: tags, downloaded: downloaded),
      width: width,
      height: height,
      sizeInBytes: bytes,
    );

void main() {
  group('lo que sabe una copia', () {
    test('cuenta las etiquetas que tiene', () {
      final copy = _copy(1, tags: [
        TagEntity(id: 1, name: 'una', children: []),
        TagEntity(id: 2, name: 'otra', children: []),
      ]);

      expect(copy.tagCount, 2);
      expect(copy.candidate.tagCount, 2);
    });

    test('sin etiquetas son cero, no un fallo', () {
      expect(_copy(1).tagCount, 0);
    });

    test('el tamaño y el peso llegan a la heurística', () {
      final copy = _copy(1, width: 1920, height: 1080, bytes: 2400000);

      expect(copy.candidate.pixels, 1920 * 1080);
      expect(copy.candidate.sizeInBytes, 2400000);
    });

    test('un fichero que no se pudo leer dice que no sabe su tamaño', () {
      expect(_copy(1).hasSize, isFalse);
      expect(_copy(1, width: 100, height: 100).hasSize, isTrue);
    });

    test('la fecha que cuenta es la de la descarga', () {
      final copy = _copy(1, downloaded: DateTime(2020, 3, 12));

      expect(copy.candidate.downloaded, DateTime(2020, 3, 12));
    });
  });

  group('la copia que viene marcada', () {
    test('la de más píxeles', () {
      final keeper = preselectedKeeper([
        _copy(1, width: 640, height: 360),
        _copy(2, width: 1920, height: 1080),
      ]);

      expect(keeper, 2);
    });

    test('sin copias no hay ninguna marcada', () {
      expect(preselectedKeeper(const []), isNull);
    });

    test('con todo empatado sale siempre la misma', () {
      final copies = [_copy(9), _copy(3), _copy(7)];

      // Abrir dos veces el mismo grupo no puede proponer cosas distintas.
      expect(preselectedKeeper(copies), 3);
      expect(preselectedKeeper(copies.reversed.toList()), 3);
    });
  });

  _ordenDeGrupos();

  group('lo que se descarta', () {
    test('todas menos la que se conserva', () {
      final discarded = discardedOf([_copy(1), _copy(2), _copy(3)], 2);

      expect(discarded.map((one) => one.id), [1, 3]);
    });

    test('sin elegir ninguna no se descarta a ciegas', () {
      // Es lo que impide que «aplicar» sin haber elegido mande el grupo entero
      // a la papelera.
      expect(discardedOf([_copy(1), _copy(2)], null), hasLength(2));
    });

    test('si la elegida no está, no se toca nada de más', () {
      final discarded = discardedOf([_copy(1), _copy(2)], 99);

      expect(discarded, hasLength(2));
    });
  });
}

// Añadido con el encadenado de grupos.
void _ordenDeGrupos() {
  group('a qué grupo se salta', () {
    test('al que ocupa el sitio del resuelto', () {
      // Volver arriba cada vez obliga a buscar por dónde se iba, y al final se
      // abandona la revisión a la mitad.
      expect(nextGroupId([1, 2, 3], 2), 3);
    });

    test('si era el último, al anterior', () {
      expect(nextGroupId([1, 2, 3], 3), 2);
    });

    test('si era el único, no hay siguiente', () {
      expect(nextGroupId([1], 1), isNull);
    });

    test('sin grupos no hay siguiente', () {
      expect(nextGroupId(const [], 1), isNull);
    });

    test('si el resuelto ya no estaba, se abre el primero', () {
      expect(nextGroupId([4, 5], 99), 4);
    });
  });
}
