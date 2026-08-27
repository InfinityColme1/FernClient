// El tamano de una imagen, leido de su cabecera.
//
// La forma que trae Flutter carga el fichero entero en memoria antes de dejar
// mirar nada: para una foto de veinte megas son veinte megas leidos y tirados
// para quedarse con dos numeros que viven en los primeros cien bytes. Con mil
// trescientos contenidos eso era la mitad de lo que tardaba una importacion.
//
// Lo que se comprueba: que cada formato se lea bien, y —sobre todo— que lo que
// no se entienda devuelva `null` en vez de inventarse un tamano. Un tamano
// inventado no da ningun error: descoloca la rejilla entera y nadie sabe por que.

import 'dart:typed_data';

import 'package:Fern/core/utils/image_header.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un PNG con el tamano que se le diga.
Uint8List png(int width, int height) {
  final bytes = BytesBuilder()
    ..add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
    ..add([0, 0, 0, 13])
    ..add('IHDR'.codeUnits);

  final size = ByteData(8)
    ..setUint32(0, width)
    ..setUint32(4, height);

  bytes.add(size.buffer.asUint8List());
  bytes.add(List.filled(16, 0));

  return bytes.toBytes();
}

/// Un GIF89a.
Uint8List gif(int width, int height) {
  final bytes = BytesBuilder()..add('GIF89a'.codeUnits);

  final size = ByteData(4)
    ..setUint16(0, width, Endian.little)
    ..setUint16(2, height, Endian.little);

  bytes.add(size.buffer.asUint8List());
  bytes.add(List.filled(16, 0));

  return bytes.toBytes();
}

/// Un BMP, cuyo alto puede venir negativo.
Uint8List bmp(int width, int height) {
  final bytes = BytesBuilder()..add('BM'.codeUnits)..add(List.filled(16, 0));

  final size = ByteData(8)
    ..setInt32(0, width, Endian.little)
    ..setInt32(4, height, Endian.little);

  bytes.add(size.buffer.asUint8List());
  bytes.add(List.filled(8, 0));

  return bytes.toBytes();
}

/// Un JPEG con [before] bytes de metadatos por delante del marcador que lleva el
/// tamano. Es lo que hay de verdad: EXIF, perfiles de color y hasta una
/// miniatura entera.
Uint8List jpeg(int width, int height, {int before = 0}) {
  final bytes = BytesBuilder()..add([0xFF, 0xD8]);

  if (before > 0) {
    // Un APP1 del tamano que se pida.
    final length = before + 2;
    bytes.add([0xFF, 0xE1, (length >> 8) & 0xFF, length & 0xFF]);
    bytes.add(List.filled(before, 0));
  }

  final frame = ByteData(9)
    ..setUint8(0, 0xFF)
    ..setUint8(1, 0xC0)
    ..setUint16(2, 17)
    ..setUint8(4, 8)
    ..setUint16(5, height)
    ..setUint16(7, width);

  bytes.add(frame.buffer.asUint8List());
  bytes.add(List.filled(16, 0));

  return bytes.toBytes();
}

/// Un WebP de los tres tipos.
Uint8List webp(String kind, List<int> payload) {
  final bytes = BytesBuilder()
    ..add('RIFF'.codeUnits)
    ..add([0, 0, 0, 0])
    ..add('WEBP'.codeUnits)
    ..add(kind.codeUnits)
    ..add(payload);

  final out = bytes.toBytes();

  return out.length >= 32 ? out : Uint8List.fromList([...out, ...List.filled(32, 0)]);
}

void main() {
  test('PNG', () {
    expect(imageSizeFromHeader(png(1920, 1080)), (width: 1920, height: 1080));
  });

  test('GIF', () {
    expect(imageSizeFromHeader(gif(320, 240)), (width: 320, height: 240));
  });

  test('BMP, con el alto del derecho y del reves', () {
    expect(imageSizeFromHeader(bmp(800, 600)), (width: 800, height: 600));
    expect(imageSizeFromHeader(bmp(800, -600)), (width: 800, height: 600));
  });

  group('JPEG', () {
    test('sin nada delante', () {
      expect(imageSizeFromHeader(jpeg(4000, 3000)), (width: 4000, height: 3000));
    });

    test('con metadatos por delante', () {
      // Saltar de marcador en marcador es lo que lo encuentra: buscar la firma a
      // pelo daria con la de dentro de la miniatura, y el tamano seria el de la
      // miniatura.
      expect(
        imageSizeFromHeader(jpeg(4000, 3000, before: 2000)),
        (width: 4000, height: 3000),
      );
    });

    test('el alto va antes que el ancho, que es como lo escribe', () {
      final size = imageSizeFromHeader(jpeg(100, 500))!;

      expect(size.width, 100);
      expect(size.height, 500);
    });
  });

  group('WebP', () {
    test('el sencillo', () {
      final payload = ByteData(20);
      payload.setUint16(10, 640, Endian.little);
      payload.setUint16(12, 480, Endian.little);

      expect(
        imageSizeFromHeader(webp('VP8 ', payload.buffer.asUint8List())),
        (width: 640, height: 480),
      );
    });

    test('el extendido, que es el de los animados', () {
      final payload = List<int>.filled(20, 0);
      // Tres bytes por medida, y guardadas una menos de lo que miden.
      payload[8] = 255;
      payload[9] = 1;
      payload[11] = 199;
      payload[12] = 0;

      expect(
        imageSizeFromHeader(webp('VP8X', payload)),
        (width: 512, height: 200),
      );
    });
  });

  group('lo que no se entiende', () {
    test('no se inventa nada', () {
      // Un tamano inventado no da ningun error: descoloca la rejilla entera y
      // nadie sabe por que. Mas vale pagar el fichero entero.
      expect(imageSizeFromHeader(Uint8List.fromList(List.filled(64, 7))), isNull);
    });

    test('un fichero cortado tampoco', () {
      expect(imageSizeFromHeader(Uint8List.fromList([0x89, 0x50])), isNull);
      expect(imageSizeFromHeader(png(10, 10).sublist(0, 20)), isNull);
    });

    test('vacio tampoco', () {
      expect(imageSizeFromHeader(Uint8List(0)), isNull);
    });
  });
}
