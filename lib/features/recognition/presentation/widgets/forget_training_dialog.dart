import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Confirma que se olvida lo entrenado de un modelo.
///
/// Se pregunta porque **los pesos no vuelven**: entrenar otra vez son horas, y
/// pulsarlo por error en el modelo equivocado no tiene deshacer.
///
/// Y se dice lo que **se queda**, que es la mitad del sentido de esto: los
/// hiperparámetros, los fernies y el reparto no tienen nada de malo, y perderlos
/// era justo lo que obligaba a borrar el modelo entero y volver a montarlo.
class ForgetTrainingDialog extends StatelessWidget {
  /// Cómo se llama el modelo, para decir sobre cuál se está preguntando.
  final String modelName;

  const ForgetTrainingDialog({super.key, required this.modelName});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(false),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      leftContent: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texts.modelForgetTrainingTitle(modelName),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              texts.modelForgetTrainingLoses,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.modelForgetTrainingKeeps,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.colors.gray,
              ),
            ),
          ],
        ),
      ),
      actionButton: FernPillButton(
        label: texts.modelForgetTrainingAction,
        icon: Symbols.delete_history,
        backgroundColor: context.colors.error,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
