import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/region_geometry.dart';

/// Una región tal y como hay que pintarla: dónde está y cómo se llama.
///
/// El rectángulo va **normalizado** (0..1 sobre el contenido original), que es
/// como se guarda: el pintor es quien lo lleva a coordenadas de pantalla con la
/// transformación que tenga puesta el visor en ese momento.
@immutable
class RegionVisual {
  final Rect rect;

  /// Nombre del fernie al que pertenece, para saber qué es cada rectángulo
  /// cuando hay varios encima del mismo contenido. `null` en las que todavía no
  /// se han asignado.
  final String? label;

  /// Se pinta más apagada de lo normal.
  final bool isDimmed;

  /// Si se pinta y se puede tocar.
  ///
  /// Con contenido que se mueve, las regiones de otro fotograma se esconden en
  /// vez de apilarse: son el mismo objeto en otro momento, y verlas todas a la
  /// vez llena la imagen de cajas que se pisan. Siguen en la lista para que los
  /// índices no bailen; lo que cambia es que no se dibujan ni responden.
  final bool isVisible;

  const RegionVisual({
    required this.rect,
    this.label,
    this.isDimmed = false,
    this.isVisible = true,
  });

  @override
  bool operator ==(Object other) =>
      other is RegionVisual &&
      other.rect == rect &&
      other.label == label &&
      other.isDimmed == isDimmed &&
      other.isVisible == isVisible;

  @override
  int get hashCode => Object.hash(rect, label, isDimmed, isVisible);
}

/// Pinta regiones sobre un contenido: las que ya están guardadas, la que se está
/// arrastrando y la que hay que resaltar.
///
/// Es el mismo pintor para el modo fernie y para el resaltado con el que el
/// visor señala una región al llegar desde la pantalla de fernies. Son el mismo
/// dibujo con distintos ajustes, y tenerlo dos veces acabaría con dos
/// rectángulos que no se parecen.
///
/// No sabe nada del dominio: recibe rectángulos, colores y una transformación.
class RegionPainter extends CustomPainter {
  final List<RegionVisual> regions;

  /// La región que se está arrastrando ahora mismo, ya normalizada. Se pinta
  /// distinto de las demás y con un velo alrededor, que es lo que hace que se
  /// entienda que se está recortando.
  final Rect? pending;

  /// Índice de la región marcada dentro de [regions]. La marcada lleva tiradores
  /// en las esquinas para redimensionarla.
  final int? selectedIndex;

  /// Índice de la región a resaltar y con qué intensidad, de 0 a 1. Es lo que
  /// hace el resaltado: lo de fuera se oscurece y el borde se refuerza.
  ///
  /// Manda sobre [regionsOpacity]: la región señalada se ve aunque las demás
  /// estén escondidas, que es justo lo que pasa al abrir el visor desde la
  /// rejilla de fernies.
  ///
  /// **Varias y no una**: un modelo puede ver cuatro coches en una foto, y
  /// señalar la fila del panel tiene que enseñar los cuatro rectángulos. Con un
  /// solo índice se veía uno y los otros tres quedaban escondidos bajo la
  /// opacidad de las regiones.
  final Set<int> highlightedIndexes;
  final double highlightIntensity;

  /// Por dónde va cada fernie ahora mismo, en el contenido que se mueve.
  ///
  /// Se pintan con trazo fino y sin tiradores porque **no son regiones**: son el
  /// recorrido entre las que sí están marcadas, y no hay nada que tocar en
  /// ellas. Es lo que se ve al reproducir para comprobar si el trabajo
  /// acompaña a lo que hay debajo.
  final List<RegionVisual> previews;

  /// Cuánto se ven las regiones, de 0 a 1.
  ///
  /// A cero no se pinta ninguna. Es lo que las esconde fuera del modo fernie y
  /// lo que las hace entrar y salir con un desvanecido en vez de aparecer de
  /// golpe.
  final double regionsOpacity;

  /// Tamaño del contenido original y transformación con la que se está pintando.
  /// Con estas dos cosas se lleva un rectángulo normalizado a la pantalla.
  final Size contentSize;
  final Matrix4 transform;

  final Color strokeColor;
  final Color scrimColor;
  final Color labelColor;

  /// Lado del tirador de esquina. Se pasa desde fuera para no clavar números
  /// aquí dentro.
  final double handleSize;

  const RegionPainter({
    required this.regions,
    required this.contentSize,
    required this.transform,
    required this.strokeColor,
    required this.scrimColor,
    required this.labelColor,
    this.pending,
    this.previews = const [],
    this.selectedIndex,
    this.highlightedIndexes = const {},
    this.highlightIntensity = 0,
    this.regionsOpacity = 1,
    this.handleSize = AppSpacing.m,
  });

  /// Opacidades del dibujo. Van aquí y no en las constantes de la aplicación
  /// porque son de este dibujo y de ningún otro.
  static const _fillOpacity = 0.15;
  static const _dimmedOpacity = 0.35;
  static const _scrimOpacity = 0.5;
  static const _labelBackgroundOpacity = 0.75;
  static const _handleBorderOpacity = 0.5;
  static const _previewOpacity = 0.7;

  @override
  void paint(Canvas canvas, Size size) {
    // El velo va antes que todo lo demás: es el fondo sobre el que se recortan
    // la región pendiente y la resaltada.
    final focus = pending ?? _highlighted;
    if (focus != null) _paintScrim(canvas, size, focus);

    for (final preview in previews) {
      _paintPreview(canvas, _toScreen(preview.rect, size), preview.label);
    }

    for (var index = 0; index < regions.length; index++) {
      final region = regions[index];
      if (!region.isVisible) continue;

      final isHighlighted = highlightedIndexes.contains(index);

      // La resaltada se ve aunque las demás estén escondidas: es la única razón
      // por la que se ha abierto el visor.
      final visibility = isHighlighted
          ? math.max(regionsOpacity, highlightIntensity)
          : regionsOpacity;
      if (visibility <= 0) continue;

      final opacity = visibility *
          (region.isDimmed && !isHighlighted ? _dimmedOpacity : 1.0);

      final rect = _toScreen(region.rect, size);
      final isSelected = index == selectedIndex;

      _paintRegion(
        canvas,
        rect,
        opacity: opacity,
        // La elegida se aclara hacia el blanco en vez de cambiar de color: sigue
        // siendo la misma región y se distingue de un vistazo.
        color: isSelected ? _selectedColor : strokeColor,
        strokeWidth: isHighlighted
            ? AppSizes.borderRegular + highlightIntensity * AppSizes.borderThin
            : AppSizes.borderRegular,
      );

      if (region.label case final label?) {
        _paintLabel(canvas, rect, label, opacity: opacity);
      }

      if (isSelected) _paintHandles(canvas, rect);
    }

    if (pending case final rect?) {
      _paintRegion(canvas, _toScreen(rect, size), opacity: 1);
    }
  }

  /// La región resaltada, si hay **una sola** y sigue existiendo.
  ///
  /// El velo oscurece todo menos un hueco, así que sólo tiene sentido con una:
  /// señalando cuatro coches a la vez, recortar cuatro huecos dejaría la imagen
  /// hecha un queso y no ayudaría a mirar ninguno. Con varias no se oscurece
  /// nada — se ven los cuatro rectángulos sobre el contenido tal cual.
  Rect? get _highlighted {
    if (highlightedIndexes.length != 1) return null;
    if (highlightIntensity <= 0) return null;

    final index = highlightedIndexes.first;
    if (index < 0 || index >= regions.length) return null;

    return regions[index].rect;
  }

  Rect _toScreen(Rect normalized, Size size) {
    return normalizedRectToWidget(
      normalized,
      transform: transform,
      widgetSize: size,
      imageSize: contentSize,
    );
  }

  /// Oscurece todo menos [focus], con la regla par-impar: dos rectángulos en el
  /// mismo trazado dejan sin pintar lo que hay dentro del pequeño.
  void _paintScrim(Canvas canvas, Size size, Rect focus) {
    final hole = _toScreen(focus, size);

    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRect(hole)
      ..fillType = PathFillType.evenOdd;

    final alpha = pending != null ? _scrimOpacity : _scrimOpacity * highlightIntensity;

    canvas.drawPath(
      path,
      Paint()..color = scrimColor.withValues(alpha: alpha),
    );
  }

  /// El recorrido de un fernie: la caja que va de una región marcada a la
  /// siguiente.
  ///
  /// Va con trazo fino y sin relleno para que no se confunda con lo marcado: es
  /// una ayuda para comprobar, no algo que se pueda tocar.
  void _paintPreview(Canvas canvas, Rect rect, String? label) {
    final rounded = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(AppSizes.radiusSmall),
    );

    canvas.drawRRect(
      rounded,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppSizes.borderThin
        ..color = strokeColor.withValues(alpha: _previewOpacity),
    );

    if (label != null) {
      _paintLabel(canvas, rect, label, opacity: _previewOpacity);
    }
  }

  /// El color de la región elegida: el de siempre, aclarado.
  Color get _selectedColor =>
      Color.lerp(strokeColor, Colors.white, regionSelectedTint) ?? strokeColor;

  void _paintRegion(
    Canvas canvas,
    Rect rect, {
    required double opacity,
    Color? color,
    double strokeWidth = AppSizes.borderRegular,
  }) {
    final paintColor = color ?? strokeColor;

    final rounded = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(AppSizes.radiusSmall),
    );

    canvas.drawRRect(
      rounded,
      Paint()..color = paintColor.withValues(alpha: _fillOpacity * opacity),
    );

    canvas.drawRRect(
      rounded,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = paintColor.withValues(alpha: opacity),
    );
  }

  /// El nombre del fernie, en una píldora pegada al borde superior del
  /// rectángulo. Se pone por dentro cuando la región está tan arriba que la
  /// píldora se saldría del contenido.
  void _paintLabel(
    Canvas canvas,
    Rect rect,
    String label, {
    required double opacity,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: labelColor.withValues(alpha: opacity),
          fontSize: AppSizes.iconSmall * 0.75,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: rect.width);

    final height = painter.height + AppSpacing.xs;
    final width = painter.width + AppSpacing.s;

    final top = rect.top - height - AppSpacing.xxs >= 0
        ? rect.top - height - AppSpacing.xxs
        : rect.top + AppSpacing.xxs;

    final background = RRect.fromRectAndRadius(
      Rect.fromLTWH(rect.left, top, width, height),
      const Radius.circular(AppSizes.radiusSmall),
    );

    canvas.drawRRect(
      background,
      Paint()
        ..color =
            strokeColor.withValues(alpha: _labelBackgroundOpacity * opacity),
    );

    painter.paint(
      canvas,
      Offset(rect.left + AppSpacing.xs, top + AppSpacing.xxs),
    );
  }

  /// Los ocho tiradores de la región elegida: las cuatro esquinas y el centro de
  /// cada lado, como los de una ventana.
  ///
  /// Se dibujan centrados en su punto para que agarrarlos sea agarrar el borde,
  /// no lo de al lado.
  void _paintHandles(Canvas canvas, Rect rect) {
    final fill = Paint()..color = _selectedColor;
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSizes.borderThin
      ..color = scrimColor.withValues(alpha: _handleBorderOpacity);

    for (final point in [
      rect.topLeft,
      rect.topCenter,
      rect.topRight,
      rect.centerLeft,
      rect.centerRight,
      rect.bottomLeft,
      rect.bottomCenter,
      rect.bottomRight,
    ]) {
      final handle = Rect.fromCenter(
        center: point,
        width: handleSize,
        height: handleSize,
      );

      canvas.drawRect(handle, fill);
      canvas.drawRect(handle, border);
    }
  }

  @override
  bool shouldRepaint(covariant RegionPainter oldDelegate) {
    // Las regiones se comparan una a una: la lista se rehace en cada
    // construcción del visor, así que compararla por identidad repintaría
    // siempre y el `shouldRepaint` no serviría de nada.
    return !listEquals(oldDelegate.regions, regions) ||
        !listEquals(oldDelegate.previews, previews) ||
        oldDelegate.pending != pending ||
        oldDelegate.selectedIndex != selectedIndex ||
        !setEquals(oldDelegate.highlightedIndexes, highlightedIndexes) ||
        oldDelegate.highlightIntensity != highlightIntensity ||
        oldDelegate.regionsOpacity != regionsOpacity ||
        oldDelegate.contentSize != contentSize ||
        oldDelegate.transform != transform ||
        oldDelegate.strokeColor != strokeColor;
  }
}
