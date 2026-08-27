import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
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

/// Cómo se nombra cada fuente en el filtro. Las plataformas se llaman igual en
/// todos los idiomas y traen su nombre puesto; el equipo sí se traduce.
extension _ImportSourceFilterLabel on ImportSource {
  String filterLabel(AppLocalizations texts) =>
      label ??
      switch (this) {
        ImportSource.browser => texts.sourceBrowser,
        _ => texts.sourceLocal,
      };
}

/// Cómo se nombra cada clase de contenido en el filtro.
extension _MediaKindFilterLabel on MediaKind {
  String filterLabel(AppLocalizations texts) => switch (this) {
        MediaKind.image => texts.filterImages,
        MediaKind.gif => texts.filterGifs,
        MediaKind.video => texts.filterVideos,
      };
}

/// Botón "Filters" de la cabecera de la pantalla de media con su panel de
/// casillas, en tres grupos:
///
/// - **de dónde salen los resultados**: una casilla por tipo (contenidos,
///   etiquetas y creadores). Recorta lo que ya se ha buscado, así que sin
///   búsqueda en marcha no hay grupos que esconder y esas casillas quedan
///   apagadas.
/// - **de dónde llegó el contenido**: una casilla por fuente. Ésta vale siempre,
///   con búsqueda y sin ella, porque la fuente es un dato del contenido y no del
///   resultado. Es lo que sustituye a tener una etiqueta por plataforma: se ve
///   sólo lo de Reddit sin que nadie lo haya etiquetado.
///
/// El panel no se cierra al marcar una casilla, así que se pueden encender y
/// apagar varias de una vez y ver la rejilla cambiar por detrás.
class SearchFilterMenu extends StatelessWidget {
  /// Tipos de resultado que se están viendo.
  final Set<SearchResultType> filters;

  /// Fuentes de las que se está viendo contenido.
  final Set<ImportSource> sourceFilters;

  /// Clases de contenido que se están viendo.
  final Set<MediaKind> typeFilters;

  /// Si hay una búsqueda en marcha, que es lo único que el filtro de tipos puede
  /// recortar.
  final bool hasSearch;

  /// Si se enseña el grupo de «de dónde salen los resultados».
  ///
  /// Ese grupo sólo recorta una búsqueda, así que en una pantalla que no tiene
  /// buscador —favoritos— no pinta nada: enseñarlo atenuado explicaría un filtro
  /// que ahí no puede existir nunca.
  final bool showResultTypes;

  const SearchFilterMenu({
    super.key,
    required this.filters,
    required this.sourceFilters,
    required this.typeFilters,
    required this.hasSearch,
    this.showResultTypes = true,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final bloc = context.read<MediaBloc>();

    return FernPopupPanel(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showResultTypes) ...[
                _groupTitle(context, texts.filtersResultsFrom),
                for (final type in SearchResultType.values)
                  FernCheckboxTile(
                    label: type.filterLabel(texts),
                    value: filters.contains(type),
                    // Sin búsqueda no hay nada que recortar: la casilla se queda
                    // atenuada en lugar de desaparecer, que así se entiende que
                    // el filtro existe y por qué no hace nada.
                    onChanged: hasSearch
                        ? (_) => bloc.add(ToggleSearchFilterEvent(type))
                        : null,
                  ),
                const SizedBox(height: AppSpacing.m),
              ],
              _groupTitle(context, texts.filtersSource),
              for (final source in ImportSource.listed)
                FernCheckboxTile(
                  label: source.filterLabel(texts),
                  value: sourceFilters.contains(source),
                  onChanged: (_) => bloc.add(ToggleSourceFilterEvent(source)),
                ),
              const SizedBox(height: AppSpacing.m),
              // De qué tipo es un fichero es un dato suyo, así que esto vale
              // con búsqueda y sin ella, igual que la fuente.
              _groupTitle(context, texts.filtersType),
              for (final kind in MediaKind.values)
                FernCheckboxTile(
                  label: kind.filterLabel(texts),
                  value: typeFilters.contains(kind),
                  onChanged: (_) => bloc.add(ToggleTypeFilterEvent(kind)),
                ),
            ],
          ),
        ),
      ],
      builder: (context, toggle) => FernPillButton(
        label: texts.filters,
        icon: Icons.tune,
        backgroundColor: context.colors.primary,
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
