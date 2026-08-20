import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Mandos que se desvanecen cuando no hacen falta.
///
/// Es lo que llevan la barra de acciones del visor, sus flechas, el panel de
/// herramientas y la línea de tiempo: se quitan de en medio cuando el ratón
/// lleva un rato quieto para dejar el contenido limpio, y vuelven en cuanto se
/// mueve.
///
/// Escondidos **no se pueden pulsar**, que es de lo que se encarga esto: un
/// botón que no se ve pero sigue respondiendo es un clic a ciegas esperando a
/// pasar. Del desvanecido en sí se encarga la opacidad, y ésa no deja de atender
/// al ratón por bajar a cero.
class FernFadingControls extends StatelessWidget {
  final bool isVisible;
  final Widget child;

  const FernFadingControls({
    super.key,
    required this.isVisible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: viewerControlsFadeDuration,
      child: IgnorePointer(ignoring: !isVisible, child: child),
    );
  }
}
