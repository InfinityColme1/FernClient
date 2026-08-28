import 'package:flutter/material.dart';

/// La barra de desplazamiento de la aplicación, allí donde Flutter no la pone
/// sola.
///
/// **Cómo se pinta no se decide aquí.** El aspecto —el pulgar con forma de
/// pastilla, que crezca al acercarse, el surco que sale con el ratón encima, los
/// colores de la paleta y el hueco que la aparta de las esquinas redondeadas—
/// vive en `scrollbarTheme` de [AppTheme], para que lo hereden también las
/// barras que Flutter añade solo a cualquier lista desplazable, que son la
/// mayoría. Si estuviera aquí, la aplicación tendría dos looks: el de lo que
/// pasa por este widget y el de todo lo demás.
///
/// Lo que sí se decide aquí es **si se queda puesta**.
class FernScrollbar extends StatelessWidget {
  final Widget child;

  /// El mismo que use lo que hay dentro. Hace falta cuando el hijo no es
  /// directamente el desplazable, que es lo normal.
  final ScrollController? controller;

  /// Si se queda puesta o sólo sale al desplazar.
  ///
  /// Puesta en lo que tiene un tope de alto y más contenido del que cabe —un
  /// desplegable, por ejemplo—: ahí la barra no es un adorno, es lo único que
  /// dice que hay más cosas debajo antes de que nadie toque la rueda.
  final bool isAlwaysVisible;

  const FernScrollbar({
    super.key,
    required this.child,
    this.controller,
    this.isAlwaysVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: isAlwaysVisible,
      child: child,
    );
  }
}
