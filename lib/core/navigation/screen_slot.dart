import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/navigation/screen_choreography.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:flutter/widgets.dart';

/// Las dos animaciones de la pantalla, puestas al alcance de lo que lleva
/// dentro.
///
/// `CustomTransitionPage` se las da a quien pinta la transición, y esa función
/// envuelve a la pantalla entera. Pero lo que hay que mover no es la pantalla
/// entera: es la cabecera hacia arriba y la rejilla hacia abajo, cada una por su
/// lado. Así que las animaciones bajan por el árbol y cada pieza coge la suya.
class ScreenTransitionScope extends InheritedWidget {
  /// De 0 a 1 mientras esta pantalla entra.
  final Animation<double> entering;

  /// De 0 a 1 mientras **otra** la tapa, es decir, mientras ésta se va.
  final Animation<double> leaving;

  const ScreenTransitionScope({
    super.key,
    required this.entering,
    required this.leaving,
    required super.child,
  });

  static ScreenTransitionScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ScreenTransitionScope>();

  @override
  bool updateShouldNotify(ScreenTransitionScope old) =>
      entering != old.entering || leaving != old.leaving;
}

/// Una pieza de la pantalla que entra y sale por su lado.
///
/// Se envuelve con esto lo que tiene sitio propio en la maquetación —la
/// cabecera, la rejilla, la lista— y cada una se retira por donde estaba: la de
/// arriba hacia arriba, la de abajo hacia abajo, la del lado hacia su lado.
///
/// **Nunca se cruzan la que sale y la que entra.** No por suerte: la que sale
/// tiene todo su recorrido en el primer tramo de la transición y la que entra en
/// el resto, así que cuando una empieza la otra ya ha terminado. Es también lo
/// que permite mover cuatro piezas a la vez sin que la pantalla parezca un
/// enjambre.
///
/// Y **dentro de la misma familia no se mueve nada**: sólo se cambia el
/// contenido con un fundido. La maquetación es idéntica a los dos lados, así que
/// animarla sería enseñar un movimiento que no ocurre.
class ScreenSlotTransition extends StatelessWidget {
  final ScreenSlot slot;
  final Widget child;

  const ScreenSlotTransition({
    super.key,
    required this.slot,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scope = ScreenTransitionScope.maybeOf(context);
    if (scope == null) return child;

    final choreography = getIt<ScreenChoreography>();

    // Con el navegador de por medio no se anima nada: su contenido no lo pinta
    // Flutter y cualquier intento sale mal.
    if (choreography.isInstant) return child;

    return AnimatedBuilder(
      animation: Listenable.merge([scope.entering, scope.leaving]),
      // **Con su propia capa.** Aplicar opacidad a un subárbol obliga a
      // componerlo aparte en cada fotograma, y aquí el subárbol es media
      // pantalla de miniaturas. Con la capa marcada, lo de dentro se pinta una
      // vez y lo único que cambia por fotograma es la transparencia con la que
      // esa capa se estampa. Es la diferencia entre una transición fluida y una
      // que va a tirones justo donde más contenido hay.
      child: RepaintBoundary(child: child),
      builder: (context, child) {
        if (choreography.isWithinFamily) {
          // **Un fundido cruzado de verdad**, los dos a la vez.
          //
          // La maquetación es idéntica a los dos lados, así que solaparlos no
          // enseña nada raro: lo único que cambia es lo que hay dentro de cada
          // hueco. Encadenándolos —primero apagar, después encender— quedaba un
          // instante en el que no había nada, y eso es lo que se veía como un
          // parpadeo.
          //
          // Las curvas no son una la inversa de la otra a propósito: ver
          // [crossfadeInCurve]. Con opacidades complementarias, a mitad de
          // camino se cuela un cuarto de fondo desnudo entre las dos pantallas.
          return Opacity(opacity: _crossfade(scope), child: child);
        }

        // Cambiando de forma de pantalla sí van encadenados: la que sale se
        // retira entera antes de que la que entra empiece a llegar. Es lo que
        // garantiza que cuatro piezas moviéndose por su lado no se crucen.
        final saliendo = Interval(
          0.0,
          screenExitSplit,
          curve: motionExitCurve,
        ).transform(scope.leaving.value);

        final entrando = Interval(
          screenExitSplit,
          1.0,
          curve: motionEnterCurve,
        ).transform(scope.entering.value);

        final opacidad = (entrando * (1 - saliendo)).clamp(0.0, 1.0);

        final direccion = screenSlotExit[slot] ?? Offset.zero;

        // Sale hacia su lado, y entra **desde ese mismo lado**. Iba con
        // `entrando - 1`, que hace justo lo contrario: la rejilla se escondía
        // hacia abajo al salir y volvía a aparecer desde arriba.
        final avance = saliendo > 0 ? saliendo : (1 - entrando);

        return FractionalTranslation(
          translation: direccion * avance,
          child: Opacity(opacity: opacidad, child: child),
        );
      },
    );
  }
}

/// Lo opaca que va una pieza en un fundido cruzado.
///
/// Sube deprisa al entrar y baja tarde al salir, que es lo que impide que las dos
/// pantallas dejen ver el fondo a la vez. Sale al mismo número por los dos lados:
/// para la que entra manda [ScreenTransitionScope.entering] y para la que sale
/// manda [ScreenTransitionScope.leaving], porque la otra vale uno.
double _crossfade(ScreenTransitionScope scope) {
  final entrando = crossfadeInCurve.transform(scope.entering.value.clamp(0.0, 1.0));
  final saliendo = crossfadeOutCurve.transform(scope.leaving.value.clamp(0.0, 1.0));

  return (entrando * (1 - saliendo)).clamp(0.0, 1.0);
}
