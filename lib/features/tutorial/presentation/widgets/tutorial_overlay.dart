import 'dart:math' as math;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_anchors.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_controller.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_step.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// El velo del tutorial: oscurece la pantalla, deja iluminado lo que toca y
/// cuenta qué es.
///
/// Va montado encima de toda la aplicación, así que cuando no hay tutorial no
/// ocupa nada ni se pone en medio de nada.
///
/// **Mientras está, no se puede tocar la aplicación.** Es a propósito: un
/// tutorial que deja pulsar por debajo se rompe en cuanto alguien navega a otra
/// pantalla, porque lo que estaba señalando deja de existir. Aquí se avanza con
/// el botón, con las flechas o con Escape, y al terminar la aplicación está
/// exactamente donde estaba.
class TutorialOverlay extends StatefulWidget {
  final TutorialController controller;

  const TutorialOverlay({super.key, required this.controller});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  /// Lo que se está señalando, ya medido. `null` en los pasos que no señalan a
  /// nada y en los que señalan a algo que no está montado.
  Rect? _spotlight;

  /// Por qué paso va la búsqueda en curso.
  ///
  /// Buscar dura varios fotogramas, así que un paso puede empezar a buscar antes
  /// de que el anterior haya terminado. Sin esto, la búsqueda vieja seguiría
  /// hasta el final y dejaría el foco donde señalaba el paso de antes.
  int _search = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStep);
  }

  @override
  void didUpdateWidget(TutorialOverlay old) {
    super.didUpdateWidget(old);
    if (old.controller == widget.controller) return;

    old.controller.removeListener(_onStep);
    widget.controller.addListener(_onStep);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStep);
    super.dispose();
  }

  /// Medir va **después** de pintar el paso, no durante.
  ///
  /// Lo que se señala puede haber entrado en pantalla en este mismo fotograma
  /// —una sección del menú que se despliega—, y preguntarle dónde está antes de
  /// que se haya colocado no devuelve nada. Con la medida en el fotograma
  /// siguiente siempre hay algo que medir.
  void _onStep() {
    if (!mounted) return;

    setState(() => _spotlight = null);

    _search++;
    _goToStepScreen();
    _measure(tutorialMeasureAttempts, _search);
  }

  /// Espera a que lo señalado **esté donde va a quedarse**, y entonces lo
  /// señala.
  ///
  /// Tres cosas tienen que cumplirse, y cada una tapa un agujero distinto:
  ///
  /// - **Que se esté ya en la pantalla del paso.** Mientras la ruta sigue siendo
  ///   la de antes, el ancla que hay registrada es la de la pantalla que se va, y
  ///   está perfectamente quieta en su sitio. Sin esta condición se remarcaba la
  ///   lista de la pantalla anterior.
  /// - **Que la pantalla haya terminado de entrar.** Se le pregunta a su propia
  ///   animación. Adivinarlo mirando si el sitio deja de cambiar no vale: justo
  ///   después de pedir la pantalla la animación no ha arrancado todavía, así que
  ///   dos fotogramas seguidos dan lo mismo y parece que ya está — que es lo que
  ///   dejaba el foco corrido a medio camino.
  /// - **Que el sitio se repita.** Lo de dentro puede colocarse un fotograma
  ///   después de que la pantalla haya llegado.
  ///
  /// Mientras tanto se va enseñando lo que se mide: seguir a lo que entra se lee
  /// como parte de la animación, y esperar quieto deja el foco apagado justo
  /// mientras se mira.
  ///
  /// Con un tope, que es lo que impide quedarse esperando para siempre algo que
  /// no va a aparecer —una fila del menú con el menú plegado—. Ahí no señalar es
  /// la respuesta correcta.
  void _measure(int attempts, int search, [Rect? previous]) {
    final step = widget.controller.step;
    final id = step?.anchorId;
    if (id == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || search != _search) return;

      final rect = TutorialAnchors.rectOf(id);
      final ready = _isOnStepScreen(step!) &&
          TutorialAnchors.isSettled(id) &&
          rect != null &&
          rect == previous;

      if (!ready && attempts > 1) {
        if (rect != null && rect != _spotlight) {
          setState(() => _spotlight = rect);
        }

        return _measure(attempts - 1, search, rect);
      }

      if (rect == _spotlight) return;

      setState(() => _spotlight = rect);
    });
  }

  /// Lleva a la pantalla del paso, si el paso pide una y no se está ya en ella.
  ///
  /// Es lo que permite que un recorrido cruce pantallas sin pedirle al usuario
  /// que pulse nada, que sería pedírselo con la aplicación bloqueada por el
  /// velo. Y navegar aquí es seguro precisamente por eso: mientras el tutorial
  /// dura, nadie más puede estar cambiando de pantalla.
  void _goToStepScreen() {
    final step = widget.controller.step;
    if (step == null || step.route == null || _isOnStepScreen(step)) return;

    context.go(step.route!);
  }

  /// Si ya se está en la pantalla que pide el paso. Los pasos que no piden
  /// ninguna se enseñan donde se esté, así que siempre lo están.
  bool _isOnStepScreen(TutorialStep step) {
    final route = step.route;
    if (route == null) return true;

    return GoRouterState.of(context).matchedLocation == route;
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.controller.step;
    if (step == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: Stack(
          children: [
            // Se come los clics para que nada de debajo responda mientras dura
            // el tutorial.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.controller.next,
                child: CustomPaint(
                  painter: TutorialSpotlightPainter(
                    spotlight: _spotlight,
                    color: context.colors.black
                        .withValues(alpha: tutorialScrimOpacity),
                    outline: context.colors.primary,
                  ),
                ),
              ),
            ),
            _card(context, step.title, step.body),
          ],
        ),
      ),
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        widget.controller.finish();
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
        widget.controller.next();
      case LogicalKeyboardKey.arrowLeft:
        widget.controller.back();
      default:
        return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  Widget _card(BuildContext context, String title, String body) {
    // Se coloca con el alto **de verdad** del cartel, no con uno estimado.
    //
    // Estimarlo es lo que lo sacaba de la pantalla: el texto de cada paso mide
    // lo que mide en el idioma en curso, y con un ancla alta —el menú lateral,
    // que ocupa toda la columna— la cuenta daba un sitio que empezaba por
    // encima del borde de arriba. `CustomSingleChildLayout` decide después de
    // medir, así que el cartel no puede acabar fuera.
    return Positioned.fill(
      child: CustomSingleChildLayout(
        delegate: _CardLayout(spotlight: _spotlight),
        child: _TutorialCard(
          controller: widget.controller,
          title: title,
          body: body,
        ),
      ),
    );
  }
}

/// Dónde cabe el cartel sin taparle a nadie lo que se está señalando.
///
/// Prueba los cuatro lados en orden —debajo, encima, a la derecha, a la
/// izquierda— y se queda con el primero en el que entra entero. Debajo primero
/// porque es donde se sigue leyendo; a los lados sólo cuando lo señalado es alto
/// y no deja franja arriba ni abajo, que es justo el caso del menú lateral.
///
/// Si no cabe en ninguno —lo señalado ocupa casi toda la pantalla, como la
/// rejilla— se pone en medio y encima. Ahí tapar no es un problema: lo señalado
/// es todo, así que da igual por dónde se mire.
class _CardLayout extends SingleChildLayoutDelegate {
  final Rect? spotlight;

  const _CardLayout({required this.spotlight});

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final space = constraints.biggest;

    return BoxConstraints.loose(Size(
      math.min(tutorialCardWidth, space.width - AppSpacing.l * 2),
      math.max(space.height - AppSpacing.l * 2, 0),
    ));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final centred = Offset(
      (size.width - childSize.width) / 2,
      (size.height - childSize.height) / 2,
    );

    final focus = spotlight;
    if (focus == null) return centred;

    // Los topes de cada eje, ya cruzados: en una ventana más pequeña que el
    // cartel el mínimo se pasaría del máximo y `clamp` revienta.
    double x(double value) => _clamp(value, size.width - childSize.width);
    double y(double value) => _clamp(value, size.height - childSize.height);

    final centreX = x(focus.center.dx - childSize.width / 2);
    final centreY = y(focus.center.dy - childSize.height / 2);

    final below = focus.bottom + tutorialCardGap;
    if (below + childSize.height <= size.height - AppSpacing.l) {
      return Offset(centreX, below);
    }

    final above = focus.top - tutorialCardGap - childSize.height;
    if (above >= AppSpacing.l) return Offset(centreX, above);

    final right = focus.right + tutorialCardGap;
    if (right + childSize.width <= size.width - AppSpacing.l) {
      return Offset(right, centreY);
    }

    final left = focus.left - tutorialCardGap - childSize.width;
    if (left >= AppSpacing.l) return Offset(left, centreY);

    return centred;
  }

  /// Entre el margen y lo que quede, sin que los dos topes se crucen.
  static double _clamp(double value, double most) =>
      most <= AppSpacing.l * 2 ? most / 2 : value.clamp(AppSpacing.l, most - AppSpacing.l);

  @override
  bool shouldRelayout(_CardLayout old) => old.spotlight != spotlight;
}

/// El cartel que cuenta el paso: por dónde va, qué es esto y cómo seguir.
class _TutorialCard extends StatelessWidget {
  final TutorialController controller;
  final String title;
  final String body;

  const _TutorialCard({
    required this.controller,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);
    final colors = context.colors;

    return FernSurface.raised(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            texts.tutorialProgress(controller.position, controller.total),
            style: theme.textTheme.labelSmall?.copyWith(color: colors.gray),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.gray),
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              // Salir está siempre a la vista y siempre en el mismo sitio: un
              // tutorial del que no se ve cómo salir deja de ser opcional.
              TextButton(
                onPressed: controller.finish,
                child: Text(texts.tutorialSkip),
              ),
              const Spacer(),
              if (!controller.isFirst)
                TextButton(
                  onPressed: controller.back,
                  child: Text(texts.tutorialBack),
                ),
              const SizedBox(width: AppSpacing.s),
              FernPillButton(
                label:
                    controller.isLast ? texts.tutorialDone : texts.tutorialNext,
                icon:
                    controller.isLast ? Symbols.check : Symbols.arrow_forward,
                backgroundColor: colors.primary,
                foregroundColor: colors.black,
                onPressed: controller.next,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Oscurece la pantalla entera menos el trozo que se está señalando.
///
/// Público sólo para poder comprobar **a dónde** ha acabado señalando: es el
/// único sitio donde vive esa respuesta, y es justo lo que se rompía cuando se
/// medía a media animación de entrada.
///
/// Se pinta como **un solo relleno con un agujero** y no como cuatro rectángulos
/// alrededor: con cuatro, las juntas se notan como líneas más claras y el
/// redondeo del agujero no se puede hacer.
class TutorialSpotlightPainter extends CustomPainter {
  final Rect? spotlight;
  final Color color;
  final Color outline;

  const TutorialSpotlightPainter({
    required this.spotlight,
    required this.color,
    required this.outline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final screen = Offset.zero & size;
    final focus = spotlight?.inflate(tutorialSpotlightPadding);

    if (focus == null) {
      canvas.drawRect(screen, Paint()..color = color);

      return;
    }

    final hole = RRect.fromRectAndRadius(
      focus,
      const Radius.circular(tutorialSpotlightRadius),
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(screen),
        Path()..addRRect(hole),
      ),
      Paint()..color = color,
    );

    // Un trazo alrededor del agujero: sin él, sobre una zona ya clara el foco no
    // se distingue del resto de la pantalla.
    canvas.drawRRect(
      hole,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppSizes.borderRegular
        ..color = outline,
    );
  }

  @override
  bool shouldRepaint(TutorialSpotlightPainter old) =>
      old.spotlight != spotlight ||
      old.color != color ||
      old.outline != outline;
}
