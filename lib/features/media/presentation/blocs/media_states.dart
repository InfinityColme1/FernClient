import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/media/domain/entities/empty_source.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/search/media_search_section_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_criterion_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/core/utils/same_instance.dart';
import 'package:equatable/equatable.dart';


/// De qué pantalla es la rejilla que hay en el estado.
///
/// El bloc de contenido es **uno solo** y lo comparten seis pantallas, así que
/// su lista sobrevive al cambio de pantalla. Sin decir de quién es, la
/// biblioteca se abría enseñando lo que hubiera dejado la importación, y la
/// pantalla de gestión lo que hubiera dejado la biblioteca: contenido de otro
/// sitio, con la cabecera y los botones de éste.
///
/// Con esto, cada pantalla dice al abrirse cuál es la suya, y lo que no es suyo
/// no se pinta.
enum MediaListing {
  /// Todavía no se ha abierto ninguna.
  none,

  /// La biblioteca, con o sin búsqueda: las dos son la misma pantalla.
  library,

  /// Lo que está esperando en la pantalla de importación.
  scanned,

  /// La papelera.
  deleted,

  /// Los favoritos.
  favorites,

  /// El contenido de una etiqueta: la rejilla de la pantalla de gestión de
  /// etiquetas.
  byTag,

  /// El contenido de un creador, en su pantalla de gestión.
  byCreator,
}

abstract class MediaStates extends Equatable {
  final List<MediaSummaryEntity> ? mediaList;

  /// De qué pantalla es [mediaList]. Ver [MediaListing].
  final MediaListing listing;

  final MediaEntity? currentMedia;
  final int? currentMediaIndex;
  final bool showInfo;
  final bool isModified;
  final bool isNew;

  /// Identificadores de los elementos marcados en la rejilla.
  final Set<int> selectedIds;

  /// Por qué se está buscando: las pastillas de la barra, en su orden.
  ///
  /// Vacía cuando la rejilla muestra la biblioteca entera y no un resultado de
  /// búsqueda. Antes eran dos campos —un texto o una sugerencia, nunca las dos—
  /// y por eso sólo se podía buscar una cosa a la vez.
  ///
  /// Puede llevar dentro una pastilla **sin confirmar**, que es lo que hay
  /// escrito en el campo: busca igual, pero la barra la devuelve al campo en vez
  /// de pintarla como una más.
  final List<SearchCriterionEntity> searchCriteria;

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

  /// Clases de contenido que el filtro de la cabecera deja ver. De partida las
  /// tres, que es la biblioteca entera.
  ///
  /// Va con [sourceFilters] y no con [searchFilters] porque es de la misma
  /// clase: de qué tipo es un fichero es un dato suyo, no de un resultado de
  /// búsqueda, así que recorta la rejilla haya búsqueda o no.
  final Set<MediaKind> typeFilters;

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
    this.listing = MediaListing.none,
    this.currentMediaIndex,
    this.showInfo = false,
    this.isModified = false,
    this.isNew = false,
    this.selectedIds = const {},
    this.searchCriteria = const [],
    this.searchSections,
    this.searchFilters = allSearchResultTypes,
    this.sourceFilters = ImportSource.allSources,
    this.typeFilters = allMediaKinds,
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

  /// Si el filtro de tipos deja ver [summary].
  bool showsType(MediaSummaryEntity summary) =>
      typeFilters.contains(MediaKind.of(summary.path));

  /// Si los dos filtros de contenido lo dejan ver.
  ///
  /// Los dos juntos y en un solo sitio: son la misma pregunta —«¿esto se pinta
  /// en la rejilla?»— y separarlos es la forma de que alguien aplique uno y se
  /// olvide del otro.
  bool shows(MediaSummaryEntity summary) =>
      showsSource(summary) && showsType(summary);

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

  /// Se está cruzando más de una pastilla.
  ///
  /// Es lo que decide que el resultado venga en un solo grupo, y lo que deja sin
  /// sentido al filtro de «de dónde salen los resultados»: con un único grupo,
  /// apagar una de sus tres casillas no recorta nada o lo vacía todo.
  bool get crossesCriteria =>
      searchCriteria.where((each) => each.label.trim().isNotEmpty).length > 1;

  List<MediaSearchSectionEntity>? get visibleSearchSections {
    final sections = searchSections;
    if (sections == null) return null;

    final visible = <MediaSearchSectionEntity>[];
    for (final section in sections) {
      // Cruzando no se aplica: el grupo único del cruce no pertenece a ninguna
      // de las tres clases más que por convenio, y apagar la de contenido lo
      // haría desaparecer entero sin que se entienda por qué.
      if (!crossesCriteria && !searchFilters.contains(section.type)) continue;

      final media = section.media.where(shows).toList();
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
    MediaListing ? listing,
    int ? currentMediaIndex,
    bool ? showInfo,
    bool ? isModified,
    bool ? isNew,
    Set<int> ? selectedIds,
    List<SearchCriterionEntity> ? searchCriteria,
    List<MediaSearchSectionEntity> ? searchSections,
    Set<SearchResultType> ? searchFilters,
    Set<ImportSource> ? sourceFilters,
    Set<MediaKind> ? typeFilters,
    bool ? favoritesOnly,
    bool ? isBusy,
    ImportSource ? importSource,
    DateTime ? lastImportAt,
  });

  @override
  List<Object?> get props => [
    // Las tres colecciones grandes se comparan **por identidad** y no por
    // dentro.
    //
    // El bloc mira si el estado nuevo es igual al anterior antes de emitirlo, y
    // con veinte mil contenidos eso era recorrer veinte mil entidades —cada una
    // con sus doce campos— en **cada** cambio de estado: marcar una celda, pasar
    // el ratón, abrir el panel. Ahí se iban los fotogramas.
    //
    // Comparar por identidad es correcto porque ninguna de las tres se toca por
    // dentro: cada cambio construye una colección nueva (`copyWith` conserva la
    // misma instancia de lo que no cambia, y quien la cambia la sustituye
    // entera). Y si alguna vez se construyera una lista nueva con lo mismo
    // dentro, lo que pasaría es una emisión de más —un repintado—, nunca una de
    // menos.
    SameInstance(mediaList),
    listing,
    currentMedia,
    currentMediaIndex,
    showInfo,
    isModified,
    isNew,
    SameInstance(selectedIds),
    searchCriteria,
    SameInstance(searchSections),
    searchFilters,
    sourceFilters,
    typeFilters,
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
    super.listing,
    super.showInfo,
    super.isModified,
    super.isNew,
    super.selectedIds,
    super.searchCriteria,
    super.searchSections,
    super.searchFilters,
    super.sourceFilters,
    super.typeFilters,
    super.favoritesOnly,
    super.isBusy,
    super.importSource,
    super.lastImportAt,
  });

  @override
  MediaLoading copyWith({
    MediaEntity ? currentMedia,
    List<MediaSummaryEntity> ? mediaList,
    MediaListing ? listing,
    int ? currentMediaIndex,
    bool ? showInfo,
    bool ? isModified,
    bool ? isNew,
    Set<int> ? selectedIds,
    List<SearchCriterionEntity> ? searchCriteria,
    List<MediaSearchSectionEntity> ? searchSections,
    Set<SearchResultType> ? searchFilters,
    Set<ImportSource> ? sourceFilters,
    Set<MediaKind> ? typeFilters,
    bool ? favoritesOnly,
    bool ? isBusy,
    ImportSource ? importSource,
    DateTime ? lastImportAt,
  }) {
    return MediaLoading(
      mediaList: mediaList ?? this.mediaList,
      listing: listing ?? this.listing,
      showInfo: showInfo ?? this.showInfo,
      isModified: isModified ?? this.isModified,
      isNew: isNew ?? this.isNew,
      selectedIds: selectedIds ?? this.selectedIds,
      searchCriteria: searchCriteria ?? this.searchCriteria,
      searchSections: searchSections ?? this.searchSections,
      searchFilters: searchFilters ?? this.searchFilters,
      sourceFilters: sourceFilters ?? this.sourceFilters,
      typeFilters: typeFilters ?? this.typeFilters,
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
    super.listing,
    required this.currentMediaIndex,
    required this.currentMedia,
    super.showInfo,
    super.isModified,
    super.isNew,
    super.selectedIds,
    super.searchCriteria,
    super.searchSections,
    super.searchFilters,
    super.sourceFilters,
    super.typeFilters,
    super.favoritesOnly,
    super.isBusy,
    super.importSource,
    super.lastImportAt,
  });

  @override
  MediaStates copyWith({
    MediaEntity ? currentMedia,
    List<MediaSummaryEntity> ? mediaList,
    MediaListing ? listing,
    int ? currentMediaIndex,
    bool ? showInfo,
    bool ? isModified,
    bool ? isNew,
    Set<int> ? selectedIds,
    List<SearchCriterionEntity> ? searchCriteria,
    List<MediaSearchSectionEntity> ? searchSections,
    Set<SearchResultType> ? searchFilters,
    Set<ImportSource> ? sourceFilters,
    Set<MediaKind> ? typeFilters,
    bool ? favoritesOnly,
    bool ? isBusy,
    ImportSource ? importSource,
    DateTime ? lastImportAt,
  }) {
    return DetailedMedia(
        mediaList: mediaList ?? this.mediaList,
        listing: listing ?? this.listing,
        currentMediaIndex: currentMediaIndex ?? this.currentMediaIndex,
        currentMedia: currentMedia ?? this.currentMedia,
        showInfo: showInfo ?? this.showInfo,
        isModified: isModified ?? this.isModified,
        isNew: isNew ?? this.isNew,
        selectedIds: selectedIds ?? this.selectedIds,
        searchCriteria: searchCriteria ?? this.searchCriteria,
        searchSections: searchSections ?? this.searchSections,
        searchFilters: searchFilters ?? this.searchFilters,
        sourceFilters: sourceFilters ?? this.sourceFilters,
        typeFilters: typeFilters ?? this.typeFilters,
          favoritesOnly: favoritesOnly ?? this.favoritesOnly,
        isBusy: isBusy ?? this.isBusy,
        importSource: importSource ?? this.importSource,
      lastImportAt: lastImportAt ?? this.lastImportAt,
    );
  }
}
