import 'package:flutter/material.dart';

/// De qué color es la superficie sobre la que se está pintando.
///
/// Existe por un problema muy concreto: la etiqueta flotante de un campo con
/// contorno se apoya **encima** del borde, y para que el borde no se le vea por
/// detrás tiene que taparlo con el color de lo que hay debajo. Un widget no
/// puede saber de qué color es su fondo, así que la superficie lo dice.
///
/// Sin esto, la etiqueta pintaba siempre blanco: bien sobre una ficha blanca,
/// un parche que canta sobre cualquier otra cosa.
class FernSurfaceColor extends InheritedWidget {
  final Color color;

  const FernSurfaceColor({
    super.key,
    required this.color,
    required super.child,
  });

  /// El color de la superficie más cercana, o `null` si no hay ninguna encima.
  static Color? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<FernSurfaceColor>()
      ?.color;

  @override
  bool updateShouldNotify(FernSurfaceColor oldWidget) =>
      oldWidget.color != color;
}
