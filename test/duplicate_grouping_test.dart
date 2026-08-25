// Juntar lo que parece el mismo contenido.
//
// Es la parte que decide qué acaba delante del usuario para que elija cuál
// borrar, así que los dos errores posibles cuestan cosas distintas: agrupar de
// menos deja duplicados sin encontrar —molesto—, y agrupar de más pone en la
// misma pantalla dos imágenes que no tienen nada que ver, con un botón que manda
// una de ellas a la papelera. Por eso se comprueban las dos direcciones.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/duplicates/data/services/perceptual_hash.dart';
import 'package:Fern/features/duplicates/domain/services/duplicate_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un contenido con el hash que se le diga, el mismo en los dos.
HashedMedia _media(int id, int hash) =>
    HashedMedia(mediaId: id, dHash: hash, pHash: hash);

/// El mismo hash con [bits] bits cambiados, repartidos por todo el número.
///
/// Repartidos y no seguidos a propósito: seguidos caerían todos en el mismo
/// bloque de dieciséis bits y dejarían los otros tres intactos, que es el caso
/// más fácil para el reparto en bloques y el que menos se parece a la realidad.
int _flip(int hash, int bits) {
  var result = hash;

  for (var i = 0; i < bits; i++) {
    result ^= 1 << (i * 7 % 64);
  }

  return result;
}

void main() {
  group('qué se junta', () {
    test('dos copias idénticas', () {
      final groups = groupDuplicates([_media(1, 0x1234), _media(2, 0x1234)]);

      expect(groups.single.mediaIds, [1, 2]);
      expect(groups.single.maxDistance, 0);
    });

    test('dos copias parecidas', () {
      const hash = 0x0f1e2d3c4b5a6978;
      final groups = groupDuplicates([
        _media(1, hash),
        _media(2, _flip(hash, 3)),
      ]);

      expect(groups.single.mediaIds, [1, 2]);
      expect(groups.single.maxDistance, 3);
    });

    test('lo que está justo en el listón entra', () {
      const hash = 0x0f1e2d3c4b5a6978;
      final groups = groupDuplicates(
        [_media(1, hash), _media(2, _flip(hash, defaultDuplicateThreshold))],
        threshold: defaultDuplicateThreshold,
      );

      expect(groups, hasLength(1));
    });

    test('lo que se pasa por uno se queda fuera', () {
      const hash = 0x0f1e2d3c4b5a6978;
      final groups = groupDuplicates(
        [_media(1, hash), _media(2, _flip(hash, defaultDuplicateThreshold + 1))],
        threshold: defaultDuplicateThreshold,
      );

      expect(groups, isEmpty);
    });

    test('basta con que lo vea uno de los dos hashes', () {
      // Una copia reescalada la reconoce el dHash aunque el pHash la vea lejos;
      // una con el brillo cambiado, al revés. Guardar los dos no sirve de nada si
      // luego se exige que coincidan los dos.
      final groups = groupDuplicates([
        const HashedMedia(mediaId: 1, dHash: 0x1234, pHash: 0x0),
        HashedMedia(mediaId: 2, dHash: 0x1234, pHash: _flip(0, 40)),
      ]);

      expect(groups.single.mediaIds, [1, 2]);
    });
  });

  group('qué no se junta', () {
    test('dos contenidos que no se parecen', () {
      final groups = groupDuplicates([
        _media(1, 0x0000000000000000),
        _media(2, -1),
      ]);

      expect(groups, isEmpty);
    });

    test('un solo contenido no es un grupo', () {
      expect(groupDuplicates([_media(1, 0x1234)]), isEmpty);
    });

    test('sin nada, nada', () {
      expect(groupDuplicates(const []), isEmpty);
    });

    test('lo que no se parece a nadie se queda fuera del grupo', () {
      final groups = groupDuplicates([
        _media(1, 0x1234),
        _media(2, 0x1234),
        _media(3, -1),
      ]);

      expect(groups.single.mediaIds, [1, 2]);
    });
  });

  group('cadenas de copias', () {
    test('si A se parece a B y B a C, van los tres juntos', () {
      const hash = 0x0f1e2d3c4b5a6978;

      final groups = groupDuplicates([
        _media(1, hash),
        _media(2, _flip(hash, 5)),
        _media(3, _flip(_flip(hash, 5), 5)),
      ]);

      // Son la misma imagen pasando por copias sucesivas: separarlas obligaría a
      // decidir dos veces sobre lo mismo.
      expect(groups.single.mediaIds, [1, 2, 3]);
    });

    test('la distancia del grupo es la mayor que hay dentro', () {
      const hash = 0x0f1e2d3c4b5a6978;

      final groups = groupDuplicates([
        _media(1, hash),
        _media(2, _flip(hash, 2)),
        _media(3, _flip(hash, 6)),
      ]);

      expect(groups.single.maxDistance, 6);
    });

    test('dos grupos distintos no se mezclan', () {
      const one = 0x0f1e2d3c4b5a6978;
      const other = -1 ^ 0x0f1e2d3c4b5a6978;

      final groups = groupDuplicates([
        _media(1, one),
        _media(2, _flip(one, 2)),
        _media(3, other),
        _media(4, _flip(other, 2)),
      ]);

      expect(groups, hasLength(2));
      expect(groups.map((one) => one.mediaIds), [
        [1, 2],
        [3, 4],
      ]);
    });
  });

  group('el orden', () {
    test('lo idéntico va primero', () {
      const hash = 0x0f1e2d3c4b5a6978;
      const other = -1 ^ 0x0f1e2d3c4b5a6978;

      final groups = groupDuplicates([
        _media(1, hash),
        _media(2, _flip(hash, 6)),
        _media(3, other),
        _media(4, other),
      ]);

      // Primero lo que se decide sin pensar.
      expect(groups.first.maxDistance, 0);
      expect(groups.last.maxDistance, 6);
    });

    test('los contenidos de un grupo van ordenados', () {
      final groups = groupDuplicates([
        _media(9, 0x1234),
        _media(3, 0x1234),
        _media(7, 0x1234),
      ]);

      // Dos escaneos del mismo material tienen que dar exactamente lo mismo.
      expect(groups.single.mediaIds, [3, 7, 9]);
    });
  });

  group('lo lejos que están', () {
    // Un grupo en cadena: A con B y B con C, pero A y C lejos. Contando sólo los
    // pares emparejados pasaba por casi idéntico y la pantalla lo ponía el
    // primero, entre los que se deciden sin mirar. Lo que hay que mirar con
    // calma es justo lo lejos que están los dos extremos.
    test('se mide entre los dos extremos, no entre los emparejados', () {
      // Bits disjuntos: A y B se separan por los cinco primeros, B y C por los
      // cinco siguientes. Así A y C están a diez, que es más que el listón, y
      // sólo llegan al mismo grupo por la cadena.
      const a = 0;
      const b = 0x1f; // cinco bits bajos
      const c = 0x3ff; // esos cinco y cinco más

      final groups = groupDuplicates(
        [_media(1, a), _media(2, b), _media(3, c)],
        threshold: 6,
      );

      expect(groups.single.mediaIds, [1, 2, 3]);
      expect(groups.single.maxDistance, 10);
    });

    test('con dos copias es la distancia entre ellas', () {
      final groups = groupDuplicates(
        [_media(1, 0), _media(2, _flip(0, 4))],
        threshold: 8,
      );

      expect(groups.single.maxDistance, 4);
    });
  });

  group('con muchos contenidos', () {
    /// Veinte mil hashes repartidos, con veinte parejas escondidas.
    List<HashedMedia> library() {
      final media = <HashedMedia>[];

      for (var id = 0; id < 20000; id++) {
        // Números bien repartidos por los 64 bits: dos ids consecutivos no
        // pueden salir parecidos por accidente.
        final hash = (id * 0x9e3779b97f4a7c15) ^ (id << 32);
        media.add(_media(id, hash));
      }

      for (var i = 0; i < 20; i++) {
        final source = media[i * 500];
        media.add(HashedMedia(
          mediaId: 100000 + i,
          dHash: _flip(source.dHash, 3),
          pHash: _flip(source.pHash, 3),
        ));
      }

      return media;
    }

    test('encuentra las parejas escondidas', () {
      final groups = groupDuplicates(library(), threshold: 3);

      expect(groups, hasLength(20));
      for (final group in groups) {
        expect(group.mediaIds, hasLength(2));
      }
    });

    test('con listón bajo, el reparto en bloques lo deja en un paseo', () {
      final media = library();
      final clock = Stopwatch()..start();

      groupDuplicates(media, threshold: 3);
      clock.stop();

      // Compararlos todos contra todos serían doscientos millones de pares. Si
      // esto tarda segundos, es que el atajo ha dejado de funcionar.
      expect(clock.elapsed, lessThan(const Duration(seconds: 5)));
    });

    // Con el listón de fábrica el atajo no vale —ocho diferencias se reparten en
    // los cuatro bloques sin dejar ninguno limpio— y se compara todo contra
    // todo. Este es el camino que la aplicación toma de verdad, y la prueba
    // anterior no lo medía: durante un tiempo el único número que teníamos era
    // el del camino que nadie recorre.
    test('con el listón de fábrica sigue siendo cosa de segundos', () {
      final media = library();
      final clock = Stopwatch()..start();

      groupDuplicates(media, threshold: defaultDuplicateThreshold);
      clock.stop();

      // Holgado a propósito: lo que vigila es que no se dispare a minutos, no
      // los milisegundos que dé una máquina concreta. Y por eso agrupar corre en
      // otro hilo: veinte mil contenidos son segundos, y cincuenta mil, más.
      expect(clock.elapsed, lessThan(const Duration(seconds: 30)));
    });

    // El atajo es exacto, no aproximado. Si se saltara un par dejaría duplicados
    // sin encontrar y nadie se enteraría, así que la prueba busca los pares por
    // su cuenta, a lo bruto, y exige que estén todos.
    test('el atajo no se salta ni un par', () {
      final media = library();
      const threshold = 3;

      final expected = <String>{};
      for (var a = 0; a < media.length; a++) {
        for (var b = a + 1; b < media.length; b++) {
          final byD = hammingDistance(media[a].dHash, media[b].dHash);
          final byP = hammingDistance(media[a].pHash, media[b].pHash);

          if (byD <= threshold || byP <= threshold) {
            expected.add(([media[a].mediaId, media[b].mediaId]..sort()).join('-'));
          }
        }
      }

      final found = <String>{};
      for (final group in groupDuplicates(media, threshold: threshold)) {
        for (var i = 0; i < group.mediaIds.length; i++) {
          for (var j = i + 1; j < group.mediaIds.length; j++) {
            found.add('${group.mediaIds[i]}-${group.mediaIds[j]}');
          }
        }
      }

      expect(expected.difference(found), isEmpty);
    });
  });
}
