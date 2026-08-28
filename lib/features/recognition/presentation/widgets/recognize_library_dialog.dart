import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Cuánto de la biblioteca hay que mirar.
enum RecognitionScope {
  /// Sólo lo que no se ha reconocido nunca.
  onlyUnrecognized,

  /// Todo, otra vez.
  everything,
}

/// Pregunta cuánto de la biblioteca hay que reconocer.
///
/// Se pregunta y no se decide por el usuario porque las dos respuestas son
/// legítimas y cuestan cosas muy distintas: una predicción por imagen y varias
/// por vídeo, en una biblioteca que puede tener decenas de miles. Lanzarlo sobre
/// todo sin avisar puede dejar el equipo trabajando horas.
///
/// Los dos recuentos van escritos porque son lo que decide: «lo nuevo» puede ser
/// tres contenidos o quince mil, y no hay forma de saberlo desde fuera.
class RecognizeLibraryDialog extends StatelessWidget {
  /// Cuántos no se han mirado nunca.
  final int unrecognized;

  /// Cuántos hay en total.
  final int total;

  const RecognizeLibraryDialog({
    super.key,
    required this.unrecognized,
    required this.total,
  });

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
          Text(
            texts.recognizeLibraryTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            texts.recognizeLibraryQuestion,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: context.colors.unremarked),
          ),
          const SizedBox(height: AppSpacing.l),
          FernPillButton(
            label: '${texts.recognizeLibraryOnlyNew} '
                '(${texts.recognizeCountable(unrecognized)})',
            icon: Symbols.auto_awesome,
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.black,
            // Sin nada nuevo el botón no sirve de nada, y dejarlo pulsable sólo
            // sirve para que alguien lo pulse y no pase nada.
            onPressed: unrecognized == 0
                ? null
                : () => Navigator.of(context)
                    .pop(RecognitionScope.onlyUnrecognized),
          ),
          const SizedBox(height: AppSpacing.m),
          FernPillButton(
            label: '${texts.recognizeLibraryAll} '
                '(${texts.recognizeCountable(total)})',
            icon: Symbols.refresh,
            backgroundColor: context.colors.secondary,
            foregroundColor: context.colors.black,
            onPressed: total == 0
                ? null
                : () =>
                    Navigator.of(context).pop(RecognitionScope.everything),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            texts.recognizeLibraryAllHint,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: context.colors.unremarked),
          ),
        ],
      ),
    );
  }
}
