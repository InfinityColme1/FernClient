import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_unlock_dialog.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

/// Botón "Filtros" de las cabeceras de la biblioteca y de favoritos con su
/// panel de casillas, de arriba abajo:
///
/// - **NSFW**: esconder o enseñar lo marcado, sólo con contraseña puesta.
/// - **qué clase de contenido**: imágenes, GIF, vídeos.
/// - **de dónde llegó**: una casilla por fuente. Es lo que sustituye a tener
///   una etiqueta por plataforma: se ve sólo lo de Reddit sin que nadie lo haya
///   etiquetado.
///
/// Los tres valen con búsqueda y sin ella: son datos del contenido. Qué tipos
/// de resultado devuelve el buscador no está aquí sino junto a él
/// (`SearchScopeMenu`), que es a lo que afecta.
///
/// El panel no se cierra al marcar una casilla, así que se pueden encender y
/// apagar varias de una vez y ver la rejilla cambiar por detrás.
class SearchFilterMenu extends StatelessWidget {
  /// Fuentes de las que se está viendo contenido.
  final Set<ImportSource> sourceFilters;

  /// Clases de contenido que se están viendo.
  final Set<MediaKind> typeFilters;

  const SearchFilterMenu({
    super.key,
    required this.sourceFilters,
    required this.typeFilters,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final bloc = context.read<MediaBloc>();
    final nsfw = getIt<NsfwModeService>();

    return FernPopupPanel(
      // Con tope y desplazándose: todos los grupos juntos pasaban del alto de
      // media pantalla, y un desplegable que tapa la rejilla entera no deja ver
      // lo que el filtro está cambiando.
      maxHeight: filterMenuMaxHeight,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Arriba del todo: es el que más cambia lo que se ve. Sólo con
              // contraseña puesta, que sin ella no esconde nada. Quitarlo pide
              // la contraseña, como en todas partes; ponerlo no pide nada.
              if (nsfw.isConfigured) ...[
                _groupTitle(context, texts.filtersNsfw),
                StreamBuilder<bool>(
                  stream: nsfw.changes,
                  builder: (context, _) => FernCheckboxTile(
                    label: texts.filterNsfwHide,
                    value: !nsfw.isUnlocked,
                    onChanged: (_) {
                      if (nsfw.isUnlocked) {
                        nsfw.lock();
                        return;
                      }

                      showFernDialog<bool, Never>(
                        context: context,
                        builder: (_) => const NsfwUnlockDialog(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
              ],
              _groupTitle(context, texts.filtersType),
              for (final kind in MediaKind.values)
                FernCheckboxTile(
                  label: kind.filterLabel(texts),
                  value: typeFilters.contains(kind),
                  onChanged: (_) => bloc.add(ToggleTypeFilterEvent(kind)),
                ),
              const SizedBox(height: AppSpacing.m),
              _groupTitle(context, texts.filtersSource),
              for (final source in ImportSource.listed)
                FernCheckboxTile(
                  label: source.filterLabel(texts),
                  value: sourceFilters.contains(source),
                  onChanged: (_) => bloc.add(ToggleSourceFilterEvent(source)),
                ),
            ],
          ),
        ),
      ],
      builder: (context, toggle) => FernPillButton(
        label: texts.filters,
        icon: Symbols.tune,
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
