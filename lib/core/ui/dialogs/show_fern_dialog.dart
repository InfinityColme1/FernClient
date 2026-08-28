import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/display/fern_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Abre un diálogo y, si se indica [bloc], lo vuelve a proveer al árbol del
/// diálogo (que cuelga del `Navigator`, no del widget que lo abre).
///
/// Evita repetir en cada pantalla el `showDialog` + `BlocProvider.value`.
///
/// [T] es el tipo del resultado con el que se cierra el diálogo y [B] el del
/// bloc. Este último tiene que ser el tipo concreto (`MediaBloc`, por ejemplo):
/// `BlocProvider` registra el bloc con el tipo estático que se le pasa, así que
/// si aquí se recibiera como `StateStreamableSource` ningún
/// `context.read<MediaBloc>()` del diálogo lo encontraría.
///
/// Dart no infiere sólo una parte de los tipos: si hace falta nombrar [T] hay
/// que nombrar también [B] (`showFernDialog<TagEntity, MediaBloc>(...)`).
Future<T?> showFernDialog<T, B extends StateStreamableSource<Object?>>({
  required BuildContext context,
  required WidgetBuilder builder,
  B? bloc,
  bool barrierDismissible = true,
}) {
  final blocValue = bloc;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    // `showGeneralDialog` no lo saca del tema como hace `showDialog`, así que hay
    // que decirlo: sin esto el velo sale negro opaco de fábrica.
    barrierColor: Theme.of(context).colorScheme.scrim.withValues(
          alpha: dialogBarrierOpacity,
        ),
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: context.motion(motionStandard),
    transitionBuilder: _fernDialogTransition,
    pageBuilder: (dialogContext, _, _) => blocValue == null
        ? builder(dialogContext)
        : BlocProvider<B>.value(
            value: blocValue,
            child: builder(dialogContext),
          ),
  );
}

/// Cómo aparece y cómo se va un diálogo.
///
/// **Aparece creciendo un poco, no cayendo.** Un diálogo no viene de ninguna
/// parte: se abre donde está. Escalar desde casi su tamaño dice eso; deslizarlo
/// desde un borde diría que estaba fuera de la pantalla esperando, que no es lo
/// que pasa.
///
/// Se anima sólo cómo se pinta —opacidad y escala—, así que la maquetación está
/// en su sitio definitivo desde el primer fotograma y nada puede desbordar a
/// mitad de camino.
Widget _fernDialogTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondary,
  Widget child,
) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: motionEnterCurve,
    reverseCurve: motionExitCurve,
  );

  return FadeTransition(
    opacity: curved,
    child: ScaleTransition(
      scale: Tween<double>(begin: dialogEnterScale, end: 1.0).animate(curved),
      child: child,
    ),
  );
}

/// Cierra el diálogo actual y abre otro en su lugar.
///
/// Toma el `Navigator` antes de cerrar para no usar un [BuildContext]
/// desmontado al abrir el segundo diálogo.
Future<T?> replaceFernDialog<T, B extends StateStreamableSource<Object?>>({
  required BuildContext context,
  required WidgetBuilder builder,
  B? bloc,
}) {
  final navigator = Navigator.of(context);
  navigator.pop();

  return showFernDialog<T, B>(
    context: navigator.context,
    builder: builder,
    bloc: bloc,
  );
}
