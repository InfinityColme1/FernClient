import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_controller.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_tours.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Ayuda: los recorridos guiados, para verlos cuando hagan falta.
///
/// Es lo que hace que el tutorial sea de verdad omitible. Sin un sitio donde
/// encontrarlo después, saltárselo la primera vez sería perderlo para siempre, y
/// entonces la pregunta del principio dejaría de ser una pregunta.
///
/// Y es donde viven los cinco especializados, que aquí no estorban: nadie
/// necesita saber cómo se entrena un modelo el día que abre la aplicación, y
/// contárselo entonces es la forma más segura de que no se entere de nada. Los
/// busca quien ya se ha topado con la pantalla y quiere saber qué hace.
class HelpSettingsSection extends StatelessWidget {
  const HelpSettingsSection({super.key});

  /// Cierra los ajustes **antes** de arrancar.
  ///
  /// El velo del tutorial vive en el marco de la aplicación y este diálogo se
  /// pinta por encima de él, así que con los ajustes abiertos el tutorial se
  /// vería por debajo. Y además lo que va a señalar —el menú, la barra de
  /// arriba, la pantalla de turno— es justo lo que el diálogo está tapando.
  void _start(BuildContext context, TutorialTour tour) {
    final steps = tour.steps(AppLocalizations.of(context));

    Navigator.of(context).pop();
    getIt<TutorialController>().start(steps);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(texts.tutorialSectionTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.s),
        Text(
          texts.tutorialSectionNote,
          style:
              theme.textTheme.bodyMedium?.copyWith(color: context.colors.gray),
        ),
        const SizedBox(height: AppSpacing.l),
        // Sin desplazamiento propio: **el que desplaza es el diálogo**, que mete
        // cada sección dentro de su scroll. Aquí había una pieza flexible con su
        // propia lista desplazable, y no hacía nada — con alto sin límite no hay
        // nada que repartir y esa lista no llegaba a desplazar nunca. Como todas
        // las demás secciones: una columna y ya.
        for (final tour in TutorialTour.values)
          _TourTile(tour: tour, onStart: () => _start(context, tour)),
      ],
    );
  }
}

/// La fila de un recorrido: su icono, de qué va y el botón de empezarlo.
///
/// La fila entera se puede pulsar, no sólo el botón: el botón dice qué pasa al
/// pulsar, pero una fila que se ilumina bajo el ratón y no responde es peor que
/// una que no se ilumina.
class _TourTile extends StatelessWidget {
  final TutorialTour tour;
  final VoidCallback onStart;

  const _TourTile({required this.tour, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Material(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: InkWell(
          onTap: onStart,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          mouseCursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Icon(tour.icon, size: AppSizes.iconMedium, color: colors.gray),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tour.title(texts),
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        tour.description(texts),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: colors.unremarked),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                FernPillButton(
                  label: texts.tutorialOfferAccept,
                  icon: Symbols.play_arrow,
                  backgroundColor: colors.primary,
                  foregroundColor: colors.black,
                  onPressed: onStart,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
