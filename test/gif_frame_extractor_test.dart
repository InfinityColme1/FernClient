// Los fotogramas de un GIF, sacados a disco para que el sidecar los mire.
//
// Un GIF no pasa por el reproductor de vídeo aunque se mueva: se descodifica
// entero en otro hilo y salen todos sus fotogramas de una vez. Aquí se
// comprueba contra ficheros de verdad que lo que llega al reconocimiento son
// **fotogramas distintos**, cada uno con el momento en que empieza.

import 'dart:io';

import 'package:Fern/features/recognition/data/services/gif_frame_extractor.dart';
import 'package:Fern/features/recognition/domain/services/frame_sampling.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Un GIF con [durationsMs.length] fotogramas de colores distintos.
///
/// Los colores importan: son lo que deja comprobar que cada fichero escrito es
/// un fotograma **diferente** y no el mismo tres veces.
String _writeGif(Directory directory, List<int> durationsMs) {
  final animation = <img.Image>[];

  for (var index = 0; index < durationsMs.length; index++) {
    final frame = img.Image(width: 4, height: 4)
      ..frameDuration = durationsMs[index];

    img.fill(frame, color: img.ColorRgb8(index * 80, 0, 0));
    animation.add(frame);
  }

  final first = animation.first;
  for (final frame in animation.skip(1)) {
    first.frames.add(frame);
  }

  final path = p.join(directory.path, 'animado.gif');
  File(path).writeAsBytesSync(img.encodeGif(first));

  return path;
}

void main() {
  late Directory directory;
  late GifFrameExtractor extractor;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('fern_gif_frames');
    PathProviderPlatform.instance = _FakePathProvider(directory.path);
    extractor = GifFrameExtractor();
  });

  tearDown(() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  group('cuánto dura', () {
    test('la suma de sus fotogramas', () async {
      final path = _writeGif(directory, [100, 200, 300]);

      expect(await extractor.durationOf(path),
          const Duration(milliseconds: 600));
    });

    test('lo que no es un GIF animado no dura', () async {
      final path = p.join(directory.path, 'no-es.gif');
      File(path).writeAsBytesSync([1, 2, 3]);

      expect(await extractor.durationOf(path), isNull);
    });
  });

  group('qué sale', () {
    test('un fichero por fotograma distinto', () async {
      final path = _writeGif(directory, [1000, 1000, 1000]);

      final moments = sampleFrames(
        duration: const Duration(seconds: 3),
        count: 5,
      );

      final frames = await extractor.extract(path, moments);

      // Cinco miradas sobre tres fotogramas son tres: mirar dos veces la misma
      // imagen es pagar dos predicciones por una respuesta que ya se tenía.
      expect(frames.length, 3);

      for (final file in frames.values) {
        expect(File(file).existsSync(), isTrue);
      }
    });

    test('cada uno es un fotograma diferente', () async {
      final path = _writeGif(directory, [1000, 1000, 1000]);

      final frames = await extractor.extract(path, [
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 1500),
        const Duration(milliseconds: 2500),
      ]);

      final colors = {
        for (final file in frames.values)
          img.decodePng(File(file).readAsBytesSync())!.getPixel(0, 0).r,
      };

      // Tres ficheros con el mismo contenido serían tres predicciones sobre la
      // misma imagen, que es exactamente lo que esto evita.
      expect(colors.length, 3);
    });

    test('el momento es el de inicio del fotograma', () async {
      final path = _writeGif(directory, [1000, 1000, 1000]);

      final frames = await extractor.extract(path, [
        const Duration(milliseconds: 1700),
      ]);

      // No el que se pidió: lo que se ha mirado empieza en el segundo uno, y es
      // ahí donde hay que apuntar la detección.
      expect(frames.keys.single, const Duration(seconds: 1));
    });

    test('sin momentos no se toca el disco', () async {
      final path = _writeGif(directory, [1000, 1000]);

      expect(await extractor.extract(path, const []), isEmpty);
    });

    test('lo que no es un GIF animado no da nada', () async {
      final path = p.join(directory.path, 'roto.gif');
      File(path).writeAsBytesSync([1, 2, 3]);

      expect(
        await extractor.extract(path, [const Duration(milliseconds: 100)]),
        isEmpty,
      );
    });
  });

  group('no repetir trabajo', () {
    test('pedirlo dos veces no reescribe los ficheros', () async {
      final path = _writeGif(directory, [1000, 1000]);
      final moments = [
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 1500),
      ];

      final first = await extractor.extract(path, moments);

      // Se marcan los ficheros a mano: si la segunda pasada los reescribe, la
      // marca desaparece. Comparar fechas no vale, que dos escrituras seguidas
      // caben en el mismo milisegundo.
      for (final file in first.values) {
        File(file).writeAsStringSync('ya estaba');
      }

      final second = await extractor.extract(path, moments);

      // Reconocer el mismo GIF dos veces no tiene por qué volver a tocar el
      // disco, y la segunda vez tiene que dar exactamente lo mismo.
      expect(second, first);

      for (final file in first.values) {
        expect(File(file).readAsStringSync(), 'ya estaba');
      }
    });
  });
}

class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String path;

  _FakePathProvider(this.path);

  @override
  Future<String?> getTemporaryPath() async => path;
}
