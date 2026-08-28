import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/display/fern_motion.dart';
import 'package:flutter/material.dart';

/// El hueco de algo que todavía está llegando.
///
/// **Por qué no un círculo girando.** Un indicador de espera dice «espera» y nada
/// más; el hueco dice además **qué** va a aparecer y cuánto va a ocupar, así que
/// cuando llega el contenido no se recoloca la pantalla entera de golpe. Es lo
/// que separa una espera que se sufre de una que no se nota.
///
/// Se usa donde lo que se espera tiene forma conocida —una rejilla de
/// miniaturas, una lista de filas—. Donde no se sabe qué va a venir, el círculo
/// sigue siendo lo honesto.
class FernSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;

  /// Si late.
  ///
  /// **Apagarlo importa más de lo que parece.** Cada hueco que late es una
  /// animación en marcha, y hay un momento en el que la rejilla se llena de
  /// huecos de golpe: mientras se desplaza deprisa. Justo ahí, decenas de
  /// animaciones a la vez es lo contrario de lo que hace falta — y además un
  /// campo de cuadros latiendo mientras se pasa de largo no lo mira nadie.
  final bool isPulsing;

  const FernSkeleton({
    super.key,
    this.width,
    this.height,
    this.radius = AppSizes.radiusMedium,
    this.isPulsing = true,
  });

  @override
  State<FernSkeleton> createState() => _FernSkeletonState();
}

class _FernSkeletonState extends State<FernSkeleton>
    with SingleTickerProviderStateMixin {
  /// Sólo existe si de verdad late: un controlador parado sigue costando un
  /// `Ticker` registrado por cada celda.
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _syncController();
  }

  @override
  void didUpdateWidget(FernSkeleton old) {
    super.didUpdateWidget(old);
    if (old.isPulsing != widget.isPulsing) _syncController();
  }

  void _syncController() {
    if (!widget.isPulsing) {
      _controller?.dispose();
      _controller = null;

      return;
    }

    _controller ??= AnimationController(
      vsync: this,
      duration: skeletonPulseDuration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.secondary,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      child: SizedBox(width: widget.width, height: widget.height),
    );

    // Con «reducir movimiento» puesto se queda el hueco quieto. Un latido no se
    // puede acortar: se repite solo, así que o no está o sigue molestando.
    final controller = _controller;
    if (controller == null || context.prefersStillness) return box;

    return AnimatedBuilder(
      animation: controller,
      child: box,
      builder: (context, child) => Opacity(
        opacity: Tween<double>(
          begin: skeletonMinOpacity,
          end: 1.0,
        ).transform(Curves.easeInOut.transform(controller.value)),
        child: child,
      ),
    );
  }
}

/// Una rejilla de huecos, con la forma de la de contenido.
///
/// Las alturas se alternan a propósito: la rejilla de verdad es de mampostería y
/// sus celdas no miden todas lo mismo, así que un cuadriculado perfecto se
/// delataría como lo que es y daría un salto al llegar el contenido.
class FernSkeletonGrid extends StatelessWidget {
  final int columns;
  final int count;

  const FernSkeletonGrid({
    super.key,
    required this.columns,
    this.count = skeletonGridCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.gridInset),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: AppSpacing.s,
        crossAxisSpacing: AppSpacing.s,
        childAspectRatio: 1,
      ),
      itemCount: count,
      itemBuilder: (context, index) => Align(
        alignment: Alignment.topCenter,
        child: FernSkeleton(
          width: double.infinity,
          // Tres alturas que se van turnando: ni todas iguales ni al azar, que
          // al reconstruirse cambiarían de tamaño mientras se espera.
          height: skeletonCellHeights[index % skeletonCellHeights.length],
          radius: AppSizes.radiusLarge,
        ),
      ),
    );
  }
}
