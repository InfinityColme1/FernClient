import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Estructura común de los diálogos de la aplicación: botón de cierre arriba a
/// la izquierda, dos columnas de contenido y una acción abajo a la derecha.
class FernDialog extends StatelessWidget {
  final Widget? leftContent;
  final Widget? rightContent;
  final Widget? actionButton;
  final VoidCallback onClose;
  final double maxWidth;
  final double columnSpacing;

  const FernDialog({
    super.key,
    this.leftContent,
    this.rightContent,
    this.actionButton,
    required this.onClose,
    this.maxWidth = AppSizes.dialogMaxWidth,
    this.columnSpacing = AppSpacing.xxxl,
  });

  @override
  Widget build(BuildContext context) {
    final hasBothColumns = leftContent != null && rightContent != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusDialog),
      ),
      backgroundColor: AppColors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: AppSpacing.dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, size: AppSizes.iconExtraLarge),
                  onPressed: onClose,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (leftContent != null)
                      Expanded(flex: 1, child: leftContent!),
                    if (hasBothColumns) SizedBox(width: columnSpacing),
                    if (rightContent != null)
                      Expanded(flex: 1, child: rightContent!),
                  ],
                ),
              ),
              if (actionButton != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                Align(
                  alignment: Alignment.bottomRight,
                  child: actionButton!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
