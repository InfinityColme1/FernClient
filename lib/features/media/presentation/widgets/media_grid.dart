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

  const MediaGrid({
    super.key,
    required this.mediaList,
    required this.columns,
  }) : sections = null;

  /// Rejilla de resultados de búsqueda: el contenido va separado en grupos
  /// (descripciones, etiquetas y creadores) con una cabecera delante de cada
  /// uno.
  const MediaGrid.sections({
    super.key,
    required List<MediaSearchSectionEntity> this.sections,
    required this.columns,
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

  @override
  Widget build(BuildContext context) {
    final isEmpty = sections?.isEmpty ?? mediaList.isEmpty;

    if (isEmpty) {
      return FernSurface(
        width: double.infinity,
        child: FernEmptyState(
          imageAsset: fernEmptyImage,
          message: AppLocalizations.of(context).emptyLibrary,
        ),
      );
    }

    final orderedIds = _orderedIds;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l, right: AppSpacing.l),
      child: FernSurface(
        clipBehavior: Clip.antiAlias,
        child: sections == null
            ? _buildGrid(orderedIds)
            : _buildSections(orderedIds),
      ),
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
