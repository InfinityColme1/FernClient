import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/media_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/media/media_summary_entity.dart';

class MediaGrid extends StatelessWidget {
  final List<MediaSummaryEntity> mediaList;
  final int columns;

  const MediaGrid({
    super.key,
    required this.mediaList,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaList.isEmpty) {
      return const FernSurface(
        width: double.infinity,
        child: FernEmptyState(
          imageAsset: fernEmptyImage,
          message: "This looks a little empty",
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l, right: AppSpacing.l),
      child: FernSurface(
        clipBehavior: Clip.antiAlias,

        child: MasonryGridView.count(
          padding: const EdgeInsets.all(AppSpacing.s),
          crossAxisCount: columns,
          mainAxisSpacing: AppSpacing.s,
          crossAxisSpacing: AppSpacing.s,
          itemCount: mediaList.length,
          itemBuilder: (context, index) {
            final media = mediaList[index];

            return BlocSelector<MediaBloc, MediaStates, bool>(
              selector: (state) => state.selectedIds.contains(media.id),
              builder: (context, isSelected) => MediaItem(
                media: media,
                isSelected: isSelected,
                onTap: () =>
                    context.read<MediaBloc>().add(MediaClickedEvent(media: media)),
                onSelectionToggled: () => context
                    .read<MediaBloc>()
                    .add(ToggleMediaSelectionEvent(media: media)),
              ),
            );
          },
        ),
      ),
    );
  }
}
