import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/search/media_search_section_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
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

  /// Texto de la búsqueda que ha dado lugar a [mediaList]. `null` cuando la
  /// rejilla muestra la biblioteca entera y no un resultado de búsqueda.
  final String? searchQuery;

  /// Resultado de la búsqueda repartido en grupos (descripciones, etiquetas y
  /// creadores), en el orden en el que la rejilla los pinta. `null` si no hay
  /// búsqueda: entonces la rejilla usa [mediaList] sin cabeceras.
  final List<MediaSearchSectionEntity>? searchSections;

  /// Sugerencia elegida en el buscador, cuando la búsqueda viene de pulsar una
  /// y no de escribir. `null` en las búsquedas por texto.
  final SearchSuggestionEntity? searchSuggestion;

  const MediaStates({
    this.currentMedia,
    this.mediaList,
    this.currentMediaIndex,
    this.showInfo = false,
    this.isModified = false,
    this.isNew = false,
    this.selectedIds = const {},
    this.searchQuery,
    this.searchSections,
    this.searchSuggestion,
  });

  MediaStates copyWith({
    MediaEntity ? currentMedia,
    List<MediaSummaryEntity> ? mediaList,
    int ? currentMediaIndex,
    bool ? showInfo,
    bool ? isModified,
    bool ? isNew,
    Set<int> ? selectedIds,
    String ? searchQuery,
    List<MediaSearchSectionEntity> ? searchSections,
    SearchSuggestionEntity ? searchSuggestion,
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
    searchQuery,
    searchSections,
    searchSuggestion,
  ];
}

class MediaLoading extends MediaStates {
  const MediaLoading({
    super.mediaList,
    super.showInfo,
    super.isModified,
    super.isNew,
    super.selectedIds,
    super.searchQuery,
    super.searchSections,
    super.searchSuggestion,
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
    String ? searchQuery,
    List<MediaSearchSectionEntity> ? searchSections,
    SearchSuggestionEntity ? searchSuggestion,
  }) {
    return MediaLoading(
      mediaList: mediaList ?? this.mediaList,
      showInfo: showInfo ?? this.showInfo,
      isModified: isModified ?? this.isModified,
      isNew: isNew ?? this.isNew,
      selectedIds: selectedIds ?? this.selectedIds,
      searchQuery: searchQuery ?? this.searchQuery,
      searchSections: searchSections ?? this.searchSections,
      searchSuggestion: searchSuggestion ?? this.searchSuggestion,
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
    super.searchQuery,
    super.searchSections,
    super.searchSuggestion,
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
    String ? searchQuery,
    List<MediaSearchSectionEntity> ? searchSections,
    SearchSuggestionEntity ? searchSuggestion,
  }) {
    return DetailedMedia(
        mediaList: mediaList ?? this.mediaList,
        currentMediaIndex: currentMediaIndex ?? this.currentMediaIndex,
        currentMedia: currentMedia ?? this.currentMedia,
        showInfo: showInfo ?? this.showInfo,
        isModified: isModified ?? this.isModified,
        isNew: isNew ?? this.isNew,
        selectedIds: selectedIds ?? this.selectedIds,
        searchQuery: searchQuery ?? this.searchQuery,
        searchSections: searchSections ?? this.searchSections,
        searchSuggestion: searchSuggestion ?? this.searchSuggestion,
    );
  }
}
