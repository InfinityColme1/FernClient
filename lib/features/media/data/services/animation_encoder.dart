import 'dart:isolate';
import 'dart:typed_data';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:archive/archive.dart';
import 'package:image/image.dart' as img;

/// Monta una animación a partir de un paquete de fotogramas sueltos.
///
/// Hay plataformas que no sirven sus animaciones como un vídeo sino como un zip
/// de imágenes más el tiempo que dura cada una (Pixiv llama a las suyas
/// *ugoira*). Tal cual no hay nada que la aplicación pueda reproducir, así que
/// se junta aquí en un fichero que sí: un GIF, que es lo único que se puede
/// escribir sin arrastrar un codificador de vídeo entero.
///
/// No sabe de ninguna plataforma en concreto, y por eso vale para todas: recibe
/// el zip y los tiempos, y devuelve el fichero. De dónde salieron es cosa de
/// quien lo llame.
class AnimationEncoder {
  const AnimationEncoder();

  /// El GIF que sale de [zip], o `null` si dentro no había ningún fotograma que
  /// se pudiera leer.
  ///
  /// [delays] es lo que dura cada fotograma en milisegundos, en el mismo orden
  /// en el que van dentro del zip. Los que falten duran
  /// [defaultAnimationFrameDelay].
  ///
  /// El trabajo se hace en otro hilo: juntar decenas de fotogramas lleva su
  /// tiempo, y hacerlo en el de la interfaz la dejaría parada mientras dura la
  /// importación.
  Future<Uint8List?> gifFromZip(
    Uint8List zip, {
    List<int> delays = const [],
  }) {
    return Isolate.run(() => _encode(zip, delays));
  }

  /// El montaje en sí, ya en el otro hilo.
  ///
  /// Los fotogramas se ordenan por su nombre porque es el orden en el que van:
  /// las plataformas los numeran, y dentro del zip pueden venir de cualquier
  /// manera.
  ///
  /// Un fotograma que no se deje leer se salta en lugar de perder la animación
  /// entera; sólo cuando no queda ninguno se da por perdida.
  static Uint8List? _encode(Uint8List zip, List<int> delays) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zip);
    } on Exception {
      return null;
    }

    final files = archive.files.where((file) => file.isFile).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final encoder = img.GifEncoder();
    var frames = 0;

    for (var i = 0; i < files.length; i++) {
      final bytes = files[i].readBytes();
      if (bytes == null) continue;

      // Lo que no sea una imagen no siempre se reconoce como tal: hay formatos
      // que el lector da por buenos por sus primeros bytes y revientan al
      // seguir. Un fotograma ilegible se salta igual, venga como venga.
      final img.Image? frame;
      try {
        frame = img.decodeImage(bytes);
      } on Object {
        continue;
      }
      if (frame == null) continue;

      final delay = i < delays.length ? delays[i] : defaultAnimationFrameDelay;

      // El GIF cuenta el tiempo en centésimas de segundo, y un fotograma no
      // puede durar cero: eso deja la animación parada en muchos visores.
      encoder.addFrame(
        _fit(frame),
        duration: (delay / 10).round().clamp(1, 65535),
      );
      frames++;
    }

    return frames == 0 ? null : encoder.finish();
  }

  /// Deja el fotograma en un tamaño que valga la pena guardar.
  ///
  /// Se mide por el ancho y se guarda la proporción, así que todos los
  /// fotogramas de una animación acaban del mismo tamaño, que es lo que el
  /// formato exige.
  static img.Image _fit(img.Image frame) {
    if (frame.width <= maxAnimationFrameWidth) return frame;

    return img.copyResize(frame, width: maxAnimationFrameWidth);
  }
}
