import 'package:Fern/features/media/domain/entities/empty_source.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
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

  /// Fuentes de las que el filtro de la cabecera deja ver contenido. De partida
  /// están todas, que es la biblioteca entera.
  ///
  /// A diferencia de [searchFilters], recorta la rejilla haya búsqueda o no: de
  /// dónde llegó un contenido es un dato suyo, no de un resultado de búsqueda.
  /// Es la forma de ver sólo lo de una plataforma sin necesidad de que exista
  /// una etiqueta por plataforma.
  final Set<ImportSource> sourceFilters;

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

  /// Fuente elegida en la pantalla de importación.
  ///
  /// Decide las dos cosas que hace ese desplegable: de dónde se importa la
  /// próxima vez y qué contenido de los pendientes enseña la rejilla. En las
  /// demás pantallas no pinta nada, pero se arrastra igual para que volver a
  /// importación la encuentre como se dejó.
  final ImportSource importSource;

  /// Cuándo se importó por última vez de [importSource]. `null` si nunca, o si
  /// lo elegido son todas las fuentes (que no tienen un único momento).
  final DateTime? lastImportAt;

  /// La fuente cuya sesión ha rechazado la plataforma durante la importación
  /// que acaba de terminar, si es que ha pasado.
  ///
  /// Es un aviso de una sola vez: no lo arrastra [copyWith], así que vive lo que
  /// dura el estado que lo trae y desaparece con el siguiente. Es lo que hace
  /// que se enseñe una vez y no en cada repintado.
  final ImportSource? expiredSession;

  /// Lo que ha fallado durante la importación que acaba de terminar, si es que
  /// ha fallado algo y no era cosa de las credenciales.
  ///
  /// Es un aviso de una sola vez, igual que [expiredSession]: no lo arrastra
  /// [copyWith], así que se enseña una vez y no en cada repintado. Sin esto, una
  /// fuente que contesta mal deja la pantalla exactamente igual que una fuente
  /// que no tenía nada nuevo, y no hay forma de distinguirlas.
  final String? importError;

  /// La fuente que no tenía nada que traer, y por qué, si es que se sabe.
  ///
  /// Es otro aviso de una sola vez. Sin él, una importación que acaba en cero se
  /// ve igual que una que no ha llegado a funcionar.
  final ImportSource? emptySource;
  final EmptySourceHint? emptyHint;

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
    this.sourceFilters = ImportSource.allSources,
    this.searchSuggestion,
    this.favoritesOnly = false,
    this.isBusy = false,
    this.importSource = ImportSource.local,
    this.lastImportAt,
    this.expiredSession,
    this.importError,
    this.emptySource,
    this.emptyHint,
  });

  /// Si el filtro de fuentes deja ver [summary].
  bool showsSource(MediaSummaryEntity summary) =>
      sourceFilters.contains(summary.importSource);

  /// Los grupos que la rejilla pinta: los de la búsqueda que el filtro de tipos
  /// deja pasar, con su contenido recortado por el de fuentes. `null` cuando no
  /// hay búsqueda, igual que [searchSections].
  ///
  /// Un grupo que se queda sin contenido desaparece con su cabecera: una
  /// etiqueta de la que no se ve nada no es un grupo vacío que enseñar.
  /// El contenido que se está viendo ya está en la papelera.
  ///
  /// Cambia lo que se puede hacer con él: su botón de borrar es el definitivo y
  /// aparece además el de devolverlo a su sitio. Lo miran el visor y su panel de
  /// información, y por eso se calcula aquí en vez de en cada uno: es el mismo
  /// contenido y la misma pregunta.
  ///
  /// No es un campo de [MediaEntity] porque no es suyo: quien sabe si algo está
  /// marcado es la lista de la que sale.
  bool get isCurrentMediaMarked {
    final media = currentMedia;
    if (media == null) return false;

    return mediaList?.any(
          (summary) => summary.id == media.id && summary.isDeleted,
        ) ??
        false;
  }

  List<MediaSearchSectionEntity>? get visibleSearchSections {
    final sections = searchSections;
    if (sections == null) return null;

    final visible = <MediaSearchSectionEntity>[];
    for (final section in sections) {
      if (!searchFilters.contains(section.type)) continue;

      final media = section.media.where(showsSource).toList();
      if (media.isEmpty) continue;

      visible.add(MediaSearchSectionEntity(
        type: section.type,
        title: section.title,
        imagePath: section.imagePath,
        media: media,
      ));
    }
    return visible;
  }

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
    Set<ImportSource> ? sourceFilters,
    SearchSuggestionEntity ? searchSuggestion,
    bool ? favoritesOnly,
    bool ? isBusy,
    ImportSource ? importSource,
    DateTime ? lastImportAt,
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
    sourceFilters,
    searchSuggestion,
    favoritesOnly,
    isBusy,
    importSource,
    lastImportAt,
    expiredSession,
    importError,
    emptySource,
    emptyHint,
  ];
}

class MediaLoading extends MediaStates {
  const MediaLoading({
    super.expiredSession,
    super.importError,
    super.emptySource,
    super.emptyHint,
    super.mediaList,
    super.showInfo,
    super.isModified,
    super.isNew,
    super.selectedIds,
    super.searchQuery,
    super.searchSections,
    super.searchFilters,
    super.sourceFilters,
    super.searchSuggestion,
    super.favoritesOnly,
    super.isBusy,
    super.importSource,
    super.lastImportAt,
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
    Set<ImportSource> ? sourceFilters,
    SearchSuggestionEntity ? searchSuggestion,
    bool ? favoritesOnly,
    bool ? isBusy,
    ImportSource ? importSource,
    DateTime ? lastImportAt,
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
      sourceFilters: sourceFilters ?? this.sourceFilters,
      searchSuggestion: searchSuggestion ?? this.searchSuggestion,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      isBusy: isBusy ?? this.isBusy,
      importSource: importSource ?? this.importSource,
      lastImportAt: lastImportAt ?? this.lastImportAt,
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
    super.sourceFilters,
    super.searchSuggestion,
    super.favoritesOnly,
    super.isBusy,
    super.importSource,
    super.lastImportAt,
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
    Set<ImportSource> ? sourceFilters,
    SearchSuggestionEntity ? searchSuggestion,
    bool ? favoritesOnly,
    bool ? isBusy,
    ImportSource ? importSource,
    DateTime ? lastImportAt,
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
        sourceFilters: sourceFilters ?? this.sourceFilters,
        searchSuggestion: searchSuggestion ?? this.searchSuggestion,
        favoritesOnly: favoritesOnly ?? this.favoritesOnly,
        isBusy: isBusy ?? this.isBusy,
        importSource: importSource ?? this.importSource,
      lastImportAt: lastImportAt ?? this.lastImportAt,
    );
  }
}
