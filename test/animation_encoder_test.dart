// El montaje de animaciones a partir de un paquete de fotogramas.
//
// Es lo que hace que las obras animadas de Pixiv (y las de cualquier otra
// plataforma que las sirva así) acaben siendo un fichero que la aplicación
// puede enseñar. Lo que importa aquí es que salgan todos los fotogramas, en su
// orden y con su tiempo, y que un paquete que no vale no tumbe la importación.

import 'dart:typed_data';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/services/animation_encoder.dart';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Una imagen de un color, de las que se guardan dentro del paquete.
Uint8List frame(int red, {int size = 4}) {
  final image = img.Image(width: size, height: size);
  img.fill(image, color: img.ColorRgb8(red, 0, 0));

  return img.encodePng(image);
}

/// Un paquete de fotogramas como el que sirven las plataformas: imágenes
/// numeradas, y nada más.
Uint8List zipOf(Map<String, Uint8List> files) {
  final archive = Archive();
  for (final entry in files.entries) {
    archive.add(ArchiveFile.bytes(entry.key, entry.value));
  }

  return Uint8List.fromList(ZipEncoder().encode(archive));
}

void main() {
  const encoder = AnimationEncoder();

  group('el montaje de una animación', () {
    test('saca un fotograma por imagen del paquete', () async {
      final gif = await encoder.gifFromZip(
        zipOf({
          '000000.png': frame(10),
          '000001.png': frame(120),
          '000002.png': frame(240),
        }),
        delays: const [100, 100, 100],
      );

      final animation = img.decodeGif(gif!);
      expect(animation!.numFrames, 3);
    });

    test('cada fotograma dura lo que dice la plataforma', () async {
      final gif = await encoder.gifFromZip(
        zipOf({'000000.png': frame(10), '000001.png': frame(200)}),
        delays: const [120, 80],
      );

      final animation = img.decodeGif(gif!);
      expect(
        animation!.frames.map((each) => each.frameDuration),
        [120, 80],
      );
    });

    test('van en el orden de sus nombres, no en el que trae el paquete',
        () async {
      final gif = await encoder.gifFromZip(
        zipOf({
          '000002.png': frame(240),
          '000000.png': frame(10),
          '000001.png': frame(120),
        }),
        delays: const [10, 500, 990],
      );

      final animation = img.decodeGif(gif!);
      // Los tiempos se reparten por el orden bueno, así que si salen en él es
      // que los fotogramas también.
      expect(
        animation!.frames.map((each) => each.frameDuration),
        [10, 500, 990],
      );
    });

    test('un fotograma sin tiempo dura lo de por defecto', () async {
      final gif = await encoder.gifFromZip(
        zipOf({'000000.png': frame(10), '000001.png': frame(200)}),
        delays: const [50],
      );

      final animation = img.decodeGif(gif!);
      expect(animation!.frames.last.frameDuration, defaultAnimationFrameDelay);
    });

    test('una imagen que no se deja leer se salta, y las demás siguen',
        () async {
      final gif = await encoder.gifFromZip(
        zipOf({
          '000000.png': frame(10),
          '000001.png': Uint8List.fromList([1, 2, 3]),
          '000002.png': frame(240),
        }),
      );

      final animation = img.decodeGif(gif!);
      expect(animation!.numFrames, 2);
    });

    test('un paquete sin nada que leer no da fichero', () async {
      expect(await encoder.gifFromZip(zipOf({})), isNull);
      expect(
        await encoder.gifFromZip(zipOf({'000000.png': Uint8List(4)})),
        isNull,
      );
    });

    test('lo que ni siquiera es un paquete no tumba la importación', () async {
      expect(
        await encoder.gifFromZip(Uint8List.fromList([1, 2, 3, 4, 5])),
        isNull,
      );
    });
  });
}
