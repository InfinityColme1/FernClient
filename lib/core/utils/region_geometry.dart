import 'dart:math' as math;
import 'package:flutter/rendering.dart';

/// Un rectángulo normalizado sobre un contenido, y el fotograma del que sale.
///
/// Es lo que hace falta para recortar: las coordenadas van de 0 a 1 con el
/// origen en la esquina superior izquierda, así que valen igual para el fichero
/// original que para una miniatura suya, y [frameMs] dice de qué instante hay
/// que sacar la imagen en vídeo y GIF.
class RegionCrop {
  final double x;
  final double y;
  final double w;
  final double h;

  /// Milisegundo del fotograma. `null` en imágenes estáticas.
  final int? frameMs;

  const RegionCrop({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.frameMs,
  });

  RegionCrop.fromRect(Rect rect, {this.frameMs})
      : x = rect.left,
        y = rect.top,
        w = rect.width,
        h = rect.height;

  Rect get rect => Rect.fromLTWH(x, y, w, h);

  /// Proporción ancho/alto de la región dentro de un contenido de [contentSize].
  ///
  /// No es `w / h`: eso serían las proporciones de la región medidas en
  /// fracciones del contenido, que sólo coinciden con las de verdad si el
  /// contenido es cuadrado.
  double aspectRatio(Size contentSize) {
    final width = w * contentSize.width;
    final height = h * contentSize.height;

    if (width <= 0 || height <= 0) return 1;
    return width / height;
  }

  @override
  bool operator ==(Object other) =>
      other is RegionCrop &&
      other.x == x &&
      other.y == y &&
      other.w == w &&
      other.h == h &&
      other.frameMs == frameMs;

  @override
  int get hashCode => Object.hash(x, y, w, h, frameMs);
}

/// Dónde acaba pintado un contenido de [contentSize] dentro de una caja de
/// [boxSize] con `BoxFit.contain`.
///
/// Es la primera de las dos capas que hay que deshacer para saber a qué parte de
/// la imagen corresponde un punto de la pantalla: `contain` deja bandas a los
/// lados o arriba y abajo, y sin descontarlas todo queda desplazado.
Rect containedRect(Size contentSize, Size boxSize) {
  if (contentSize.width <= 0 || contentSize.height <= 0) {
    return Offset.zero & boxSize;
  }

  final scale = math.min(
    boxSize.width / contentSize.width,
    boxSize.height / contentSize.height,
  );

  final width = contentSize.width * scale;
  final height = contentSize.height * scale;

  return Rect.fromLTWH(
    (boxSize.width - width) / 2,
    (boxSize.height - height) / 2,
    width,
    height,
  );
}

/// Deja el rectángulo dentro de [0, 1] en los dos ejes.
///
/// Es el recorte a los bordes de la imagen que pide el modo fernie: se puede
/// arrastrar fuera del contenido, pero lo que se guarda nunca se sale de él.
Rect clampNormalized(Rect rect) {
  final left = rect.left.clamp(0.0, 1.0);
  final top = rect.top.clamp(0.0, 1.0);
  final right = rect.right.clamp(0.0, 1.0);
  final bottom = rect.bottom.clamp(0.0, 1.0);

  return Rect.fromLTRB(
    math.min(left, right),
    math.min(top, bottom),
    math.max(left, right),
    math.max(top, bottom),
  );
}

/// El cuadrado que va de [anchor] hasta donde esté [cursor], sin salirse de
/// [bounds].
///
/// Es lo que se arrastra al recortar un avatar. El cuadrado se impone **aquí y
/// no al soltar**: lo que se pinta mientras se arrastra y lo que sale al final
/// tienen que ser lo mismo, o se elige una cosa y se recorta otra.
///
/// El lado lo manda el eje que más se haya movido, para que el cuadrado siga al
/// ratón por el eje en el que se está tirando en vez de quedarse corto. Y se
/// recorta a lo que quede hasta el borde **en la dirección del arrastre**: pasado
/// ese punto el cuadrado deja de crecer, que es lo único que lo mantiene dentro
/// de la imagen sin deformarlo.
///
/// Va en coordenadas del widget a propósito. Un cuadrado en píxeles de la imagen
/// es un cuadrado en pantalla —el contenido se pinta con una escala igual en los
/// dos ejes—, pero **no** un cuadrado en coordenadas normalizadas: ahí cada eje
/// se mide en fracciones de un lado distinto.
Rect squareBetween(Offset anchor, Offset cursor, {required Rect bounds}) {
  // El principio puede caer fuera si el arrastre empezó sobre una banda: se
  // trae al borde en vez de descartarlo, que es lo que hace que arrastrar desde
  // el margen recorte la esquina en lugar de no hacer nada.
  final start = Offset(
    anchor.dx.clamp(bounds.left, bounds.right),
    anchor.dy.clamp(bounds.top, bounds.bottom),
  );

  final toRight = cursor.dx >= start.dx;
  final toBottom = cursor.dy >= start.dy;

  final room = math.min(
    toRight ? bounds.right - start.dx : start.dx - bounds.left,
    toBottom ? bounds.bottom - start.dy : start.dy - bounds.top,
  );

  final side = math.min(
    math.max((cursor.dx - start.dx).abs(), (cursor.dy - start.dy).abs()),
    math.max(0.0, room),
  );

  return Rect.fromPoints(
    start,
    Offset(
      start.dx + (toRight ? side : -side),
      start.dy + (toBottom ? side : -side),
    ),
  );
}

/// De un rectángulo en coordenadas del widget a coordenadas normalizadas de la
/// imagen original.
///
/// Hay dos capas que deshacer, y equivocarse en cualquiera de las dos guarda las
/// regiones desplazadas sin ningún síntoma visible hasta que el modelo no
/// acierta:
///
/// 1. La matriz del `InteractiveViewer`, que es lo que aplica el zoom y el
///    desplazamiento. Se deshace invirtiéndola.
/// 2. El `BoxFit.contain` con el que se pinta la imagen dentro del widget, que
///    deja bandas. Se deshace con [containedRect].
///
/// El resultado siempre queda dentro de la imagen: lo que se haya arrastrado
/// fuera se recorta a sus bordes.
Rect widgetRectToNormalized(
  Rect widgetRect, {
  required Matrix4 transform,
  required Size widgetSize,
  required Size imageSize,
}) {
  if (imageSize.width <= 0 || imageSize.height <= 0) return Rect.zero;

  final scene = _sceneRect(widgetRect, transform);
  final painted = containedRect(imageSize, widgetSize);

  if (painted.width <= 0 || painted.height <= 0) return Rect.zero;

  final normalized = Rect.fromLTRB(
    (scene.left - painted.left) / painted.width,
    (scene.top - painted.top) / painted.height,
    (scene.right - painted.left) / painted.width,
    (scene.bottom - painted.top) / painted.height,
  );

  return clampNormalized(normalized);
}

/// El camino de vuelta: de coordenadas normalizadas a coordenadas del widget.
///
/// Es lo que necesita el pintado para dibujar encima de la imagen una región que
/// se guardó con otro zoom, con otro tamaño de ventana o incluso en otro equipo.
Rect normalizedRectToWidget(
  Rect normalized, {
  required Matrix4 transform,
  required Size widgetSize,
  required Size imageSize,
}) {
  final painted = containedRect(imageSize, widgetSize);

  final scene = Rect.fromLTRB(
    painted.left + normalized.left * painted.width,
    painted.top + normalized.top * painted.height,
    painted.left + normalized.right * painted.width,
    painted.top + normalized.bottom * painted.height,
  );

  return MatrixUtils.transformRect(transform, scene);
}

/// El rectángulo [widgetRect] visto desde la escena, es decir, deshaciendo el
/// zoom y el desplazamiento.
///
/// Con la matriz sin invertir (que pasa cuando está degenerada, con una escala
/// de cero) se devuelve tal cual: es preferible una región mal puesta que una
/// excepción en mitad de un arrastre.
Rect _sceneRect(Rect widgetRect, Matrix4 transform) {
  final inverse = Matrix4.tryInvert(transform);
  if (inverse == null) return widgetRect;

  return MatrixUtils.transformRect(inverse, widgetRect);
}
