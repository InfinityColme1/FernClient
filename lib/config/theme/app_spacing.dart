import 'package:flutter/material.dart';

class AppSpacing {
  /// El escalón más fino, para separar un icono de su borde. No se usa como
  /// separación entre elementos: para eso el mínimo es [xs].
  static const double xxs = 1.0;

  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  /// Margen interior de una rejilla metida en una superficie redondeada.
  ///
  /// La curva de la superficie —`AppSizes.radiusSurface`, 43— muerde las celdas
  /// de las esquinas, y con el hueco normal entre celdas (8) el mordisco se ve.
  /// No hace falta el radio entero: la celda también es redondeada, así que sus
  /// esquinas ya se apartan del arco. Con esto dejan de cortarse.
  static const double gridInset = l;

  // Edge Insets
  static const EdgeInsets pagePadding = EdgeInsets.all(xl);
  static const EdgeInsets dialogPadding = EdgeInsets.all(xl);
  static const EdgeInsets infoPadding = EdgeInsets.symmetric(horizontal: l, vertical: xl);
}
