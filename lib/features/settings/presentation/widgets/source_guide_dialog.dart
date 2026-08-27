import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/domain/entities/source_guide.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Cómo conectar Fern con una fuente remota, paso a paso.
///
/// Cada plataforma pide una cosa distinta y ninguna se puede evitar: unas
/// quieren que registres una aplicación, otras una clave de su ficha y otras que
/// entres tú porque tienen captcha. Lo que sí está en nuestra mano es que no
/// haya que buscar cómo se hace en ningún otro sitio, que es lo que desanima
/// antes de empezar.
///
/// Dos cosas son iguales en todas y por eso viven aquí y no en cada guía:
///
/// - **El paso que se falla va destacado.** Siempre es del mismo tipo: uno que
///   la otra web deja pasar sin quejarse y que rompe todo lo demás en silencio.
/// - **Lo que hay que copiar se copia.** Se escriben mal, y el error no se ve
///   por ninguna parte.
class SourceGuideDialog extends StatelessWidget {
  final SourceGuide guide;

  const SourceGuideDialog({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth,
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(guide.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            guide.intro,
            style:
                theme.textTheme.bodyMedium?.copyWith(color: context.colors.gray),
          ),
          const SizedBox(height: AppSpacing.l),
          // Lo que quede de alto, y con desplazamiento: son varios pasos y una
          // ventana pequeña no tiene por qué caberlos todos de una vez.
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (index, step) in guide.steps.indexed)
                    _step(context, index + 1, step),
                  if (guide.notes.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s),
                    for (final note in guide.notes) ...[
                      _note(context, note),
                      const SizedBox(height: AppSpacing.s),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      actionButton: FernPillButton(
        label: guide.openLabel,
        icon: Icons.travel_explore_outlined,
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.black,
        onPressed: () {
          final router = GoRouter.of(context);
          Navigator.of(context).pop();
          router.go(browserRouteWithUrl(guide.openUrl));
        },
      ),
    );
  }

  Widget _step(BuildContext context, int number, SourceGuideStep step) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _number(context, number, highlight: step.isCritical),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: step.isCritical ? FontWeight.w600 : null,
                  ),
                ),
                if (step.copyable case final value?) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _copyable(context, value),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _number(BuildContext context, int number, {bool highlight = false}) {
    final theme = Theme.of(context);

    return Container(
      width: AppSizes.iconMedium,
      height: AppSizes.iconMedium,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlight ? context.colors.terciary : context.colors.secondary,
      ),
      child: Text(
        '$number',
        style: theme.textTheme.labelSmall?.copyWith(color: context.colors.black),
      ),
    );
  }

  /// Un valor que hay que poner tal cual en la otra web, con su botón.
  Widget _copyable(BuildContext context, String value) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: context.colors.lightgray,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
        IconButton(
          tooltip: texts.redditGuideCopy,
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: value));

            if (!context.mounted) return;
            showFernToast(context, texts.redditGuideCopied);
          },
          icon: const Icon(Icons.copy_outlined, size: AppSizes.iconCompact),
        ),
      ],
    );
  }

  Widget _note(BuildContext context, String text) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: AppSizes.iconSmall,
          color: context.colors.gray,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style:
                theme.textTheme.labelSmall?.copyWith(color: context.colors.gray),
          ),
        ),
      ],
    );
  }
}
