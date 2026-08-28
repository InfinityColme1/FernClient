import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/interaction/fern_drag_watch.dart';
import 'package:flutter/material.dart';

/// Algo que se puede arrastrar a otro sitio.
///
/// Envuelve a [Draggable] con lo que hay que decidir una sola vez para toda la
/// aplicación: qué se ve mientras se arrastra —una copia elevada, con sombra y
/// algo transparente— y cómo se queda lo que se dejó atrás —atenuado, para que
/// se vea de dónde salió y no parezca que ha desaparecido—.
///
/// No sabe de qué va lo que arrastra: [T] es del que lo usa. Está en `core/ui`
/// porque lo usan el árbol de modelos y arrastrar contenidos sobre una etiqueta
/// del menú.
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

  /// Se acabó el arrastre, salga bien o mal.
  void _finish() {
    // Si el arrastre termina en el aire, nadie ha avisado de que se ha salido
    // del sitio donde se podía soltar: se apaga aquí, que es lo único por lo que
    // pasan todos los finales.
    fernDragIsOverTarget.value = false;
    // La miniatura se olvida **en el fotograma siguiente**: quien recoge la
    // necesita todavía para pintar cómo el contenido entra dentro, y su aviso
    // llega en este mismo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fernDragPreview.value = null;
    });
    onDragEnd?.call();
  }

  /// Empieza el arrastre: se apunta qué se está llevando.
  void _start() {
    fernDragPreview.value = feedback ?? child;
    onDragStarted?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) return child;

    return Draggable<T>(
      data: data,
      onDragStarted: _start,
      onDragEnd: (_) => _finish(),
      onDraggableCanceled: (_, _) => _finish(),
      // **La miniatura se cuelga del cursor, no de dónde se agarró.**
      //
      // De fábrica, `Draggable` conserva el punto por el que se agarró el hijo:
      // agarrando una celda grande por su esquina derecha, la miniatura —que es
      // pequeña— se dibuja desplazada por esa misma distancia, así que el cursor
      // se queda fuera de ella. Arrastrando hacia el menú lateral se iba tan
      // lejos que parecía que había desaparecido.
      dragAnchorStrategy: pointerDragAnchorStrategy,
      // **En la capa de encima de todo, no en la de la pantalla.**
      //
      // De fábrica la miniatura se pinta en la capa más cercana, que aquí es la
      // del armazón de navegación: ésa ocupa sólo la zona de contenido, a la
      // derecha del menú lateral. Por eso la miniatura se cortaba en seco justo
      // al salir de la rejilla — y el sitio al que se arrastra, las etiquetas,
      // está precisamente al otro lado de ese borde.
      rootOverlay: true,
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
///
/// Cuelga abajo y a la derecha en vez de ir centrada: centrada taparía justo lo
/// que hay debajo del cursor, que es la etiqueta a la que se está apuntando.
///
/// Y **encoge y se oscurece al llegar a un sitio donde se puede soltar**. Es lo
/// que dice «esto entra aquí» sin escribirlo, y de paso destapa el destino justo
/// cuando hace falta verlo.
class _Feedback extends StatelessWidget {
  final Widget child;

  const _Feedback({required this.child});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(dragFeedbackCursorGap, dragFeedbackCursorGap),
      child: Material(
        color: Colors.transparent,
        child: ValueListenableBuilder<bool>(
          valueListenable: fernDragIsOverTarget,
          builder: (context, isOverTarget, child) => AnimatedScale(
            scale: isOverTarget ? dragOverTargetScale : 1.0,
            duration: hoverAnimationDuration,
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: draggingFeedbackOpacity,
              duration: hoverAnimationDuration,
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
                child: Stack(
                  children: [
                    child!,
                    // El velo va encima y recortado igual que la miniatura, para
                    // que oscurezca lo que se ve y no el hueco de alrededor.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: isOverTarget ? dragOverTargetShade : 0,
                          duration: hoverAnimationDuration,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.colors.scrim,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusLarge),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
