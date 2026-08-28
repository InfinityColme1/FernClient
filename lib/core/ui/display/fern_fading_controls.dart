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
///
/// [onHoverChanged] avisa de cuándo el ratón está encima, y hace falta porque la
/// cuenta atrás no distingue «nadie está mirando» de «alguien está a punto de
/// pulsar»: quieto sobre un botón, el ratón no se mueve, así que la cuenta
/// llegaba al final y el botón se desvanecía debajo del cursor.
class FernFadingControls extends StatelessWidget {
  final bool isVisible;
  final Widget child;

  /// Se llama con `true` al entrar el ratón y con `false` al salir.
  final ValueChanged<bool>? onHoverChanged;

  const FernFadingControls({
    super.key,
    required this.isVisible,
    required this.child,
    this.onHoverChanged,
  });

  @override
  Widget build(BuildContext context) {
    // El aviso del ratón va **dentro** del `IgnorePointer` a propósito: escondido
    // el mando no existe para el ratón, así que tampoco avisa. Por fuera, el
    // cursor parado donde estuvo un botón lo haría reaparecer solo, y entonces no
    // habría manera de dejar el contenido limpio sin apartar el ratón.
    final Widget controls = onHoverChanged == null
        ? child
        : MouseRegion(
            // Sólo cuentan los botones, no el hueco que hay entre ellos.
            //
            // Una barra de acciones ocupa el ancho entero de la ventana y casi
            // todo es aire —el sombreado y los huecos—. Sin esto, el ratón
            // quieto en cualquier punto de esa franja contaba como «encima de un
            // mando» y los botones no se iban nunca.
            //
            // `deferToChild` hace que la pregunta la conteste lo que haya
            // debajo: un botón dice que sí, un degradado o un `Spacer` no.
            opaque: false,
            hitTestBehavior: HitTestBehavior.deferToChild,
            onEnter: (_) => onHoverChanged!(true),
            onExit: (_) => onHoverChanged!(false),
            child: child,
          );

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: viewerControlsFadeDuration,
      child: IgnorePointer(ignoring: !isVisible, child: controls),
    );
  }
}
