import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/search/media_search_section_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
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
  ///
  /// Están **todos** los grupos que ha encontrado el buscador, también los que el
  /// filtro esconde: apagar un tipo no repite la búsqueda, sólo deja de pintarlo,
  /// así que volver a encenderlo tiene que poder recuperarlo.
  final List<MediaSearchSectionEntity>? searchSections;

  /// Tipos de resultado que el filtro de la cabecera deja ver. De partida están
  /// los tres, que es la búsqueda entera.
  final Set<SearchResultType> searchFilters;

  /// Sugerencia elegida en el buscador, cuando la búsqueda viene de pulsar una
  /// y no de escribir. `null` en las búsquedas por texto.
  final SearchSuggestionEntity? searchSuggestion;

  /// La lista es la de la pantalla de favoritos.
  ///
  /// Es lo que hace que quitar el corazón desde el visor saque el contenido de
  /// la rejilla: en cualquier otra pantalla el contenido se queda donde está.
  final bool favoritesOnly;

  /// Hay una consulta a la base de datos o una operación con ficheros en marcha.
  ///
  /// Es lo que enseña el indicador de espera de las pantallas. Lo pone quien
  /// lanza la operación y lo quita el estado con el que termina, así que basta
  /// con emitir el resultado para que el indicador desaparezca.
  final bool isBusy;

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
    this.searchFilters = allSearchResultTypes,
    this.searchSuggestion,
    this.favoritesOnly = false,
    this.isBusy = false,
  });

  /// Los grupos que la rejilla pinta: los de la búsqueda que el filtro deja
  /// pasar. `null` cuando no hay búsqueda, igual que [searchSections].
  List<MediaSearchSectionEntity>? get visibleSearchSections => searchSections
      ?.where((section) => searchFilters.contains(section.type))
      .toList();

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
    Set<SearchResultType> ? searchFilters,
    SearchSuggestionEntity ? searchSuggestion,
    bool ? favoritesOnly,
    bool ? isBusy,
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
    searchFilters,
    searchSuggestion,
    favoritesOnly,
    isBusy,
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
    super.searchFilters,
    super.searchSuggestion,
    super.favoritesOnly,
    super.isBusy,
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
    Set<SearchResultType> ? searchFilters,
    SearchSuggestionEntity ? searchSuggestion,
    bool ? favoritesOnly,
    bool ? isBusy,
  }) {
    return MediaLoading(
      mediaList: mediaList ?? this.mediaList,
      showInfo: showInfo ?? this.showInfo,
      isModified: isModified ?? this.isModified,
      isNew: isNew ?? this.isNew,
      selectedIds: selectedIds ?? this.selectedIds,
      searchQuery: searchQuery ?? this.searchQuery,
      searchSections: searchSections ?? this.searchSections,
      searchFilters: searchFilters ?? this.searchFilters,
      searchSuggestion: searchSuggestion ?? this.searchSuggestion,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      isBusy: isBusy ?? this.isBusy,
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
    super.searchFilters,
    super.searchSuggestion,
    super.favoritesOnly,
    super.isBusy,
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
    Set<SearchResultType> ? searchFilters,
    SearchSuggestionEntity ? searchSuggestion,
    bool ? favoritesOnly,
    bool ? isBusy,
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
        searchFilters: searchFilters ?? this.searchFilters,
        searchSuggestion: searchSuggestion ?? this.searchSuggestion,
        favoritesOnly: favoritesOnly ?? this.favoritesOnly,
        isBusy: isBusy ?? this.isBusy,
    );
  }
}
