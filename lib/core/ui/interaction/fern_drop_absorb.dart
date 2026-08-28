import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/display/fern_motion.dart';
import 'package:Fern/core/ui/interaction/fern_drag_watch.dart';
import 'package:flutter/material.dart';

/// Lo que se acaba de soltar, viajando hasta meterse dentro de donde ha caído.
///
/// **Por qué hace falta.** Al soltar contenido sobre una etiqueta, la miniatura
/// que iba pegada al cursor desaparecía en el sitio y la etiqueta seguía igual.
/// El contenido se etiquetaba de verdad, pero no había nada que lo dijera: había
/// que ir a mirar. Verlo entrar es la confirmación, y llega antes que cualquier
/// aviso escrito.
///
/// Se pinta en la capa de encima de todo y se quita sola. No toca el árbol de
/// nadie: ni la fila que recoge ni la rejilla de la que salió se enteran de que
/// esto existe.
void playFernDropAbsorb({
  required BuildContext context,
  required Offset pointer,
}) {
  final preview = fernDragPreview.value;
  if (preview == null) return;

  // Con «reducir movimiento» puesto no se pinta nada: lo que se ahorra aquí es
  // justo lo que molesta, y la acción ya ha ocurrido de todas formas.
  if (context.prefersStillness) return;

  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return;

  // De dónde sale: el centro de la miniatura, que va colgada del cursor con su
  // separación. Del cursor a secas saldría de una esquina.
  final desde = pointer +
      const Offset(dragFeedbackCursorGap, dragFeedbackCursorGap) +
      const Offset(dragFeedbackSize / 2, dragFeedbackSize / 2);

  final hasta = box.localToGlobal(box.size.center(Offset.zero));

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Absorbed(
      from: desde,
      to: hasta,
      onDone: entry.remove,
      child: preview,
    ),
  );

  overlay.insert(entry);
}

/// La miniatura viajando de donde se soltó a donde ha caído.
class _Absorbed extends StatefulWidget {
  final Offset from;
  final Offset to;
  final Widget child;
  final VoidCallback onDone;

  const _Absorbed({
    required this.from,
    required this.to,
    required this.child,
    required this.onDone,
  });

  @override
  State<_Absorbed> createState() => _AbsorbedState();
}

class _AbsorbedState extends State<_Absorbed>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: motionEmphasized,
  );

  late final Animation<double> _curved = CurvedAnimation(
    parent: _controller,
    curve: motionEnterCurve,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // El `Stack` es imprescindible: lo que se coloca con `Positioned` tiene que
    // colgar directamente de uno. Sin él no se pinta nada — que es exactamente
    // lo que pasaba.
    return IgnorePointer(
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _curved,
            // La miniatura se construye una vez: lo que cambia en cada fotograma
            // es dónde y cómo se pinta, no lo que se pinta.
            child: SizedBox(
              width: dragFeedbackSize,
              height: dragFeedbackSize,
              child: widget.child,
            ),
            builder: (context, child) {
              final t = _curved.value;
              final centro = Offset.lerp(widget.from, widget.to, t)!;

              // Encoge hasta casi nada y se apaga al final: se lee como que
              // entra, no como que se cae.
              final escala = 1.0 - (1.0 - dropAbsorbEndScale) * t;

              return Positioned(
                left: centro.dx - dragFeedbackSize / 2,
                top: centro.dy - dragFeedbackSize / 2,
                width: dragFeedbackSize,
                height: dragFeedbackSize,
                child: Opacity(
                  // Se mantiene entera casi todo el viaje y se apaga al final:
                  // apagándose desde el principio no se llega a ver llegar.
                  opacity: (1.0 - t * t).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: escala,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                      child: child,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
