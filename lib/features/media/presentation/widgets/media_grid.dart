import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/media_item.dart';
import 'package:Fern/features/media/presentation/widgets/search_result_row.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/media/media_summary_entity.dart';
import '../../domain/entities/search/media_search_section_entity.dart';

class MediaGrid extends StatelessWidget {
  final List<MediaSummaryEntity> mediaList;
  final int columns;

  /// Grupos de una búsqueda, cada uno con su cabecera. `null` en la rejilla
  /// normal, que pinta [mediaList] de un tirón.
  final List<MediaSearchSectionEntity>? sections;

  /// Si la rejilla va sobre una superficie propia. Con `false` el contenido va
  /// directamente sobre el fondo de la pantalla, para las pantallas en las que la
  /// superficie es de otra cosa (la ficha de gestión de etiquetas).
  final bool hasSurface;

  /// Hay una consulta en marcha: lo que se está viendo es lo de antes y está a
  /// punto de cambiar.
  ///
  /// Con contenido a la vista se pone el indicador de espera encima, y sin nada
  /// que enseñar el indicador ocupa el sitio de la rejilla: mientras se está
  /// leyendo no se puede decir que no haya nada, todavía no se sabe.
  final bool isLoading;

  /// Qué hacer si el usuario quiere parar lo que se está haciendo. Con esto
  /// puesto, el indicador de espera lleva encima el botón de parar; sin ello,
  /// sólo se espera.
  final VoidCallback? onStop;

  const MediaGrid({
    super.key,
    required this.mediaList,
    required this.columns,
    this.hasSurface = true,
    this.isLoading = false,
    this.onStop,
  }) : sections = null;

  /// Rejilla de resultados de búsqueda: el contenido va separado en grupos
  /// (descripciones, etiquetas y creadores) con una cabecera delante de cada
  /// uno.
  const MediaGrid.sections({
    super.key,
    required List<MediaSearchSectionEntity> this.sections,
    required this.columns,
    this.hasSurface = true,
    this.isLoading = false,
    this.onStop,
  }) : mediaList = const [];

  /// Todo el contenido de la rejilla en el orden en el que se pinta, que es el
  /// que sigue la selección por rango. Con grupos, los recorre de arriba abajo
  /// como una sola lista, igual que se ven.
  List<int> get _orderedIds => sections == null
      ? [for (final media in mediaList) media.id]
      : [
          for (final section in sections!)
            for (final media in section.media) media.id,
        ];

  /// El hueco que la rejilla deja hasta el borde de la ventana.
  ///
  /// La pantalla ya separa por arriba y por la izquierda (que es donde están la
  /// cabecera y el menú), así que aquí se completan los otros dos lados: la
  /// superficie nunca toca el borde, ni con contenido ni vacía.
  static const _padding =
      EdgeInsets.only(bottom: AppSpacing.l, right: AppSpacing.l);

  @override
  Widget build(BuildContext context) {
    final isEmpty = sections?.isEmpty ?? mediaList.isEmpty;

    if (isEmpty) {
      // Mientras se está leyendo, el indicador de espera; sólo cuando ya se sabe
      // que no hay nada se dice que la rejilla está vacía.
      final Widget placeholder = isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_stopButton(context) case final stop?) ...[
                    stop,
                    const SizedBox(height: AppSpacing.s),
                  ],
                  const FernProgressIndicator(),
                ],
              ),
            )
          : FernEmptyState(
              imageAsset: fernEmptyImage,
              message: AppLocalizations.of(context).emptyLibrary,
            );

      return Padding(
        padding: _padding,
        child: hasSurface
            ? FernSurface(width: double.infinity, child: placeholder)
            : SizedBox(width: double.infinity, child: placeholder),
      );
    }

    final orderedIds = _orderedIds;
    final content =
        sections == null ? _buildGrid(orderedIds) : _buildSections(orderedIds);

    return Padding(
      padding: _padding,
      child: FernBusyOverlay(
        isBusy: isLoading,
        action: _stopButton(context),
        radius: hasSurface ? AppSizes.radiusSurface : AppSizes.radiusMedium,
        child: hasSurface
            ? FernSurface(clipBehavior: Clip.antiAlias, child: content)
            : content,
      ),
    );
  }

  /// El botón que para lo que se está haciendo, o `null` si esta rejilla no
  /// deja pararlo.
  ///
  /// Va del color del indicador que tiene debajo porque es parte de él: no es
  /// una acción de la pantalla, es lo único que se puede hacer con la espera
  /// que se está mirando.
  Widget? _stopButton(BuildContext context) {
    if (onStop == null) return null;

    final color = Theme.of(context).progressIndicatorTheme.color ??
        Theme.of(context).colorScheme.primary;

    return IconButton(
      tooltip: AppLocalizations.of(context).actionStopImport,
      onPressed: onStop,
      icon: Icon(Icons.stop_circle_outlined, color: color),
      iconSize: AppSizes.iconLarge,
    );
  }

  Widget _buildGrid(List<int> orderedIds) {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(AppSpacing.s),
      crossAxisCount: columns,
      mainAxisSpacing: AppSpacing.s,
      crossAxisSpacing: AppSpacing.s,
      itemCount: mediaList.length,
      itemBuilder: (context, index) =>
          _buildItem(mediaList[index], orderedIds),
    );
  }

  /// Un bloque por grupo: la cabecera que lo identifica y su rejilla. Todo va en
  /// el mismo scroll, así que los grupos se recorren de arriba abajo como una
  /// sola lista.
  Widget _buildSections(List<int> orderedIds) {
    return CustomScrollView(
      slivers: [
        for (final section in sections!) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.m,
              AppSpacing.l,
              AppSpacing.m,
              AppSpacing.xs,
            ),
            sliver: SliverToBoxAdapter(
              child: SearchResultRow.header(
                label: section.title,
                imagePath: section.imagePath,
                type: section.type,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: columns,
              mainAxisSpacing: AppSpacing.s,
              crossAxisSpacing: AppSpacing.s,
              childCount: section.media.length,
              itemBuilder: (context, index) =>
                  _buildItem(section.media[index], orderedIds),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s)),
      ],
    );
  }

  Widget _buildItem(MediaSummaryEntity media, List<int> orderedIds) {
    return BlocSelector<MediaBloc, MediaStates, bool>(
      selector: (state) => state.selectedIds.contains(media.id),
      builder: (context, isSelected) => MediaItem(
        media: media,
        isSelected: isSelected,
        onTap: () =>
            context.read<MediaBloc>().add(MediaClickedEvent(media: media)),
        onSelectionToggled: () =>
            context.read<MediaBloc>().add(ToggleMediaSelectionEvent(media: media)),
        // Mayúsculas + clic: la selección se estira hasta aquí desde el último
        // elemento marcado, siguiendo el orden de la rejilla.
        onRangeSelectionRequested: () => context.read<MediaBloc>().add(
              SelectMediaRangeEvent(media: media, orderedIds: orderedIds),
            ),
        // Si el contenido no se pinta porque su fichero ya no está, la fila de
        // la base de datos sobra y el elemento desaparece de la rejilla.
        onLoadFailed: () =>
            context.read<MediaBloc>().add(MediaLoadFailedEvent(media.id)),
      ),
    );
  }
}
