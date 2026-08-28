import 'dart:async';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Indicador circular de espera de la aplicación.
///
/// Es el único sitio donde se decide cómo se ve una espera: sale siempre igual
/// esté donde esté, y con dos tamaños, el normal y el de dentro de otra cosa
/// ([FernProgressIndicator.small]) —un botón, un campo o una cabecera—.
class FernProgressIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;

  /// Color del trazo. Sin él usa el del tema, que es el de la aplicación; se pasa
  /// en los sitios que tienen su propio fondo y necesitan otro (el visor, que va
  /// sobre negro, o un botón de color).
  final Color? color;

  const FernProgressIndicator({
    super.key,
    this.size = AppSizes.progressIndicator,
    this.strokeWidth = progressStrokeWidth,
    this.color,
  });

  const FernProgressIndicator.small({super.key, this.color})
      : size = AppSizes.progressIndicatorSmall,
        strokeWidth = progressSmallStrokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}

/// Lo que se está mirando, con el indicador de espera encima mientras haya una
/// operación en marcha.
///
/// El contenido anterior se queda a la vista, atenuado: así se entiende que
/// sigue ahí y que lo que pasa es que hay que esperar. Mientras el velo está
/// puesto no se puede pulsar nada de lo que tapa, que es contenido que está a
/// punto de cambiar.
///
/// **No aparece si la espera es corta.** Casi todo lo que hace esperar aquí
/// —leer la biblioteca, escribir una etiqueta— se resuelve en unas decenas de
/// milisegundos, y un velo que se levanta y cae en ese tiempo no informa de
/// nada: sólo se ve como un parpadeo. Se le da un margen ([busyOverlayDelay]) y
/// sólo si la cosa sigue en marcha después se enseña.
class FernBusyOverlay extends StatefulWidget {
  final bool isBusy;
  final Widget child;

  /// Color del velo. Sin decir nada, el fondo de la aplicación.
  final Color? color;

  /// Redondeo del velo, para que no asome por las esquinas de la superficie que
  /// tapa.
  final double radius;

  /// Color del trazo del indicador, para los fondos que no son el de la
  /// aplicación.
  final Color? indicatorColor;

  /// Lo que se ofrece mientras se espera, encima del indicador: por ejemplo, el
  /// botón que para lo que se está haciendo.
  ///
  /// A diferencia de lo que hay debajo del velo, esto sí se puede pulsar: es lo
  /// único que tiene sentido hacer mientras dura la espera.
  final Widget? action;

  const FernBusyOverlay({
    super.key,
    required this.isBusy,
    required this.child,
    this.color,
    this.radius = AppSizes.radiusSurface,
    this.indicatorColor,
    this.action,
  });

  @override
  State<FernBusyOverlay> createState() => _FernBusyOverlayState();
}

class _FernBusyOverlayState extends State<FernBusyOverlay> {
  /// Si ya toca enseñarlo: la espera ha durado lo suficiente.
  bool _isShowing = false;

  Timer? _pending;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(FernBusyOverlay old) {
    super.didUpdateWidget(old);
    if (old.isBusy != widget.isBusy) _sync();
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }

  void _sync() {
    _pending?.cancel();

    if (!widget.isBusy) {
      // Al terminar se quita en el acto: lo que estorba es que aparezca tarde,
      // no que se vaya pronto.
      if (_isShowing) setState(() => _isShowing = false);

      return;
    }

    _pending = Timer(busyOverlayDelay, () {
      if (mounted) setState(() => _isShowing = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isShowing;
    final color = widget.color;
    final radius = widget.radius;
    final indicatorColor = widget.indicatorColor;
    final action = widget.action;
    final child = widget.child;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: isBusy ? 1.0 : 0.0),
            duration: busyOverlayFadeDuration,
            builder: (context, progress, child) {
              // Sin velo no hay nada que pintar ni nada que estorbe: el
              // indicador deja incluso de animarse, que no se está esperando.
              if (progress == 0) return const SizedBox.shrink();

              return Opacity(opacity: progress, child: child);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Mientras se espera, el velo se queda con las pulsaciones: lo
                // que hay debajo es contenido a punto de cambiar. Cuando el velo
                // ya se está yendo deja de estorbar, aunque todavía se vea.
                AbsorbPointer(
                  absorbing: isBusy,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: (color ?? context.colors.background)
                          .withValues(alpha: busyOverlayOpacity),
                      borderRadius: BorderRadius.circular(radius),
                    ),
                  ),
                ),
                // El indicador y lo que se ofrezca con él van por encima del
                // velo y fuera de lo que absorbe: si no, el botón de parar
                // quedaría tapado por el mismo velo que lo enseña.
                IgnorePointer(
                  ignoring: !isBusy,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (action case final action?) ...[
                          action,
                          const SizedBox(height: AppSpacing.s),
                        ],
                        FernProgressIndicator(color: indicatorColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
