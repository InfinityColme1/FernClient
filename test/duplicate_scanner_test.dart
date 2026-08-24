// El recorrido que le calcula los hashes a la biblioteca.
//
// Lo que importa aquí no es el hash —eso ya tiene sus pruebas— sino cómo se
// comporta el recorrido: que no repita trabajo, que un fichero roto no se lleve
// por delante a los demás, que se pueda parar, y que diga por dónde va.

import 'dart:typed_data';

import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/services/jobs/job_runner.dart';
import 'package:Fern/features/duplicates/data/services/duplicate_scanner.dart';
import 'package:Fern/features/duplicates/data/services/perceptual_hash.dart';
import 'package:Fern/features/duplicates/domain/services/hashing_plan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

HashableMedia _media(int id, {DateTime? hashedAt, DateTime? modifiedAt}) {
  return HashableMedia(
    mediaId: id,
    path: 'C:/media/$id.jpg',
    hashedAt: hashedAt,
    fileModifiedAt: modifiedAt,
  );
}

/// Un PNG de verdad, para que el hash tenga algo que decodificar.
Uint8List _png(int seed) {
  final image = img.Image(width: 32, height: 32);

  img.fill(image, color: img.ColorRgb8(seed * 7 % 256, 40, 200));
  img.fillCircle(
    image,
    x: 8 + seed % 8,
    y: 16,
    radius: 6,
    color: img.ColorRgb8(250, 250, 250),
  );

  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  late List<String> read;
  late Map<int, PerceptualHashes> written;

  setUp(() {
    read = [];
    written = {};
  });

  DuplicateScanner scanner({
    Set<String> broken = const {},
    Set<String> missing = const {},
    Set<String> unreadable = const {},
  }) {
    return DuplicateScanner(
      read: (path) async {
        read.add(path);

        if (unreadable.contains(path)) throw StateError('no se puede leer');
        if (missing.contains(path)) return null;
        if (broken.contains(path)) return Uint8List.fromList([1, 2, 3]);

        return _png(path.length);
      },
      write: (mediaId, hashes) async => written[mediaId] = hashes,
    );
  }

  group('a quién mira', () {
    test('a lo que no tiene hash', () async {
      final hashed = await scanner().hashPending([_media(1), _media(2)]);

      expect(hashed, 2);
      expect(written.keys, [1, 2]);
    });

    test('no repite lo ya hecho', () async {
      final hoy = DateTime(2026, 8, 23);

      await scanner().hashPending([
        _media(1, hashedAt: hoy, modifiedAt: DateTime(2026, 8, 1)),
        _media(2),
      ]);

      // Es lo que hace que el segundo escaneo sea casi instantáneo. Sin esto no
      // habría manera de dejar el automático puesto.
      expect(written.keys, [2]);
      expect(read, ['C:/media/2.jpg']);
    });

    test('sin nada pendiente no lee nada', () async {
      final hashed = await scanner().hashPending([
        _media(1, hashedAt: DateTime(2026, 8, 23)),
      ]);

      expect(hashed, 0);
      expect(read, isEmpty);
    });

    test('sin contenidos, nada', () async {
      expect(await scanner().hashPending(const []), 0);
    });
  });

  group('lo que sale mal', () {
    test('un fichero roto no para el escaneo', () async {
      final hashed = await scanner(broken: {'C:/media/2.jpg'})
          .hashPending([_media(1), _media(2), _media(3)]);

      // En una biblioteca de miles hay ficheros corruptos y formatos raros: que
      // uno deje sin hashear los otros novecientos noventa y nueve es lo peor que
      // podría hacer esto.
      expect(hashed, 2);
      expect(written.keys, [1, 3]);
    });

    test('un fichero que revienta al leerse tampoco', () async {
      // Un disco que se desconecta a media faena, un permiso que cambia: lo que
      // lanza al leer no puede llevarse por delante el resto del escaneo.
      final hashed = await scanner(unreadable: {'C:/media/2.jpg'})
          .hashPending([_media(1), _media(2), _media(3)]);

      expect(hashed, 2);
      expect(written.keys, [1, 3]);
    });

    test('un fichero que ya no está tampoco', () async {
      final hashed = await scanner(missing: {'C:/media/1.jpg'})
          .hashPending([_media(1), _media(2)]);

      expect(hashed, 1);
      expect(written.keys, [2]);
    });

    test('lo que falla no se apunta como hasheado', () async {
      await scanner(broken: {'C:/media/1.jpg'}).hashPending([_media(1)]);

      // Apuntarlo dejaría el contenido fuera del siguiente escaneo para siempre,
      // sin hash y sin que nadie lo vuelva a intentar.
      expect(written, isEmpty);
    });
  });

  group('cómo se porta', () {
    test('dice por dónde va', () async {
      final progress = <(int, int)>[];

      await scanner().hashPending(
        [_media(1), _media(2), _media(3)],
        onProgress: (done, total) => progress.add((done, total)),
      );

      expect(progress, [(1, 3), (2, 3), (3, 3)]);
    });

    test('el avance cuenta también lo que falló', () async {
      final progress = <int>[];

      await scanner(broken: {'C:/media/2.jpg'}).hashPending(
        [_media(1), _media(2), _media(3)],
        onProgress: (done, _) => progress.add(done),
      );

      // La barra mide lo que queda por mirar, no lo que salió bien: si se
      // saltara los fallos parecería que se ha quedado atascada.
      expect(progress, [1, 2, 3]);
    });

    test('se puede parar', () async {
      final token = CancellationToken();

      await expectLater(
        scanner().hashPending(
          [_media(1), _media(2), _media(3)],
          token: token,
          onProgress: (done, _) {
            if (done == 1) token.cancel();
          },
        ),
        throwsA(isA<JobCancelledException>()),
      );

      // Lo hecho hasta ahí se queda hecho: el siguiente escaneo sigue por donde
      // se dejó en vez de empezar de cero.
      expect(written.keys, [1]);
    });
  });
}
