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

  // Edge Insets
  static const EdgeInsets pagePadding = EdgeInsets.all(xl);
  static const EdgeInsets dialogPadding = EdgeInsets.all(xl);
  static const EdgeInsets infoPadding = EdgeInsets.symmetric(horizontal: l, vertical: xl);
}
