import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Página con la transición de la aplicación: la que sale se desvanece mientras
/// la que entra aparece creciendo un poco hasta su tamaño.
///
/// Todas las pantallas entran y salen así, de modo que cambiar de pantalla no da
/// ningún salto. Y lo hace sin mover nada de sitio: lo único que se anima es
/// cómo se pinta (la opacidad y una escala), así que la maquetación de la
/// pantalla nueva está en su sitio definitivo desde el primer fotograma y no
/// puede desbordar mientras la transición está en marcha.
CustomTransitionPage<void> fernTransitionPage({
  required LocalKey key,
  required Widget child,
  Duration duration = pageTransitionDuration,
}) {
  return CustomTransitionPage<void>(
    key: key,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    child: child,
    transitionsBuilder: fernPageTransition,
  );
}

/// La transición en sí, tal y como la espera `CustomTransitionPage`.
///
/// Se aplica sobre la animación de la propia página, así que sirve para las dos
/// direcciones: al entrar va de transparente y pequeña a opaca y en su tamaño, y
/// al salir hace el camino de vuelta.
Widget fernPageTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

  return FadeTransition(
    opacity: curved,
    child: ScaleTransition(
      scale: Tween<double>(begin: pageTransitionScale, end: 1.0).animate(curved),
      child: child,
    ),
  );
}
