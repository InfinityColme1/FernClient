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

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => blocValue == null
        ? builder(dialogContext)
        : BlocProvider<B>.value(
            value: blocValue,
            child: builder(dialogContext),
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
