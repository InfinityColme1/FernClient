// Qué contenidos hay que mirar en un escaneo.
//
// Es lo que hace que los escaneos sean incrementales, y con ello lo que hace que
// la función sea usable: la primera pasada sobre una biblioteca grande cuesta lo
// que cuesta, pero si las siguientes repitieran el trabajo entero no habría
// manera de dejar el escaneo automático puesto.

import 'package:Fern/features/duplicates/domain/services/hashing_plan.dart';
import 'package:flutter_test/flutter_test.dart';

HashableMedia _media(
  int id, {
  DateTime? hashedAt,
  DateTime? modifiedAt,
}) {
  return HashableMedia(
    mediaId: id,
    path: 'C:/media/$id.jpg',
    hashedAt: hashedAt,
    fileModifiedAt: modifiedAt,
  );
}

void main() {
  final ayer = DateTime(2026, 8, 22);
  final hoy = DateTime(2026, 8, 23);

  group('qué hay que mirar', () {
    test('lo que nunca se ha mirado', () {
      expect(needsHashing(_media(1)), isTrue);
    });

    test('lo que ha cambiado desde que se miró', () {
      // Pasa de verdad: la aplicación mueve ficheros a la carpeta de la
      // biblioteca, y hay quien edita una imagen y la guarda encima. Un hash de
      // una imagen que ya no existe agrupa cosas que no se parecen.
      expect(
        needsHashing(_media(1, hashedAt: ayer, modifiedAt: hoy)),
        isTrue,
      );
    });
  });

  group('qué no', () {
    test('lo que ya se miró y sigue igual', () {
      expect(
        needsHashing(_media(1, hashedAt: hoy, modifiedAt: ayer)),
        isFalse,
      );
    });

    test('lo que se miró y del fichero no se sabe nada', () {
      // El fichero ya no está o no se pudo leer su estado. Rehacerlo no sirve de
      // nada: tampoco se va a poder leer para hashearlo.
      expect(needsHashing(_media(1, hashedAt: hoy)), isFalse);
    });

    test('lo tocado en el mismo instante no cuenta como cambiado', () {
      expect(
        needsHashing(_media(1, hashedAt: hoy, modifiedAt: hoy)),
        isFalse,
      );
    });
  });

  group('en qué orden', () {
    test('lo que nunca se miró va primero', () {
      final pending = pendingToHash([
        _media(1, hashedAt: ayer, modifiedAt: hoy),
        _media(2),
        _media(3, hashedAt: ayer, modifiedAt: hoy),
        _media(4),
      ]);

      // Un escaneo se puede cancelar a la mitad, y lo que más aporta es lo que
      // todavía no tiene hash: sin él, un contenido nuevo no aparece en ningún
      // grupo. El que cambió ya está en la comparación, aunque sea con el viejo.
      expect([for (final one in pending) one.mediaId], [2, 4, 1, 3]);
    });

    test('lo que no hay que mirar se queda fuera', () {
      final pending = pendingToHash([
        _media(1, hashedAt: hoy, modifiedAt: ayer),
        _media(2),
      ]);

      expect([for (final one in pending) one.mediaId], [2]);
    });

    test('sin nada pendiente, la lista queda vacía', () {
      expect(pendingToHash([_media(1, hashedAt: hoy)]), isEmpty);
    });

    test('sin contenidos, nada', () {
      expect(pendingToHash(const []), isEmpty);
    });
  });
}
