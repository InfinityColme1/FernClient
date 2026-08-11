import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Botón compacto con icono y texto, usado en las cabeceras de las pantallas.
///
/// Con `onPressed` a `null` queda desactivado: conserva sus colores, pero
/// atenuados, para que se siga leyendo de qué botón se trata.
class FernPillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;
  final double height;

  const FernPillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onPressed,
    this.height = AppSizes.buttonHeightSmall,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final effectiveForeground = isEnabled
        ? foregroundColor
        : foregroundColor.withValues(alpha: pillButtonDisabledOpacity);

    return SizedBox(
      height: height,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: AppSizes.iconCompact, color: effectiveForeground),
        label: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: effectiveForeground),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor:
              backgroundColor.withValues(alpha: pillButtonDisabledOpacity),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
        ),
      ),
    );
  }
}
