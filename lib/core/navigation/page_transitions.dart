import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/navigation/screen_choreography.dart';
import 'package:Fern/core/navigation/screen_slot.dart';
import 'package:Fern/core/service_locator.dart';
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

/// Página de las pantallas del armazón: las que se cambian por el menú lateral.
///
/// **Sólo un fundido, y muy corto.** Estas se cambian muchísimas veces al día y
/// cualquier cosa que se interponga entre pulsar y ver molesta enseguida. Un
/// fundido de opacidad no se interpone: la pantalla nueva está maquetada en su
/// sitio definitivo desde el primer fotograma y lo único que ocurre es que se
/// hace visible. Nada crece, nada se desplaza y no hay nada que esperar.
///
/// Estaban sin transición ninguna, y el corte seco entre dos pantallas del mismo
/// armazón es lo que hacía que cambiar de sección se sintiera como un parpadeo.
CustomTransitionPage<void> fernShellPage({
  required LocalKey key,
  required Widget child,
  required String location,
  ScreenFamily family = ScreenFamily.plain,
}) {
  // Se apunta a dónde se va **al construir la página**, que es el momento en el
  // que se navega. De aquí sale si el cambio es dentro de la familia o entre dos
  // formas distintas de pantalla, y eso lo leen las dos a la vez.
  final choreography = getIt<ScreenChoreography>()..moveTo(location, family);

  // Cuánto se le da a esta transición, decidido ya sabiendo de dónde se viene.
  //
  // Quien manda es la pantalla que entra: es su duración la que usa el navegador
  // para las dos. Y aquí ya se sabe si el cambio es dentro de la familia o entre
  // dos formas distintas, porque acaba de apuntarse.
  final duration = switch (choreography) {
    _ when choreography.isInstant => Duration.zero,
    _ when choreography.isWithinFamily => screenCrossfadeDuration,
    _ => screenTransitionDuration,
  };

  return CustomTransitionPage<void>(
    key: key,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    child: child,
    transitionsBuilder: (context, animation, secondary, child) =>
        ScreenTransitionScope(
      entering: animation,
      leaving: secondary,
      // La pantalla entera **no se mueve ni se apaga**: eso lo hace cada una de
      // sus piezas por su cuenta, cada una por su lado. Aquí sólo se le pasan
      // las dos animaciones para que puedan cogerlas.
      //
      // Lo que no tiene piezas declaradas se queda sin animación, y es lo
      // correcto: mover una pantalla entera de la que no se sabe cómo está
      // hecha es lo que produce esos deslizamientos en bloque que no dicen nada.
      // Las que declaran piezas congelan cada pieza por su cuenta, dentro de
      // `ScreenSlotTransition`; aquí no hay piezas, así que la pantalla entera
      // es la unidad.
      child: family == ScreenFamily.plain
          ? _PlainFade(
              entering: animation,
              leaving: secondary,
              child: child,
            )
          // Las que declaran piezas se animan por dentro, cada una por su lado:
          // apagarlas además aquí dejaría todo a mitad de opaco.
          : child,
    ),
  );
}

/// El fundido de las pantallas que no declaran piezas.
///
/// Encadenado, no cruzado: la que sale se apaga antes de que la que entra
/// aparezca. Solaparlas es lo que hacía que se viera una rejilla llena asomando
/// por debajo de una pantalla vacía.
class _PlainFade extends StatelessWidget {
  final Animation<double> entering;
  final Animation<double> leaving;
  final Widget child;

  const _PlainFade({
    required this.entering,
    required this.leaving,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final choreography = getIt<ScreenChoreography>();
    if (choreography.isInstant) return child;

    return AnimatedBuilder(
      animation: Listenable.merge([entering, leaving]),
      child: RepaintBoundary(child: child),
      builder: (context, child) {
        // Entre dos pantallas de la misma forma, cruzado: solaparlas no enseña
        // nada raro y encadenarlas deja un instante en negro que se ve como un
        // parpadeo.
        if (choreography.isWithinFamily) {
          // Las mismas curvas que las piezas: suben deprisa y bajan tarde, así
          // que las dos pantallas nunca dejan ver el fondo a la vez.
          final entrando = crossfadeInCurve.transform(entering.value);
          final saliendo = crossfadeOutCurve.transform(leaving.value);

          return Opacity(
            opacity: (entrando * (1 - saliendo)).clamp(0.0, 1.0),
            child: child,
          );
        }

        // Cambiando de forma, encadenado: la que sale se apaga antes de que la
        // que entra aparezca.
        final saliendo = const Interval(0.0, screenExitSplit)
            .transform(leaving.value);
        final entrando = const Interval(screenExitSplit, 1.0)
            .transform(entering.value);

        return Opacity(
          opacity: (entrando * (1 - saliendo)).clamp(0.0, 1.0),
          child: child,
        );
      },
    );
  }
}

/// Un fundido **encadenado**: primero se va la que estaba, después llega la
/// nueva. Nunca las dos a la vez.
///
/// **Por qué encadenado y no cruzado.** Un fundido cruzado deja las dos
/// pantallas encima a la vez a media transición, y con una rejilla llena por
/// debajo y una pantalla vacía por encima lo que se ve es la rejilla asomando a
/// través: parecía que el contenido se iba hacia arriba y luego desaparecía.
///
/// Aquí no se solapan. La que sale se apaga en el primer tercio; la nueva
/// aparece en los dos tercios restantes, cuando ya no hay nada debajo. Es el
/// patrón que Material llama «fade through» y está pensado justamente para esto:
/// pasar entre pantallas hermanas, que no vienen una de otra.
Widget fernFadeThrough(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    // Al entrar: quieta y transparente hasta que la anterior se ha ido del todo.
    opacity: CurvedAnimation(
      parent: animation,
      curve: const Interval(fadeThroughSplit, 1.0, curve: motionEnterCurve),
    ),
    child: FadeTransition(
      // Al salir: se apaga deprisa y deja el sitio limpio.
      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: const Interval(0.0, fadeThroughSplit, curve: motionExitCurve),
        ),
      ),
      child: child,
    ),
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
  final curved = CurvedAnimation(parent: animation, curve: motionEnterCurve);

  return FadeTransition(
    opacity: curved,
    child: ScaleTransition(
      scale: Tween<double>(begin: pageTransitionScale, end: 1.0).animate(curved),
      child: child,
    ),
  );
}
