import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cómo se nombra cada tipo de resultado en el filtro: en plural, porque lo que
/// se enciende o se apaga es el grupo entero, no un resultado.
extension _SearchResultTypeFilterLabel on SearchResultType {
  String filterLabel(AppLocalizations texts) => switch (this) {
        SearchResultType.media => texts.filterMedia,
        SearchResultType.tag => texts.filterTags,
        SearchResultType.creator => texts.filterCreators,
      };
}

/// Botón "Filters" de la cabecera de la pantalla de media con su panel de
/// casillas: una por tipo de resultado (contenidos, etiquetas y creadores).
///
/// El panel no se cierra al marcar una casilla, así que se pueden encender y
/// apagar varios tipos de una vez y ver la rejilla cambiar por detrás.
///
/// Filtra lo que ya se ha buscado, no la biblioteca: sin búsqueda en marcha no
/// hay grupos que esconder y el botón queda desactivado.
class SearchFilterMenu extends StatelessWidget {
  /// Tipos de resultado que se están viendo.
  final Set<SearchResultType> filters;

  /// Si hay una búsqueda en marcha, que es lo único que el filtro puede recortar.
  final bool hasSearch;

  const SearchFilterMenu({
    super.key,
    required this.filters,
    required this.hasSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);
    final bloc = context.read<MediaBloc>();

    return FernPopupPanel(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                texts.filtersResultsFrom,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.gray,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              for (final type in SearchResultType.values)
                FernCheckboxTile(
                  label: type.filterLabel(texts),
                  value: filters.contains(type),
                  onChanged: (_) => bloc.add(ToggleSearchFilterEvent(type)),
                ),
            ],
          ),
        ),
      ],
      builder: (context, toggle) => FernPillButton(
        label: texts.filters,
        icon: Icons.tune,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        onPressed: hasSearch ? toggle : null,
      ),
    );
  }
}
