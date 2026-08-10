import 'package:Fern/config/theme/app_sizes.dart';
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
    return Container(
      width: width,
      height: height,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).secondaryHeaderColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
