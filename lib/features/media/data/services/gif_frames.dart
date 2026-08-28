import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Los fotogramas de un GIF, ya sueltos y con su reloj.
///
/// Existe porque marcar regiones sobre un GIF pide poder pararlo en un fotograma
/// concreto, y eso no lo da ni `Image.file` (que lo anima solo, sin mando) ni el
/// reproductor de vídeo (que con un GIF se queda en el primer fotograma). La
/// única forma de tener control de verdad es abrirlo nosotros.
@immutable
class GifFrames {
  /// Cada fotograma ya codificado en PNG, listo para `Image.memory`.
  final List<Uint8List> frames;

  /// Cuándo empieza cada fotograma, contando desde el principio.
  final List<Duration> starts;

  /// Lo que dura el GIF entero.
  final Duration total;

  const GifFrames({
    required this.frames,
    required this.starts,
    required this.total,
  });

  bool get isEmpty => frames.isEmpty;

  int get length => frames.length;

  /// Qué fotograma toca en [position].
  ///
  /// Los fotogramas de un GIF no duran todos lo mismo, así que no vale con
  /// dividir: hay que buscar en qué tramo cae.
  int indexAt(Duration position) {
    if (frames.isEmpty) return 0;

    for (var index = starts.length - 1; index >= 0; index--) {
      if (position >= starts[index]) return index;
    }

    return 0;
  }

  /// Abre el GIF de [path] y devuelve sus fotogramas.
  ///
  /// Va en otro hilo porque descodificar un GIF largo bloquea el dibujado, que
  /// es justo lo que no se puede permitir un visor. Devuelve `null` si el
  /// fichero no es un GIF animado que se pueda abrir; quien lo pida decide qué
  /// hacer con eso.
  static Future<GifFrames?> load(String path) {
    return compute(_decode, path);
  }
}

/// Lo que corre en el otro hilo.
///
/// Cada fotograma sale ya compuesto sobre el anterior (el decodificador se
/// encarga de las transparencias y de los GIF que sólo guardan lo que cambia),
/// así que se pueden pintar sueltos y en cualquier orden.
GifFrames? _decode(String path) {
  try {
    final bytes = File(path).readAsBytesSync();
    final decoded = img.decodeGif(bytes);

    if (decoded == null || decoded.frames.length < 2) return null;

    final frames = <Uint8List>[];
    final starts = <Duration>[];
    var elapsed = Duration.zero;

    for (final frame in decoded.frames) {
      frames.add(img.encodePng(frame));
      starts.add(elapsed);

      // Un GIF puede declarar cero: los navegadores lo tratan como el mínimo
      // razonable en vez de como «instantáneo», y aquí se hace lo mismo.
      final duration = frame.frameDuration <= 0
          ? _minimumFrameDuration
          : Duration(milliseconds: frame.frameDuration);

      elapsed += duration;
    }

    return GifFrames(frames: frames, starts: starts, total: elapsed);
  } catch (error) {
    debugPrint('GifFrames: no se pudo abrir "$path": $error');
    return null;
  }
}

/// Lo que se le da a un fotograma que dice durar cero.
const _minimumFrameDuration = Duration(milliseconds: 100);
