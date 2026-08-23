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

  /// Acción secundaria de la esquina superior derecha, enfrente del botón de
  /// cierre. Es donde va lo que abre otro diálogo sobre este (vincular las
  /// direcciones de una etiqueta, por ejemplo): no confirma ni cancela lo que se
  /// está haciendo, así que no tiene sitio en la fila de abajo, y lejos del aspa
  /// para que no se pulse una por otra.
  final Widget? trailingAction;

  const FernDialog({
    super.key,
    this.leftContent,
    this.rightContent,
    this.actionButton,
    required this.onClose,
    this.trailingAction,
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
      backgroundColor: context.colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: AppSpacing.dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: AppSizes.iconExtraLarge),
                    onPressed: onClose,
                  ),
                  const Spacer(),
                  if (trailingAction != null) trailingAction!,
                ],
              ),
              // Flexible y no fijo: es la parte que tiene que ceder cuando el
              // diálogo no cabe. La cabecera y el botón de acción ocupan lo que
              // ocupan y no se pueden encoger.
              Flexible(
                child: Padding(
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
