import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/widgets/media_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_masonry_view/flutter_masonry_view.dart';

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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l, right: AppSpacing.l),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).secondaryHeaderColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusSurface)),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: MasonryView(
              listOfItem: mediaList,
              numberOfColumn: columns,
              itemPadding: AppSpacing.s,
              itemRadius: AppSizes.radiusLarge,
              itemBuilder: (item) {
                return MediaItem(
                  media: item as MediaSummaryEntity,
                  onTap: () => context
                      .read<MediaBloc>()
                      .add(MediaClickedEvent(media: item)),
                );
              }),
        ),
      ),
    );
  }
}
