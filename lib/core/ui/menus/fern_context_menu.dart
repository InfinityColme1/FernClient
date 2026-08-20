import 'dart:math' as math;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Panel blanco anclado a **una posición** en vez de a un botón.
///
/// Es el hermano de [FernPopupPanel] para cuando no hay disparador: el menú que
/// se abre donde se ha soltado el ratón. Lleva su propia barrera transparente
/// detrás, así que pulsar en cualquier otro sitio lo cierra, que es lo que se
/// espera de un menú contextual.
///
/// Se coloca dentro de un `Stack` que ocupe toda el área en la que puede
/// aparecer, y [position] va en coordenadas de ese `Stack`. El panel se corre lo
/// justo para no salirse por ningún borde: si no cabe por debajo del punto, se
/// pone por encima.
///
/// No sabe nada del dominio: lo que lleva dentro lo pone quien lo abre.
class FernContextMenu extends StatelessWidget {
  /// Dónde se ha pulsado, en coordenadas del `Stack` que lo contiene.
  final Offset position;

  /// Lo que hay que hacer al pulsar fuera. Un menú contextual del que no se
  /// elige nada es un menú que se cancela.
  final VoidCallback onDismiss;

  final Widget child;

  final double width;

  /// Alto máximo del panel. El contenido se desplaza por dentro si no cabe.
  final double maxHeight;

  /// Hueco que se le deja a los bordes del área.
  final double margin;

  const FernContextMenu({
    super.key,
    required this.position,
    required this.onDismiss,
    required this.child,
    this.width = AppSizes.menuWidth,
    this.maxHeight = contextMenuMaxHeight,
    this.margin = AppSpacing.l,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final area = constraints.biggest;
        final offset = _placeIn(area);

        return Stack(
          children: [
            // La barrera va debajo del panel y encima de todo lo demás: sin ella
            // se podría seguir marcando regiones con el menú abierto.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDismiss,
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width,
                  maxHeight: maxHeight,
                ),
                child: Material(
                  color: context.colors.white,
                  elevation: contextMenuElevation,
                  borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(width: width, child: child),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Dónde acaba la esquina superior izquierda del panel.
  ///
  /// Por defecto justo debajo y a la derecha del punto, que es de donde sale el
  /// gesto. Si por ahí no cabe, se vuelca al otro lado en lugar de quedarse
  /// pegado al borde: un menú medio fuera de la ventana no se puede usar.
  Offset _placeIn(Size area) {
    final left = position.dx + width + margin <= area.width
        ? position.dx
        : math.max(margin, position.dx - width);

    final top = position.dy + maxHeight + margin <= area.height
        ? position.dy
        : math.max(margin, area.height - maxHeight - margin);

    return Offset(left, top);
  }
}
