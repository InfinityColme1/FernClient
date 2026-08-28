import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/ui/interaction/fern_drag_watch.dart';
import 'package:flutter/material.dart';

/// En qué estado está una zona donde se puede soltar algo.
enum FernDropState {
  /// No hay nada arrastrándose por encima.
  idle,

  /// Hay algo encima y se acepta.
  accepting,

  /// Hay algo encima y **no** se acepta.
  rejecting,
}

/// Un sitio donde soltar lo que se arrastra.
///
/// Envuelve a [DragTarget] con las tres caras que hay que distinguir siempre:
/// en reposo, aceptando y rechazando. **La de rechazo es la que no se puede
/// omitir**: sin ella, soltar algo que no vale se ve exactamente igual que
/// soltarlo bien, sólo que no pasa nada, y no hay forma de saber si el fallo fue
/// del sitio o de la puntería.
///
/// Quién decide si se acepta es de quien lo usa: aquí no se sabe qué se está
/// arrastrando ni por qué unas cosas valen y otras no.
class FernDropSlot<T extends Object> extends StatelessWidget {
  /// Si esto que viene se puede soltar aquí.
  final bool Function(T data) canAccept;

  final ValueChanged<T> onAccept;

  /// Lo de dentro. Recibe el estado para poder cambiar con él si hace falta;
  /// el resaltado del borde lo pone este widget por su cuenta.
  final Widget Function(BuildContext context, FernDropState state) builder;

  /// Con `false` no recoge nada. Sirve para apagar una zona sin sacarla del
  /// árbol de widgets y que lo de dentro no se mueva de sitio.
  final bool isEnabled;

  /// Sin marco: la zona resalta lo que tenga dentro y no se dibuja a sí misma.
  /// Es lo que quiere una zona grande, como el fondo de un lienzo.
  final bool isPlain;

  const FernDropSlot({
    super.key,
    required this.canAccept,
    required this.onAccept,
    required this.builder,
    this.isEnabled = true,
    this.isPlain = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) return builder(context, FernDropState.idle);

    return DragTarget<T>(
      onWillAcceptWithDetails: (details) {
        final acepta = canAccept(details.data);
        // Se avisa a la miniatura que va pegada al cursor, que no tiene otra
        // forma de enterarse: la pinta `Draggable` en la capa de encima, fuera
        // de este arbol.
        if (acepta) fernDragIsOverTarget.value = true;

        return acepta;
      },
      onLeave: (_) => fernDragIsOverTarget.value = false,
      onAcceptWithDetails: (details) {
        fernDragIsOverTarget.value = false;
        onAccept(details.data);
      },
      builder: (context, candidates, rejected) {
        final state = candidates.isNotEmpty
            ? FernDropState.accepting
            : rejected.isNotEmpty
                ? FernDropState.rejecting
                : FernDropState.idle;

        final child = builder(context, state);
        if (isPlain || state == FernDropState.idle) return child;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            border: Border.all(
              color: state == FernDropState.accepting
                  ? context.colors.terciary
                  : context.colors.error,
              width: AppSizes.borderRegular,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
