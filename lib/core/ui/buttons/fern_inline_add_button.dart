import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Versión menuda de `FernAddButton`: el "+" y la etiqueta en una sola línea.
///
/// Se usa para añadir campos dentro de un formulario, donde el botón redondo
/// con etiqueta debajo pesaría demasiado.
class FernInlineAddButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData icon;

  const FernInlineAddButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      mouseCursor: WidgetStateMouseCursor.clickable,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.black, width: 1.5),
              ),
              child: Icon(
                icon,
                size: AppSizes.iconSmall,
                color: AppColors.black,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
