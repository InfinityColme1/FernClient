import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Botón circular con un "+" y una etiqueta, en dos variantes:
///
/// * la de por defecto, con la etiqueta debajo del círculo;
/// * [FernAddButton.inline], con la etiqueta al lado, para que encaje en un
///   listado vertical de filas con avatar (las etiquetas del panel de
///   información, por ejemplo).
class FernAddButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData icon;

  /// Etiqueta al lado del círculo en lugar de debajo.
  final bool isInline;

  const FernAddButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon = Icons.add,
  }) : isInline = false;

  const FernAddButton.inline({
    super.key,
    required this.label,
    this.onTap,
    this.icon = Icons.add,
  }) : isInline = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final circle = Container(
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.black, width: 2),
      ),
      child: Icon(
        icon,
        size: AppSizes.iconLarge,
        color: AppColors.black,
      ),
    );

    return InkWell(
      onTap: onTap,
      mouseCursor: WidgetStateMouseCursor.clickable,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: isInline
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                circle,
                const SizedBox(width: AppSpacing.m),
                Text(label, style: theme.textTheme.bodyMedium),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                circle,
                const SizedBox(height: AppSpacing.xs),
                Text(label, style: theme.textTheme.labelSmall),
              ],
            ),
    );
  }
}
