import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Pregunta antes de instalar la versión de tarjeta gráfica.
///
/// Merece un aviso porque la decisión no es gratis: se gana mucha velocidad al
/// entrenar, pero son varios gigas más de descarga y de disco, y en una conexión
/// normal eso es un buen rato. Es justo el tipo de cosa que hay que decir antes
/// y no después.
///
/// Devuelve `true` si se confirma y `null` si se cierra sin más.
Future<bool?> askForGpuInstall(BuildContext context) {
  return showFernDialog<bool, Never>(
    context: context,
    builder: (_) => const ConfirmGpuDialog(),
  );
}

class ConfirmGpuDialog extends StatelessWidget {
  const ConfirmGpuDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(texts.gpuDialogTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.l),
          _point(context, Symbols.speed, texts.gpuDialogBenefit),
          const SizedBox(height: AppSpacing.m),
          _point(context, Symbols.schedule, texts.gpuDialogTime),
          const SizedBox(height: AppSpacing.m),
          _point(context, Symbols.storage, texts.gpuDialogSize),
          const SizedBox(height: AppSpacing.l),
          Text(
            texts.gpuDialogReversible,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: context.colors.gray),
          ),
        ],
      ),
      actionButton: FernPillButton(
        label: texts.gpuDialogConfirm,
        icon: Symbols.bolt,
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.black,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }

  /// Una de las tres cosas que hay que saber, con su icono delante.
  Widget _point(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconMedium, color: context.colors.gray),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
