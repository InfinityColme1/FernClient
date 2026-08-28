// De dónde salen los bytes que se comparan de cada contenido.
//
// Lo que se prueba aquí no es sacar el fotograma —eso es abrir el fichero con
// libmpv, esperar, saltar y capturar— sino lo de alrededor: qué instante se
// pide, qué se hace cuando el vídeo no se deja leer, y que una imagen no acabe
// pasando por el reproductor.

import 'dart:typed_data';

import 'package:Fern/features/duplicates/data/services/video_frame_reader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final bytes = Uint8List.fromList([1, 2, 3]);

  group('el instante que representa a un vídeo', () {
    test('es el 10 % de su duración', () {
      expect(
        hashedMomentOf(const Duration(minutes: 10)),
        const Duration(minutes: 1),
      );
    });

    // El primer fotograma es negro, una carátula o un logotipo. Tres vídeos que
    // empiezan en negro dan el mismo hash y salen agrupados como si fueran el
    // mismo, que es la peor forma de fallar que tiene esto.
    test('nunca es el principio', () {
      expect(hashedMomentOf(const Duration(seconds: 1)), isNot(Duration.zero));
    });

    test('un vídeo de milisegundos no se va a cero', () {
      expect(
        hashedMomentOf(const Duration(milliseconds: 40)),
        const Duration(milliseconds: 4),
      );
    });
  });

  group('los bytes de un vídeo', () {
    /// Un lector con las respuestas ya puestas.
    VideoFrameReader reader({
      Duration? duration,
      String? framePath,
      List<Duration>? asked,
      Uint8List? content,
    }) {
      return VideoFrameReader(
        duration: (_) async => duration,
        frameAt: (_, moment) async {
          asked?.add(moment);

          return framePath;
        },
        read: (_) async => content ?? bytes,
      );
    }

    test('son los del fotograma del 10 %', () async {
      final asked = <Duration>[];
      final subject = reader(
        duration: const Duration(seconds: 100),
        framePath: 'C:/cache/frame.jpg',
        asked: asked,
      );

      expect(await subject.bytesOf('C:/uno.mp4'), bytes);
      expect(asked, [const Duration(seconds: 10)]);
    });

    // Un fichero que no dice cuánto dura es uno que no se ha podido abrir.
    // Capturar de él el instante cero daría un fotograma negro, y el negro es
    // el hash que agruparía entre sí a todo lo que no se pudo leer.
    test('sin duración no se saca nada', () async {
      final subject = reader(framePath: 'C:/cache/frame.jpg');

      expect(await subject.bytesOf('C:/roto.mp4'), isNull);
    });

    test('una duración de cero tampoco cuenta', () async {
      final subject = reader(
        duration: Duration.zero,
        framePath: 'C:/cache/frame.jpg',
      );

      expect(await subject.bytesOf('C:/vacio.mp4'), isNull);
    });

    test('un fotograma que no se pudo sacar no rompe nada', () async {
      final subject = reader(duration: const Duration(seconds: 30));

      expect(await subject.bytesOf('C:/uno.mp4'), isNull);
    });
  });

  group('a quién le toca cada fichero', () {
    late List<String> asImage;
    late List<String> asVideo;

    setUp(() {
      asImage = [];
      asVideo = [];
    });

    Future<Uint8List?> Function(String) reader() => hashableBytesReader(
          VideoFrameReader(
            duration: (path) async {
              asVideo.add(path);

              return const Duration(seconds: 10);
            },
            frameAt: (_, _) async => 'C:/cache/frame.jpg',
            read: (_) async => bytes,
          ),
          image: (path) async {
            asImage.add(path);

            return bytes;
          },
        );

    test('un vídeo pasa por el reproductor', () async {
      await reader()('C:/uno.mp4');

      expect(asVideo, ['C:/uno.mp4']);
      expect(asImage, isEmpty);
    });

    // Un GIF es una imagen: el decodificador se queda con su primer fotograma,
    // que es la imagen entera y no un negro de cabecera. Mandarlo al
    // reproductor sería pagar una apertura de fichero por nada.
    test('un GIF se lee como cualquier imagen', () async {
      await reader()('C:/uno.gif');

      expect(asImage, ['C:/uno.gif']);
      expect(asVideo, isEmpty);
    });

    test('una imagen también', () async {
      await reader()('C:/uno.jpg');

      expect(asImage, ['C:/uno.jpg']);
      expect(asVideo, isEmpty);
    });

    test('la extensión no distingue mayúsculas', () async {
      await reader()('C:/UNO.MP4');

      expect(asVideo, ['C:/UNO.MP4']);
    });
  });
}
