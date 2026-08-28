import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media/suggestion_filter.dart';
import 'package:Fern/features/media/domain/entities/media_sort_order.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Cómo se está mirando lo pendiente de revisar: qué parte y en qué orden.
///
/// **Las dos cosas en un solo botón** y no en dos desplegables. Son dos
/// preguntas distintas —con cuál se trabaja y cómo se coloca— pero se contestan
/// juntas y se cambian poco, y la cabecera de esta pantalla ya tiene todo lo que
/// puede sostener: dos controles más eran los que la dejaban sin sitio.
///
/// El panel no se cierra al elegir, así que se pueden tocar los dos y ver la
/// rejilla cambiar por detrás, igual que el de filtros de la biblioteca.
class ImportViewMenu extends StatelessWidget {
  final SuggestionFilter filter;
  final MediaSortOrder order;

  /// Si esta fuente sabe dar sus creadores. Sin eso no hay nada que enseñar y el
  /// grupo no aparece: un interruptor que no lleva a ninguna parte es peor que
  /// su ausencia.
  final bool hasCreators;

  /// Si se está enseñando la lista de creadores en vez del contenido.
  final bool showsCreators;

  /// Si hay algo que revisar. Sin contenido no hay ni parte que elegir ni nada
  /// que ordenar, y el grupo se queda fuera en vez de salir apagado.
  final bool hasMedia;

  final ValueChanged<SuggestionFilter> onFilterChanged;
  final ValueChanged<MediaSortOrder> onOrderChanged;
  final ValueChanged<bool> onShowsCreatorsChanged;

  const ImportViewMenu({
    super.key,
    required this.filter,
    required this.order,
    required this.hasMedia,
    required this.hasCreators,
    required this.showsCreators,
    required this.onFilterChanged,
    required this.onOrderChanged,
    required this.onShowsCreatorsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return FernPopupPanel(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lo primero, porque cambia **qué** se está mirando y lo demás
              // sólo cómo se mira. Y porque la lista de creadores tapa la
              // rejilla: si no se puede quitar desde aquí, no se puede quitar.
              if (hasCreators) ...[
                _groupTitle(context, texts.importCreatorsLabel),
                FernRadioTile<bool>(
                  value: false,
                  groupValue: showsCreators,
                  label: texts.remoteContentMode,
                  onChanged: onShowsCreatorsChanged,
                ),
                FernRadioTile<bool>(
                  value: true,
                  groupValue: showsCreators,
                  label: texts.remoteCreatorsMode,
                  onChanged: onShowsCreatorsChanged,
                ),
                const SizedBox(height: AppSpacing.m),
              ],
              if (hasMedia) ...[
                _groupTitle(context, texts.importReviewLabel),
                for (final option in SuggestionFilter.values)
                  FernRadioTile<SuggestionFilter>(
                    value: option,
                    groupValue: filter,
                    label: option.label(texts),
                    onChanged: onFilterChanged,
                  ),
                const SizedBox(height: AppSpacing.m),
              ],
              _groupTitle(context, texts.importSortLabel),
              for (final option in MediaSortOrder.forImport)
                FernRadioTile<MediaSortOrder>(
                  value: option,
                  groupValue: order,
                  label: sortOrderLabel(option, texts),
                  onChanged: onOrderChanged,
                ),
            ],
          ),
        ),
      ],
      builder: (context, toggle) => FernPillButton(
        label: texts.importShowLabel,
        icon: Symbols.tune,
        backgroundColor: context.colors.secondary,
        foregroundColor: context.colors.black,
        onPressed: toggle,
      ),
    );
  }

  Widget _groupTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: context.colors.gray),
      ),
    );
  }
}

/// Cómo se llama cada orden.
///
/// Aquí y no en cada pantalla: la de contenido y la de importación ofrecen los
/// mismos y llamarlos distinto en cada una sería confundir por escrito dos cosas
/// que son la misma.
String sortOrderLabel(MediaSortOrder order, AppLocalizations texts) =>
    switch (order) {
      MediaSortOrder.newestFirst => texts.sortNewestFirst,
      MediaSortOrder.oldestFirst => texts.sortOldestFirst,
      MediaSortOrder.fileName => texts.sortFileName,
      MediaSortOrder.description => texts.sortDescription,
      MediaSortOrder.kind => texts.sortKind,
      MediaSortOrder.random => texts.sortRandom,
    };
