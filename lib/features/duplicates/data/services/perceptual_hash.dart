import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Los dos hashes de una imagen.
///
/// Se guardan **los dos** porque cubren cosas distintas y juntos ocupan dieciséis
/// bytes por contenido: el dHash aguanta bien los reescalados y el pHash los
/// cambios de brillo y la compresión fuerte. Dos contenidos son candidatos si
/// **cualquiera** de los dos los ve cerca.
@immutable
class PerceptualHashes {
  /// Diferencias entre píxeles vecinos, 64 bits.
  final int dHash;

  /// Coeficientes bajos de la transformada del coseno, 64 bits.
  final int pHash;

  const PerceptualHashes({required this.dHash, required this.pHash});

  @override
  bool operator ==(Object other) =>
      other is PerceptualHashes &&
      other.dHash == dHash &&
      other.pHash == pHash;

  @override
  int get hashCode => Object.hash(dHash, pHash);

  @override
  String toString() => 'PerceptualHashes(d: $dHash, p: $pHash)';
}

/// Cuántos bits cambian de un hash a otro.
///
/// Es la medida de «cuánto se parecen»: cero es la misma imagen y sesenta y
/// cuatro es lo más lejos que pueden estar.
///
/// Va por máscaras y **sin bucle sobre los bits**. No es sólo por velocidad: los
/// enteros de Dart son de 64 bits con signo, y la versión evidente —ir mirando el
/// bit bajo y desplazar— no termina nunca si el desplazamiento arrastra el signo.
/// Eso no se manifiesta como una prueba en rojo sino como la aplicación colgada,
/// que es mucho peor de encontrar. Sin bucle, el peor error posible es un número
/// equivocado.
///
/// Cada paso suma los bits de a pares, luego de a cuatro, de a ocho, y así: al
/// final el byte más bajo lleva la cuenta de los sesenta y cuatro.
int hammingDistance(int one, int other) {
  var bits = one ^ other;

  bits -= (bits >>> 1) & 0x5555555555555555;
  bits = (bits & 0x3333333333333333) + ((bits >>> 2) & 0x3333333333333333);
  bits = (bits + (bits >>> 4)) & 0x0f0f0f0f0f0f0f0f;

  return ((bits * 0x0101010101010101) >>> 56) & 0x7f;
}

/// Los dos hashes de una imagen ya decodificada.
PerceptualHashes hashesOf(img.Image image) => PerceptualHashes(
      dHash: dHashOf(image),
      pHash: pHashOf(image),
    );

/// Los dos hashes de un fichero en memoria, o `null` si no es una imagen.
///
/// Devolver `null` en vez de lanzar es deliberado: en una biblioteca de miles hay
/// ficheros rotos, a medio descargar y con extensión mentida, y que uno de ellos
/// tumbe el escaneo entero es lo peor que podría hacer esto.
PerceptualHashes? hashesOfBytes(Uint8List bytes) {
  if (bytes.isEmpty) return null;

  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    return hashesOf(decoded);
  } on Object {
    return null;
  }
}

/// dHash: cada bit dice si un píxel es más claro que el de su derecha.
///
/// Se reduce a 9×8 y se comparan los ocho pares de cada fila. Lo que mide son
/// **gradientes**, no valores: por eso sobrevive a que alguien reescale la imagen
/// o le cambie el contraste, que mueve todos los valores pero no el orden entre
/// vecinos.
///
/// No hace falta pasar la imagen a grises antes: `luminance` ya da el gris de
/// cada píxel, y hacerlo dos veces es una pasada entera de más por imagen.
int dHashOf(img.Image image) {
  final small = img.copyResize(image, width: 9, height: 8);

  var hash = 0;
  var bit = 0;

  for (var y = 0; y < 8; y++) {
    for (var x = 0; x < 8; x++) {
      final left = small.getPixel(x, y).luminance;
      final right = small.getPixel(x + 1, y).luminance;

      if (left > right) hash |= 1 << bit;

      bit++;
    }
  }

  return hash;
}

/// pHash: los coeficientes de baja frecuencia de la imagen, contra su mediana.
///
/// Se reduce a 32×32, se le aplica la transformada del coseno y se conserva el
/// bloque 8×8 de arriba a la izquierda, que es donde está la **forma** de la
/// imagen; el resto son el detalle fino y el ruido de compresión, que es
/// justamente lo que cambia al guardar en JPEG.
///
/// Se compara con la mediana y no con la media porque la mediana no se mueve
/// aunque un coeficiente se dispare, y así la mitad de los bits queda a cada
/// lado por construcción. Con estas imágenes la media daría casi lo mismo —los
/// coeficientes altos se reparten alrededor de cero—, pero eso es suerte del
/// caso, no una propiedad.
int pHashOf(img.Image image) {
  const size = 32;
  const keep = 8;

  final small = img.copyResize(image, width: size, height: size);

  final values = List.generate(
    size,
    (y) => List.generate(
      size,
      (x) => small.getPixel(x, y).luminance.toDouble(),
      growable: false,
    ),
    growable: false,
  );

  final dct = _dct2d(values, size);

  // El coeficiente (0,0) es el brillo medio de la imagen entera, y es el único
  // que cambia si se le sube el brillo a todo por igual. Se deja fuera de la
  // mediana para que ese brillo no entre en la cuenta; su bit se calcula igual
  // que los demás, que es lo que hace todo el mundo.
  //
  // Comprobado que **no** es lo que sostiene el hash: meterlo dentro apenas
  // mueve la mediana, porque una mediana no se altera por un valor extremo. Se
  // deja fuera por corrección, no porque sin ello se rompiera.
  final low = <double>[
    for (var y = 0; y < keep; y++)
      for (var x = 0; x < keep; x++)
        if (x != 0 || y != 0) dct[y][x],
  ];

  final median = _medianOf(low);

  var hash = 0;
  var bit = 0;

  for (var y = 0; y < keep; y++) {
    for (var x = 0; x < keep; x++) {
      if (dct[y][x] > median) hash |= 1 << bit;

      bit++;
    }
  }

  return hash;
}

/// La transformada del coseno en dos dimensiones.
///
/// Directa, sin ninguna de las factorizaciones rápidas: son 32×32 valores y se
/// calcula una vez por imagen. La tabla de cosenos sí se precalcula, que es lo
/// que convierte un millón de llamadas a `cos` en mil.
List<List<double>> _dct2d(List<List<double>> values, int size) {
  final cosines = List.generate(
    size,
    (u) => List.generate(
      size,
      (x) => math.cos((2 * x + 1) * u * math.pi / (2 * size)),
      growable: false,
    ),
    growable: false,
  );

  // Primero por filas y luego por columnas: la transformada es separable, y
  // hacerlo así son dos pasadas de N³ en vez de una de N⁴.
  final rows = List.generate(
    size,
    (y) => List.generate(
      size,
      (u) {
        var sum = 0.0;
        for (var x = 0; x < size; x++) {
          sum += values[y][x] * cosines[u][x];
        }

        return sum * (u == 0 ? math.sqrt1_2 : 1);
      },
      growable: false,
    ),
    growable: false,
  );

  return List.generate(
    size,
    (v) => List.generate(
      size,
      (u) {
        var sum = 0.0;
        for (var y = 0; y < size; y++) {
          sum += rows[y][u] * cosines[v][y];
        }

        return sum * (v == 0 ? math.sqrt1_2 : 1);
      },
      growable: false,
    ),
    growable: false,
  );
}

double _medianOf(List<double> values) {
  if (values.isEmpty) return 0;

  final sorted = [...values]..sort();
  final middle = sorted.length ~/ 2;

  return sorted.length.isOdd
      ? sorted[middle]
      : (sorted[middle - 1] + sorted[middle]) / 2;
}
