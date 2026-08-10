import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:equatable/equatable.dart';


abstract class MediaStates extends Equatable {
  final List<MediaSummaryEntity> ? mediaList;

  final MediaEntity? currentMedia;
  final int? currentMediaIndex;
  final bool showInfo;
  final bool isModified;
  final bool isNew;

  /// Identificadores de los elementos marcados en la rejilla.
  final Set<int> selectedIds;

  const MediaStates({
    this.currentMedia,
    this.mediaList,
    this.currentMediaIndex,
    this.showInfo = false,
    this.isModified = false,
    this.isNew = false,
    this.selectedIds = const {},
  });

  MediaStates copyWith({
    MediaEntity ? currentMedia,
    List<MediaSummaryEntity> ? mediaList,
    int ? currentMediaIndex,
    bool ? showInfo,
    bool ? isModified,
    bool ? isNew,
    Set<int> ? selectedIds,
  });

  @override
  List<Object?> get props => [
    mediaList,
    currentMedia,
    currentMediaIndex,
    showInfo,
    isModified,
    isNew,
    selectedIds,
  ];
}

class MediaLoading extends MediaStates {
  const MediaLoading({
    super.mediaList,
    super.showInfo,
    super.isModified,
    super.isNew,
    super.selectedIds,
  });

  @override
  MediaLoading copyWith({
    MediaEntity ? currentMedia,
    List<MediaSummaryEntity> ? mediaList,
    int ? currentMediaIndex,
    bool ? showInfo,
    bool ? isModified,
    bool ? isNew,
    Set<int> ? selectedIds,
  }) {
    return MediaLoading(
      mediaList: mediaList ?? this.mediaList,
      showInfo: showInfo ?? this.showInfo,
      isModified: isModified ?? this.isModified,
      isNew: isNew ?? this.isNew,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

class DetailedMedia extends MediaStates {
  @override
  final int currentMediaIndex;
  @override
  final MediaEntity currentMedia;
  
  const DetailedMedia({
    super.mediaList,
    required this.currentMediaIndex,
    required this.currentMedia,
    super.showInfo,
    super.isModified,
    super.isNew,
    super.selectedIds,
  });

  @override
  MediaStates copyWith({
    MediaEntity ? currentMedia,
    List<MediaSummaryEntity> ? mediaList,
    int ? currentMediaIndex,
    bool ? showInfo,
    bool ? isModified,
    bool ? isNew,
    Set<int> ? selectedIds,
  }) {
    return DetailedMedia(
        mediaList: mediaList ?? this.mediaList,
        currentMediaIndex: currentMediaIndex ?? this.currentMediaIndex,
        currentMedia: currentMedia ?? this.currentMedia,
        showInfo: showInfo ?? this.showInfo,
        isModified: isModified ?? this.isModified,
        isNew: isNew ?? this.isNew,
        selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}
