// Comprueba que un GIF se puede recorrer fotograma a fotograma.
//
// Marcar regiones sobre un GIF pide poder pararlo en un fotograma concreto, y
// eso no lo da ni `Image.file` (que lo anima solo, sin mando) ni el reproductor
// de video. Aqui se comprueba lo unico que hace falta para el mando: que se sabe
// cuando empieza cada fotograma y cual toca en cada momento.

import 'dart:io';
import 'dart:typed_data';

import 'package:Fern/features/media/data/services/gif_frames.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Un GIF de tres fotogramas con duraciones distintas, escrito a disco.
///
/// Las duraciones no son iguales a proposito: un GIF real tampoco las tiene, y
/// es lo que impide resolver el fotograma dividiendo.
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

  setUp(() {
    directory = Directory.systemTemp.createTempSync('fern_gif_test');
  });

  tearDown(() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  test('un GIF animado se abre con sus fotogramas y su reloj', () async {
    final path = _writeGif(directory, [100, 200, 100]);

    final frames = await GifFrames.load(path);

    expect(frames, isNotNull);
    expect(frames!.length, 3);
    expect(frames.isEmpty, isFalse);

    // Cada fotograma empieza donde termina el anterior.
    expect(frames.starts[0], Duration.zero);
    expect(frames.starts[1], const Duration(milliseconds: 100));
    expect(frames.starts[2], const Duration(milliseconds: 300));
    expect(frames.total, const Duration(milliseconds: 400));
  });

  test('el fotograma que toca sale de en que tramo cae la posicion', () async {
    final path = _writeGif(directory, [100, 200, 100]);
    final frames = (await GifFrames.load(path))!;

    expect(frames.indexAt(Duration.zero), 0);
    expect(frames.indexAt(const Duration(milliseconds: 99)), 0);
    expect(frames.indexAt(const Duration(milliseconds: 100)), 1);

    // El segundo dura el doble: sigue siendo el suyo bien pasado el corte del
    // primero, que es lo que se perderia dividiendo por una duracion media.
    expect(frames.indexAt(const Duration(milliseconds: 299)), 1);
    expect(frames.indexAt(const Duration(milliseconds: 300)), 2);
    expect(frames.indexAt(const Duration(seconds: 99)), 2);
  });

  test('lo que no es un GIF animado no se abre', () async {
    final path = p.join(directory.path, 'no_es.gif');
    File(path).writeAsBytesSync(Uint8List.fromList([1, 2, 3]));

    expect(await GifFrames.load(path), isNull);
  });

  test('un GIF de un solo fotograma no tiene nada que recorrer', () async {
    final path = _writeGif(directory, [100]);

    // Con un fotograma no hay linea de tiempo que enseñar: se trata como una
    // imagen y se pinta como siempre.
    expect(await GifFrames.load(path), isNull);
  });
}
