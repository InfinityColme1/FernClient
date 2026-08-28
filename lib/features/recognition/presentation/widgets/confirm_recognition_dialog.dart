import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Avisa de que lo que se va a reconocer saldrá de la biblioteca.
///
/// El efecto sorprende y por eso hay aviso: quien manda a reconocer veinte
/// contenidos vuelve a la rejilla y se los encuentra vacíos, sin nada que
/// explique por qué. Es la decisión D16 —una sugerencia sin validar es contenido
/// a medias— pero eso hay que decirlo **antes**, no después.
///
/// Sólo avisa de lo que va a pasar de verdad: si el ajuste está apagado, este
/// diálogo no llega a abrirse.
class ConfirmRecognitionDialog extends StatelessWidget {
  /// Cuántos contenidos se van a mandar.
  final int count;

  const ConfirmRecognitionDialog({super.key, required this.count});

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
          Text(texts.recognizeReturnTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.m),
          Text(
            texts.recognizeReturnWarning(count),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          // Dónde se apaga, dicho aquí mismo: mandar a alguien a buscarlo por los
          // ajustes cuando acaba de ver el aviso es hacerle el trabajo dos veces.
          Text(
            texts.recognizeReturnHint,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: context.colors.unremarked),
          ),
        ],
      ),
      actionButton: FernPillButton(
        label: texts.recognizeReturnConfirm,
        icon: Symbols.auto_awesome,
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.black,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
