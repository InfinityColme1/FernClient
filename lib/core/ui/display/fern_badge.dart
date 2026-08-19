import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// La bolita con un número que se pone sobre un botón para decir cuánto hay
/// pendiente allí.
///
/// Pasado [maxCount] deja de decir el número exacto y pasa a "+99": lo que
/// importa a partir de ahí es que hay mucho, y tres cifras no caben.
///
/// Con [count] a cero no se pinta nada, así que quien la usa puede ponerla
/// siempre y olvidarse de si toca o no.
class FernBadge extends StatelessWidget {
  final int count;
  final int maxCount;

  /// El botón sobre el que va. Si no se pasa, la bolita se pinta sola.
  final Widget? child;

  const FernBadge({
    super.key,
    required this.count,
    this.maxCount = 99,
    this.child,
  });

  String get _label => count > maxCount ? '+$maxCount' : '$count';

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child ?? const SizedBox.shrink();

    final dot = Container(
      constraints: const BoxConstraints(minWidth: AppSizes.badgeMinWidth),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.colors.terciary,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        _label,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: context.colors.white, fontWeight: FontWeight.w600),
      ),
    );

    if (child == null) return dot;

    // Se sale un poco por la esquina superior derecha del botón, que es donde
    // se espera encontrarla y donde no tapa el icono.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        Positioned(
          top: -AppSpacing.xs,
          right: -AppSpacing.s,
          child: dot,
        ),
      ],
    );
  }
}
