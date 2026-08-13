import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
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
class FernBusyOverlay extends StatelessWidget {
  final bool isBusy;
  final Widget child;

  /// Color del velo. Por defecto el fondo de la aplicación.
  final Color color;

  /// Redondeo del velo, para que no asome por las esquinas de la superficie que
  /// tapa.
  final double radius;

  /// Color del trazo del indicador, para los fondos que no son el de la
  /// aplicación.
  final Color? indicatorColor;

  const FernBusyOverlay({
    super.key,
    required this.isBusy,
    required this.child,
    this.color = AppColors.background,
    this.radius = AppSizes.radiusSurface,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
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

              // Mientras se espera, el velo se queda con las pulsaciones: lo que
              // hay debajo es contenido a punto de cambiar. Cuando el velo ya se
              // está yendo deja de estorbar, aunque todavía se vea.
              return AbsorbPointer(
                absorbing: isBusy,
                child: Opacity(opacity: progress, child: child),
              );
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: busyOverlayOpacity),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Center(
                child: FernProgressIndicator(color: indicatorColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
