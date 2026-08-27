import 'dart:typed_data';

/// Lo que mide una imagen, leído de su cabecera.
typedef ImageSize = ({int width, int height});

/// Saca el tamaño de una imagen de los primeros bytes del fichero.
///
/// **Por qué existe.** La rejilla necesita saber lo que mide cada contenido para
/// colocarlo, y la forma que trae Flutter (`ImmutableBuffer.fromFilePath`)
/// **carga el fichero entero en memoria** antes de dejar mirar nada. Para una
/// foto de veinte megas eso son veinte megas leídos y tirados para quedarse con
/// dos números que viven en los primeros cien bytes. Con mil trescientos
/// contenidos, ésa era la mitad de lo que tardaba una importación y todo lo que
/// costaba la primera vuelta por la biblioteca.
///
/// Aquí se leen esos cien bytes. Los formatos que se entienden son los que
/// aparecen: PNG, JPEG, GIF, WebP y BMP. Lo que no se reconozca devuelve `null`
/// y quien llame que lo pregunte por las malas — no se adivina nada, que un
/// tamaño inventado descoloca la rejilla entera.
ImageSize? imageSizeFromHeader(Uint8List bytes) {
  if (bytes.length < 16) return null;

  return _png(bytes) ?? _gif(bytes) ?? _webp(bytes) ?? _bmp(bytes) ?? _jpeg(bytes);
}

/// PNG: firma de ocho bytes y, justo después, la cabecera `IHDR` con el ancho y
/// el alto en cuatro bytes cada uno. Es el más fácil y el más común.
ImageSize? _png(Uint8List bytes) {
  const signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

  for (var i = 0; i < signature.length; i++) {
    if (bytes[i] != signature[i]) return null;
  }

  if (bytes.length < 24) return null;

  final data = ByteData.sublistView(bytes);

  return (width: data.getUint32(16), height: data.getUint32(20));
}

/// GIF: `GIF87a` o `GIF89a` y luego dos enteros de dos bytes, del revés.
ImageSize? _gif(Uint8List bytes) {
  if (bytes[0] != 0x47 || bytes[1] != 0x49 || bytes[2] != 0x46) return null;
  if (bytes.length < 10) return null;

  final data = ByteData.sublistView(bytes);

  return (
    width: data.getUint16(6, Endian.little),
    height: data.getUint16(8, Endian.little),
  );
}

/// WebP: un contenedor RIFF con tres variantes dentro, y cada una guarda el
/// tamaño en un sitio distinto. Se entienden las tres porque las tres se usan.
ImageSize? _webp(Uint8List bytes) {
  if (bytes.length < 30) return null;

  final isRiff = bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46;
  final isWebp = bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50;
  if (!isRiff || !isWebp) return null;

  final data = ByteData.sublistView(bytes);
  final kind = String.fromCharCodes(bytes.sublist(12, 16));

  // El sencillo: catorce bytes de cabecera y luego el tamaño en catorce bits.
  if (kind == 'VP8 ') {
    if (bytes.length < 30) return null;

    return (
      width: data.getUint16(26, Endian.little) & 0x3FFF,
      height: data.getUint16(28, Endian.little) & 0x3FFF,
    );
  }

  // El sin pérdida: los dos tamaños empaquetados en catorce bits cada uno,
  // menos uno, dentro de cuatro bytes seguidos.
  if (kind == 'VP8L') {
    if (bytes.length < 25) return null;

    final packed = data.getUint32(21, Endian.little);

    return (
      width: (packed & 0x3FFF) + 1,
      height: ((packed >> 14) & 0x3FFF) + 1,
    );
  }

  // El extendido, que es el de los animados: tres bytes por medida, menos uno.
  if (kind == 'VP8X') {
    if (bytes.length < 30) return null;

    return (
      width: (bytes[24] | (bytes[25] << 8) | (bytes[26] << 16)) + 1,
      height: (bytes[27] | (bytes[28] << 8) | (bytes[29] << 16)) + 1,
    );
  }

  return null;
}

/// BMP: `BM` y, en la cabecera de información, dos enteros con signo. El alto
/// puede venir negativo, que sólo quiere decir que las filas van al revés.
ImageSize? _bmp(Uint8List bytes) {
  if (bytes[0] != 0x42 || bytes[1] != 0x4D) return null;
  if (bytes.length < 26) return null;

  final data = ByteData.sublistView(bytes);

  return (
    width: data.getInt32(18, Endian.little).abs(),
    height: data.getInt32(22, Endian.little).abs(),
  );
}

/// JPEG: hay que recorrer sus marcadores hasta dar con el del principio de
/// fotograma, que es el que lleva el tamaño.
///
/// No está a una distancia fija: delante suele haber metadatos, y a veces una
/// miniatura entera. Por eso esto salta de marcador en marcador leyendo cuánto
/// ocupa cada uno, en vez de buscar la firma a pelo — buscarla encontraría la de
/// dentro de la miniatura, y entonces el tamaño sería el de la miniatura.
ImageSize? _jpeg(Uint8List bytes) {
  if (bytes[0] != 0xFF || bytes[1] != 0xD8) return null;

  final data = ByteData.sublistView(bytes);
  var at = 2;

  while (at + 9 < bytes.length) {
    if (bytes[at] != 0xFF) {
      at++;
      continue;
    }

    final marker = bytes[at + 1];

    // Relleno entre marcadores, y los que no llevan nada detrás.
    if (marker == 0xFF) {
      at++;
      continue;
    }
    if (marker == 0x01 || (marker >= 0xD0 && marker <= 0xD9)) {
      at += 2;
      continue;
    }

    final length = data.getUint16(at + 2);
    if (length < 2) return null;

    // Los de principio de fotograma: todos menos los cuatro que no lo son
    // aunque caigan en el mismo rango.
    final isFrameStart = marker >= 0xC0 &&
        marker <= 0xCF &&
        marker != 0xC4 &&
        marker != 0xC8 &&
        marker != 0xCC;

    if (isFrameStart) {
      if (at + 9 >= bytes.length) return null;

      return (
        // Primero el alto y luego el ancho, en ese orden.
        height: data.getUint16(at + 5),
        width: data.getUint16(at + 7),
      );
    }

    at += 2 + length;
  }

  return null;
}
