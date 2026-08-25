import 'dart:math' as math;

import 'package:Fern/config/theme/app_sizes.dart';
import 'package:flutter/foundation.dart';

/// Cómo queda el menú lateral a un ancho dado, y con qué veredicto se decidió.
@immutable
class SidebarCollapse {
  /// Si el menú va plegado.
  final bool isCollapsed;

  /// Si a este ancho *toca* ir plegado. Se guarda para el siguiente cálculo: lo
  /// que pliega el menú es **cruzar** el umbral, no estar a un lado de él, y sin
  /// recordar de qué lado se estaba no hay forma de distinguir las dos cosas.
  final bool verdict;

  const SidebarCollapse({required this.isCollapsed, required this.verdict});

  @override
  bool operator ==(Object other) =>
      other is SidebarCollapse &&
      other.isCollapsed == isCollapsed &&
      other.verdict == verdict;

  @override
  int get hashCode => Object.hash(isCollapsed, verdict);

  @override
  String toString() => 'SidebarCollapse($isCollapsed, veredicto: $verdict)';
}

/// Decide si el menú lateral va plegado.
///
/// El menú se pliega cuando la ventana ocupa media pantalla, pero nunca más
/// tarde de [AppSizes.sidebarAutoCollapseMinWidth]: en un monitor muy ancho,
/// media pantalla sigue siendo más de lo que las cabeceras necesitan, y esperar
/// a esa mitad las dejaría desbordando por el camino.
///
/// Cruzar el umbral manda sobre lo que el usuario hubiera puesto a mano, y
/// estar a un lado de él no: quien pliega el menú teniendo sitio de sobra lo
/// quiere plegado hasta que la ventana cambie de lado.
///
/// **Al arrancar se despliega siempre**, mire lo que mire el ancho. La regla de
/// media pantalla dice «has puesto esta ventana al lado de otra cosa», y eso no
/// se puede saber de una ventana que acaba de abrirse: en un monitor de 4K,
/// cualquier ventana de tamaño razonable ocupa menos de media pantalla, así que
/// aplicar la regla en el primer fotograma dejaba la aplicación arrancando
/// siempre plegada.
///
/// Lo que evita que ahí desborde algo no es esto, es el tamaño con el que nace
/// la ventana: `windows/runner/main.cpp` la abre lo bastante ancha como para que
/// el menú desplegado quepa.
SidebarCollapse sidebarCollapse({
  required double width,
  required double halfScreenWidth,
  required bool wasCollapsed,
  bool? lastVerdict,
}) {
  final threshold = math.max(
    halfScreenWidth,
    AppSizes.sidebarAutoCollapseMinWidth,
  );

  final verdict = width <= threshold;

  return SidebarCollapse(
    isCollapsed: lastVerdict == null || verdict == lastVerdict
        ? wasCollapsed
        : verdict,
    verdict: verdict,
  );
}
