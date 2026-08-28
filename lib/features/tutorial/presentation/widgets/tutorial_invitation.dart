import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Lo que sale la primera vez que se abre la aplicación: si se quiere una vuelta
/// guiada.
///
/// **Es una pregunta, no el tutorial.** Arrancar solo un recorrido de ocho pasos
/// sobre alguien que acaba de abrir la aplicación es empezar quitándole el
/// mando; y quien ya sabe lo que quiere hacer no tiene por qué salir de nada.
///
/// Devuelve si se ha aceptado. Sin contestar —cerrando— cuenta como que no, y de
/// todas formas se da por ofrecido: para volver a verlo está el botón de los
/// ajustes.
Future<bool> askForTutorial(BuildContext context) async {
  final accepted = await showFernDialog<bool, Never>(
    context: context,
    builder: (_) => const TutorialInvitation(),
  );

  return accepted ?? false;
}

class TutorialInvitation extends StatelessWidget {
  const TutorialInvitation({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(false),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(texts.tutorialOfferTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Text(
            texts.tutorialOfferBody,
            style:
                theme.textTheme.bodyMedium?.copyWith(color: context.colors.gray),
          ),
        ],
      ),
      // Rechazar va como texto y aceptar como botón, pero los dos están a la
      // vista y ninguno cuesta más que el otro: no es una decisión de la que
      // haya que disuadir a nadie.
      trailingAction: TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(texts.tutorialOfferDecline),
      ),
      actionButton: FernPillButton(
        label: texts.tutorialOfferAccept,
        icon: Symbols.play_arrow,
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.black,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
