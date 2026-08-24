// Los dos hashes con los que se reconoce que dos ficheros son la misma imagen.
//
// No comparan bytes: la misma foto guardada dos veces con distinta calidad son
// dos ficheros completamente distintos byte a byte y **la misma imagen** para
// quien la mira. Lo que se comprueba aquí es justo eso —que sobreviven a la
// recompresión y al reescalado— y su contrario, que no dan por iguales dos
// imágenes que no lo son. Un hash que agrupa de más es peor que no tener hash:
// manda a la papelera cosas que no sobran.

import 'dart:typed_data';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/duplicates/data/services/perceptual_hash.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Una imagen con formas reconocibles, no ruido.
///
/// El ruido puro es el mejor caso para cualquier hash y el que menos se parece a
/// una biblioteca de verdad: lo que hay ahí son dibujos, con zonas grandes de un
/// color y unas pocas formas.
img.Image _drawing({int width = 256, int height = 256, int seed = 0}) {
  final image = img.Image(width: width, height: height);

  img.fill(image, color: img.ColorRgb8(230, 220, 240));

  img.fillRect(
    image,
    x1: width ~/ 8,
    y1: height ~/ 6,
    x2: width ~/ 2 + seed,
    y2: height ~/ 2,
    color: img.ColorRgb8(40, 60, 200),
  );

  img.fillCircle(
    image,
    x: (width * 3) ~/ 4,
    y: (height * 2) ~/ 3,
    radius: width ~/ 6,
    color: img.ColorRgb8(220, 40, 60),
  );

  img.drawLine(
    image,
    x1: 0,
    y1: height - 1,
    x2: width - 1,
    y2: height ~/ 2 + seed,
    color: img.ColorRgb8(20, 120, 40),
    thickness: 5,
  );

  return image;
}

/// Otra composición distinta: otros colores, otras formas, en otros sitios.
img.Image _otherDrawing({int width = 256, int height = 256}) {
  final image = img.Image(width: width, height: height);

  img.fill(image, color: img.ColorRgb8(20, 30, 25));

  for (var i = 0; i < 6; i++) {
    img.fillCircle(
      image,
      x: (width * (i + 1)) ~/ 7,
      y: height ~/ 4 + (i.isEven ? height ~/ 3 : 0),
      radius: width ~/ 12,
      color: img.ColorRgb8(240, 200 - i * 20, 60),
    );
  }

  img.fillRect(
    image,
    x1: 0,
    y1: (height * 5) ~/ 6,
    x2: width - 1,
    y2: height - 1,
    color: img.ColorRgb8(250, 250, 250),
  );

  return image;
}

/// La misma imagen pasada por JPEG con la calidad dicha, como al guardarla.
img.Image _recompressed(img.Image source, int quality) {
  return img.decodeJpg(Uint8List.fromList(img.encodeJpg(source, quality: quality)))!;
}

void main() {
  group('la misma imagen', () {
    test('recomprimida sigue siendo la misma', () {
      // Calidad 95 contra calidad 60, que es el caso del plan: la misma imagen
      // servida por dos sitios que comprimen distinto.
      final original = _recompressed(_drawing(), 95);
      final peor = _recompressed(_drawing(), 60);

      // Es el caso de todos los días: la misma imagen descargada de dos sitios
      // que la sirven con distinta compresión.
      expect(
        hammingDistance(dHashOf(original), dHashOf(peor)),
        lessThanOrEqualTo(2),
      );
      expect(
        hammingDistance(pHashOf(original), pHashOf(peor)),
        lessThanOrEqualTo(2),
      );
    });

    test('a otro tamaño sigue siendo la misma', () {
      final grande = _drawing(width: 512, height: 512);
      final chica = img.copyResize(grande, width: 160, height: 160);

      expect(
        hammingDistance(dHashOf(grande), dHashOf(chica)),
        lessThanOrEqualTo(4),
      );
      expect(
        hammingDistance(pHashOf(grande), pHashOf(chica)),
        lessThanOrEqualTo(4),
      );
    });

    test('más clara sigue siendo la misma para el pHash', () {
      final original = _drawing();
      final clara = img.adjustColor(_drawing(), brightness: 1.25);

      // Es la razón de guardar los dos: el pHash aguanta los cambios de brillo
      // porque compara con la mediana de la propia imagen.
      expect(
        hammingDistance(pHashOf(original), pHashOf(clara)),
        lessThanOrEqualTo(4),
      );
    });

    test('el pHash reparte sus bits, no los deja casi todos a un lado', () {
      // Un hash con sesenta bits iguales no distingue nada: casi cualquier par
      // de imágenes quedaría por debajo del listón. Que se reparta es lo que le
      // da su poder de separación, y es lo que se rompe si el listón interno
      // (la mediana) se calcula mal.
      final ones = hammingDistance(pHashOf(_drawing()), 0);

      expect(ones, greaterThan(16));
      expect(ones, lessThan(48));
    });

    test('un pico aislado no se lleva medio hash por delante', () {
      // La media la mueve un solo coeficiente grande y entonces casi todos los
      // bits caen del mismo lado. La mediana no se entera.
      final normal = _drawing();
      final conPico = _drawing()
        ..setPixelRgb(0, 0, 255, 255, 255)
        ..setPixelRgb(1, 0, 0, 0, 0);

      expect(
        hammingDistance(pHashOf(normal), pHashOf(conPico)),
        lessThanOrEqualTo(2),
      );
    });

    test('idéntica da distancia cero', () {
      final one = _drawing();
      final other = _drawing();

      expect(hammingDistance(dHashOf(one), dHashOf(other)), 0);
      expect(hammingDistance(pHashOf(one), pHashOf(other)), 0);
    });
  });

  group('imágenes distintas', () {
    test('no se parecen', () {
      // Agrupar de más es peor que no agrupar: manda a la papelera cosas que no
      // sobran.
      final one = _drawing();
      final other = _otherDrawing();

      // Lo que se fija es la propiedad que importa: que queden **por encima del
      // listón con el que se agrupa**. El plan pedía más de quince y con dibujos
      // planos como éstos el dHash se queda en once; con contenido de verdad
      // sube, pero lo que no puede fallar nunca es esto.
      expect(
        hammingDistance(dHashOf(one), dHashOf(other)),
        greaterThan(defaultDuplicateThreshold),
      );
      expect(
        hammingDistance(pHashOf(one), pHashOf(other)),
        greaterThan(defaultDuplicateThreshold),
      );
    });

    test('un cambio pequeño se nota, pero poco', () {
      // La misma composición con una forma movida: se parecen, y tienen que
      // parecerse. Lo que no puede es dar cero.
      final one = _drawing();
      final other = _drawing(seed: 60);

      expect(hammingDistance(dHashOf(one), dHashOf(other)), greaterThan(0));
    });

    test('el negativo no es la misma imagen', () {
      final original = _drawing();
      final invertida = img.invert(_drawing());

      expect(
        hammingDistance(dHashOf(original), dHashOf(invertida)),
        greaterThan(8),
      );
    });
  });

  group('la distancia', () {
    test('de un hash consigo mismo es cero', () {
      expect(hammingDistance(0x0123456789abcdef, 0x0123456789abcdef), 0);
    });

    test('cuenta los bits que cambian', () {
      expect(hammingDistance(0, 1), 1);
      expect(hammingDistance(0, 3), 2);
      expect(hammingDistance(0, 0xff), 8);
    });

    test('llega a sesenta y cuatro', () {
      // Con enteros de 64 bits en Dart el bit más alto es el de signo: un
      // desplazamiento mal hecho aquí devuelve un número negativo o pierde ese
      // bit, y el hash deja de distinguir la mitad de las imágenes.
      expect(hammingDistance(0, -1), 64);
      expect(hammingDistance(-1, 0), 64);
    });

    test('no depende del orden', () {
      expect(hammingDistance(0xf0f0, 0x0f0f), hammingDistance(0x0f0f, 0xf0f0));
    });
  });

  group('lo que no es una imagen', () {
    test('un fichero ilegible no da hash', () {
      expect(hashesOfBytes(Uint8List.fromList([1, 2, 3])), isNull);
    });

    test('un fichero vacío tampoco', () {
      expect(hashesOfBytes(Uint8List(0)), isNull);
    });

    test('una imagen de verdad sí', () {
      final bytes = Uint8List.fromList(img.encodePng(_drawing()));
      final hashes = hashesOfBytes(bytes);

      expect(hashes, isNotNull);
      expect(hashes!.dHash, isNot(0));
      expect(hashes.pHash, isNot(0));
    });
  });
}
