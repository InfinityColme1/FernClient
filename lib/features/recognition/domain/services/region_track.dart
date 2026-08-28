import 'dart:ui';

/// Una región marcada en un instante concreto de un contenido que se mueve.
///
/// Es lo mínimo que hace falta para saber por dónde va un fernie a lo largo de
/// un vídeo: dónde estaba y cuándo.
class TrackKeyframe {
  final Rect rect;
  final int frameMs;

  const TrackKeyframe({required this.rect, required this.frameMs});
}

/// El recorrido de un fernie por un contenido que se mueve.
///
/// Las regiones de un mismo fernie en un vídeo no son un montón de rectángulos
/// sueltos: son **el mismo objeto en momentos distintos**. Enseñarlas todas a la
/// vez llena el fotograma de cajas que se pisan y no dice nada; lo que se
/// entiende es una sola caja que va de una a otra según avanza la reproducción.
///
/// De eso se encarga esto. Es una función del tiempo y nada más: sin estado, sin
/// widgets y sin reproductor, para poder comprobarla sin montar nada.
class RegionTrack {
  /// Los momentos marcados, ordenados por instante.
  final List<TrackKeyframe> keyframes;

  RegionTrack(List<TrackKeyframe> keyframes)
      : keyframes = [...keyframes]
          ..sort((a, b) => a.frameMs.compareTo(b.frameMs));

  bool get isEmpty => keyframes.isEmpty;

  /// Dónde está el fernie en [positionMs], o `null` si en ese momento no está.
  ///
  /// Funciona igual que las claves de un vídeo: marcar una región es poner una
  /// clave, y entre dos claves el recorrido se interpola en línea recta para que
  /// la caja acompañe con suavidad a lo que se mueve debajo.
  ///
  /// Fuera de las claves no hay recorrido, y eso es lo importante: antes de la
  /// primera y después de la última el fernie **no se pinta**. Quedarse quieto
  /// en el extremo llenaba el resto del contenido de una caja fija sobre
  /// fotogramas en los que no había nada marcado.
  ///
  /// [toleranceMs] es el margen de los dos extremos, medio fotograma, para que
  /// la primera clave y la última se vean el fotograma entero.
  Rect? rectAt(int positionMs, {int toleranceMs = 0}) {
    if (keyframes.isEmpty) return null;

    if (positionMs < keyframes.first.frameMs - toleranceMs) return null;
    if (positionMs > keyframes.last.frameMs + toleranceMs) return null;

    if (keyframes.length == 1) return keyframes.first.rect;

    if (positionMs <= keyframes.first.frameMs) return keyframes.first.rect;
    if (positionMs >= keyframes.last.frameMs) return keyframes.last.rect;

    for (var index = 0; index < keyframes.length - 1; index++) {
      final from = keyframes[index];
      final to = keyframes[index + 1];

      if (positionMs < from.frameMs || positionMs > to.frameMs) continue;

      final span = to.frameMs - from.frameMs;
      if (span <= 0) return from.rect;

      final t = (positionMs - from.frameMs) / span;
      return Rect.lerp(from.rect, to.rect, t) ?? from.rect;
    }

    return keyframes.last.rect;
  }
}
