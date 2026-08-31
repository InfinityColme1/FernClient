import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

/// Lo que sale de recortar: los bytes ya codificados y con qué extensión hay que
/// escribirlos.
typedef CroppedImage = ({Uint8List bytes, String extension});

/// Recorta [bytes] al rectángulo normalizado [rect].
///
/// Devuelve `null` si la imagen no se puede descodificar o si el recorte se
/// queda en nada. Quien lo pide decide qué hacer entonces: aquí no se puede
/// saber si lo correcto es avisar o seguir con la imagen entera.
///
/// Va en otro hilo porque descodificar y volver a codificar una imagen grande
/// son cientos de milisegundos, y esto se pide desde un diálogo abierto: en el
/// hilo de la interfaz sería la ventana congelada justo al confirmar.
Future<CroppedImage?> cropImageBytes(Uint8List bytes, Rect rect) =>
    Isolate.run(() => cropImageSync(bytes, rect));

/// Lo mismo, en el hilo de quien llama. Es lo que se prueba.
CroppedImage? cropImageSync(Uint8List bytes, Rect rect) {
  // Descodificar se protege entero y no sólo se mira el resultado: lo que no es
  // una imagen no siempre devuelve nulo, hay formatos que revientan leyendo la
  // cabecera. Un fichero corrupto no puede tumbar el guardado de un avatar.
  img.Image? decoded;
  try {
    decoded = img.decodeImage(bytes);
  } on Object {
    return null;
  }

  if (decoded == null) return null;

  // El rectángulo llega normalizado —de 0 a 1— así que vale igual para el
  // fichero original que para la miniatura sobre la que se marcó.
  final left = (rect.left * decoded.width).round();
  final top = (rect.top * decoded.height).round();
  final width = (rect.width * decoded.width).round();
  final height = (rect.height * decoded.height).round();

  // Un píxel de ancho es lo mínimo que se puede escribir; por debajo no hay
  // imagen que devolver.
  if (width < 1 || height < 1) return null;

  final cropped = img.copyCrop(
    decoded,
    x: left.clamp(0, decoded.width - 1),
    y: top.clamp(0, decoded.height - 1),
    // El recorte no puede pasarse del borde: el rectángulo se marcó sobre lo
    // pintado y el redondeo a píxeles puede sacarlo por un punto.
    width: width.clamp(1, decoded.width - left.clamp(0, decoded.width - 1)),
    height: height.clamp(1, decoded.height - top.clamp(0, decoded.height - 1)),
  );

  // **PNG y no siempre JPEG**: el recorte puede venir de un PNG con
  // transparencia, y volcarlo a JPEG le pondría un fondo negro que nadie ha
  // pedido. Lo que ya era JPEG se queda en JPEG: pasarlo a PNG multiplicaría por
  // varias veces el tamaño de una foto sin ganar nada.
  return decoded.hasAlpha
      ? (bytes: img.encodePng(cropped), extension: '.png')
      : (bytes: img.encodeJpg(cropped, quality: 90), extension: '.jpg');
}
