import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Algo que se puede arrastrar a otro sitio.
///
/// Envuelve a [Draggable] con lo que hay que decidir una sola vez para toda la
/// aplicación: qué se ve mientras se arrastra —una copia elevada, con sombra y
/// algo transparente— y cómo se queda lo que se dejó atrás —atenuado, para que
/// se vea de dónde salió y no parezca que ha desaparecido—.
///
/// No sabe de qué va lo que arrastra: [T] es del que lo usa. Está en `core/ui`
/// porque lo usan el árbol de modelos y, más adelante, arrastrar contenidos
/// sobre una etiqueta del menú.
class FernDraggableCard<T extends Object> extends StatelessWidget {
  /// Lo que viaja con el arrastre y le llega a quien lo recoja.
  final T data;

  final Widget child;

  /// Lo que se ve pegado al cursor. Sin decir nada, el propio [child].
  final Widget? feedback;

  /// Con `false` no se deja arrastrar y se comporta como su hijo a secas.
  final bool isEnabled;

  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  const FernDraggableCard({
    super.key,
    required this.data,
    required this.child,
    this.feedback,
    this.isEnabled = true,
    this.onDragStarted,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) return child;

    return Draggable<T>(
      data: data,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnd?.call(),
      onDraggableCanceled: (_, _) => onDragEnd?.call(),
      feedback: _Feedback(child: feedback ?? child),
      // Atenuado y no invisible: se ve de dónde salió, y si se suelta en un
      // sitio que no acepta, el ojo ya sabe a dónde vuelve.
      childWhenDragging: Opacity(opacity: draggingGhostOpacity, child: child),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: child,
      ),
    );
  }
}

/// La copia que va pegada al cursor.
class _Feedback extends StatelessWidget {
  final Widget child;

  const _Feedback({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: draggingFeedbackOpacity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: context.colors.scrim.withValues(alpha: 0.25),
                blurRadius: AppSizes.radiusLarge,
                offset: const Offset(0, AppSizes.borderRegular),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
