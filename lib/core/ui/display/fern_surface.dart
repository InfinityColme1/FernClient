import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/ui/display/fern_surface_color.dart';
import 'package:flutter/material.dart';


class FernSurface extends StatelessWidget {
  final double radius;
  final Widget? child;
  final Color? color;
  final Clip clipBehavior;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const FernSurface({
    super.key,
    this.radius = AppSizes.radiusSurface,
    this.child,
    this.color,
    this.clipBehavior = Clip.none,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final surface = color ?? Theme.of(context).secondaryHeaderColor;

    return Container(
      width: width,
      height: height,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
      ),
      // Lo que se pinte encima puede necesitar saber de qué color es esto: la
      // etiqueta flotante de un campo tapa el borde con el color de su fondo, y
      // un widget no puede averiguarlo por su cuenta.
      // El hijo es opcional: una superficie sin nada dentro es un hueco, y ahí
      // no hay a quién decirle nada.
      child: child == null
          ? null
          : FernSurfaceColor(color: surface, child: child!),
    );
  }
}
