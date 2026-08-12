import 'package:Fern/features/media/domain/usecases/confirm_media_list_usecase.dart';
import 'package:Fern/features/media/domain/usecases/delete_media_list_usecase.dart';
import 'package:Fern/features/media/domain/usecases/delete_missing_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_deleted_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_favorite_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_by_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_scanned_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/remove_tag_from_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/mark_media_deleted_usecase.dart';
import 'package:Fern/features/media/domain/usecases/purge_deleted_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/purge_expired_deleted_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/restore_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_details_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_list_usercase.dart';
import 'package:Fern/features/media/domain/usecases/scan_directory_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_media_by_suggestion_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/set_media_favorite_usecase.dart';
import 'package:Fern/features/media/domain/usecases/select_scan_directory_usecase.dart';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/entities/media/media_entity.dart';
import '../../domain/entities/media/media_summary_entity.dart';
import '../../domain/entities/search/media_search_section_entity.dart';
import '../../domain/entities/search/search_result_type.dart';
import '../../domain/entities/search/search_suggestion_entity.dart';
import 'media_events.dart';
import 'media_states.dart';

class MediaBloc extends Bloc<MediaEvents, MediaStates> {
  final SelectAndScanDirectoryUsecase _selectAndScanDirectoryUsecase;
  final ScanDirectoryUseCase _scanDirectoryUseCase;
  final GetMediaDetailsUsecase _getMediaDetailsUsecase;
  final SaveMediaUseCase _saveMediaUseCase;
  final DeleteMissingMediaUseCase _deleteMissingMediaUseCase;
  final DeleteMediaListUseCase _deleteMediaListUseCase;
  final MarkMediaDeletedUseCase _markMediaDeletedUseCase;
  final RestoreMediaUseCase _restoreMediaUseCase;
  final PurgeDeletedMediaUseCase _purgeDeletedMediaUseCase;
  final PurgeExpiredDeletedMediaUseCase _purgeExpiredDeletedMediaUseCase;
  final ConfirmMediaListUseCase _confirmMediaListUseCase;
  final GetScannedMediaUseCase _getScannedMediaUseCase;
  final GetMediaListUsercase _getMediaListUsecase;
  final GetDeletedMediaUseCase _getDeletedMediaUseCase;
  final GetFavoriteMediaUseCase _getFavoriteMediaUseCase;
  final GetMediaByTagUseCase _getMediaByTagUseCase;
  final RemoveTagFromMediaUseCase _removeTagFromMediaUseCase;
  final SetMediaFavoriteUseCase _setMediaFavoriteUseCase;
  final SearchMediaUseCase _searchMediaUseCase;
  final SearchMediaBySuggestionUseCase _searchMediaBySuggestionUseCase;

  /// Punto de partida de la selección por rango: el último elemento que se ha
  /// marcado o desmarcado a mano. No forma parte del estado porque no se pinta,
  /// sólo decide desde dónde se extiende el siguiente mayúsculas + clic.
  int? _selectionAnchorId;

  MediaBloc({
    required SelectAndScanDirectoryUsecase selectAndScanDirectoryUsecase,
    required ScanDirectoryUseCase scanDirectoryUseCase,
    required GetMediaDetailsUsecase getMediaDetailsUsecase,
    required SaveMediaUseCase saveMediaUseCase,
    required DeleteMissingMediaUseCase deleteMissingMediaUseCase,
    required DeleteMediaListUseCase deleteMediaListUseCase,
    required MarkMediaDeletedUseCase markMediaDeletedUseCase,
    required RestoreMediaUseCase restoreMediaUseCase,
    required PurgeDeletedMediaUseCase purgeDeletedMediaUseCase,
    required PurgeExpiredDeletedMediaUseCase purgeExpiredDeletedMediaUseCase,
    required ConfirmMediaListUseCase confirmMediaListUseCase,
    required GetScannedMediaUseCase getScannedMediaUseCase,
    required GetMediaListUsercase getMediaListUsecase,
    required GetDeletedMediaUseCase getDeletedMediaUseCase,
    required GetFavoriteMediaUseCase getFavoriteMediaUseCase,
    required GetMediaByTagUseCase getMediaByTagUseCase,
    required RemoveTagFromMediaUseCase removeTagFromMediaUseCase,
    required SetMediaFavoriteUseCase setMediaFavoriteUseCase,
    required SearchMediaUseCase searchMediaUseCase,
    required SearchMediaBySuggestionUseCase searchMediaBySuggestionUseCase,
  })  : _selectAndScanDirectoryUsecase = selectAndScanDirectoryUsecase,
        _scanDirectoryUseCase = scanDirectoryUseCase,
        _getMediaDetailsUsecase = getMediaDetailsUsecase,
        _saveMediaUseCase = saveMediaUseCase,
        _deleteMissingMediaUseCase = deleteMissingMediaUseCase,
        _deleteMediaListUseCase = deleteMediaListUseCase,
        _markMediaDeletedUseCase = markMediaDeletedUseCase,
        _restoreMediaUseCase = restoreMediaUseCase,
        _purgeDeletedMediaUseCase = purgeDeletedMediaUseCase,
        _purgeExpiredDeletedMediaUseCase = purgeExpiredDeletedMediaUseCase,
        _confirmMediaListUseCase = confirmMediaListUseCase,
        _getScannedMediaUseCase = getScannedMediaUseCase,
        _getMediaListUsecase = getMediaListUsecase,
        _getDeletedMediaUseCase = getDeletedMediaUseCase,
        _getFavoriteMediaUseCase = getFavoriteMediaUseCase,
        _getMediaByTagUseCase = getMediaByTagUseCase,
        _removeTagFromMediaUseCase = removeTagFromMediaUseCase,
        _setMediaFavoriteUseCase = setMediaFavoriteUseCase,
        _searchMediaUseCase = searchMediaUseCase,
        _searchMediaBySuggestionUseCase = searchMediaBySuggestionUseCase,
        super(const MediaLoading()) {
    on<LoadScannedMediaEvent>(onLoadScannedMedia);
    on<LoadMediaLibraryEvent>(onLoadMediaLibrary);
    on<LoadDeletedMediaEvent>(onLoadDeletedMedia);
    on<LoadFavoriteMediaEvent>(onLoadFavoriteMedia);
    on<LoadMediaByTagEvent>(onLoadMediaByTag);
    on<RemoveTagFromSelectedMediaEvent>(onRemoveTagFromSelectedMedia);
    on<ToggleFavoriteEvent>(onToggleFavorite);
    on<SearchMediaEvent>(onSearchMedia);
    on<SearchSuggestionSelectedEvent>(onSearchSuggestionSelected);
    on<ToggleSearchFilterEvent>(onToggleSearchFilter);
    on<ClearMediaSearchEvent>(onClearMediaSearch);
    on<ScanDirectoryEvent>(onScanDirectoryEvent);
    on<SelectAndScanDirectoryEvent>(onSelectAndScanDirectoryEvent);
    on<MediaClickedEvent>(onMediaClicked);
    on<ToggleMediaSelectionEvent>(onToggleMediaSelection);
    on<SelectMediaRangeEvent>(onSelectMediaRange);
    on<ClearMediaSelectionEvent>(onClearMediaSelection);
    on<ViewerNextEvent>(onViewerNextEvent);
    on<ToggleInfoEvent>(onToggleInfoEvent);
    on<SetInfoVisibilityEvent>(onSetInfoVisibility);
    on<SaveMediaEvent>(onSaveMedia);
    on<DeleteMediaEvent>(onDeleteMedia);
    on<MediaLoadFailedEvent>(onMediaLoadFailed);
    on<DeleteSelectedMediaEvent>(onDeleteSelectedMedia);
    on<RestoreSelectedMediaEvent>(onRestoreSelectedMedia);
    on<PurgeDeletedMediaEvent>(onPurgeDeletedMedia);
    on<ConfirmSelectedMediaEvent>(onConfirmSelectedMedia);
    on<UpdateMediaInfoEvent>(onUpdateMediaInfo);
    on<UpdateMediaDescriptionEvent>(onUpdateMediaDescription);
  }

  void onLoadScannedMedia(LoadScannedMediaEvent event, Emitter<MediaStates> emit) async {
    emit(const MediaLoading());
    final result = await _getScannedMediaUseCase();
    if (result is DataSuccess && result.data != null) {
      emit(MediaLoading(mediaList: result.data!));
    } else {
      emit(const MediaLoading(mediaList: []));
    }
  }

  /// Contenido definitivo de la base de datos, el de la pantalla de media.
  ///
  /// Se descarta el contenido que hubiera en el estado (que es el de la
  /// pantalla anterior) para que la rejilla no mezcle las dos listas.
  void onLoadMediaLibrary(LoadMediaLibraryEvent event, Emitter<MediaStates> emit) async {
    await _loadLibrary(emit);
  }

  /// Contenido marcado para borrar, el de la pantalla de eliminados.
  ///
  /// Como en las otras pantallas, se parte de un estado limpio: ni la lista ni
  /// la selección de la pantalla anterior tienen nada que ver con esta.
  ///
  /// Antes de leer se pasa el corte de caducidad: al arrancar ya se hace, pero la
  /// aplicación puede llevar días abierta y lo que se enseñe aquí (y su contador)
  /// tiene que ser lo que de verdad queda en la papelera.
  void onLoadDeletedMedia(LoadDeletedMediaEvent event, Emitter<MediaStates> emit) async {
    emit(const MediaLoading());

    await _purgeExpiredDeletedMediaUseCase();

    final result = await _getDeletedMediaUseCase();
    if (result is DataSuccess && result.data != null) {
      emit(MediaLoading(mediaList: result.data!));
    } else {
      emit(const MediaLoading(mediaList: []));
    }
  }

  /// Contenido favorito, el de la pantalla de favoritos.
  ///
  /// Como en las demás pantallas se parte de un estado limpio, y además se
  /// marca la lista como la de favoritos: es lo que hace que quitar el corazón
  /// desde el visor saque el contenido de esta rejilla y no de las otras.
  void onLoadFavoriteMedia(LoadFavoriteMediaEvent event, Emitter<MediaStates> emit) async {
    emit(const MediaLoading(favoritesOnly: true));

    final result = await _getFavoriteMediaUseCase();
    final mediaList = (result is DataSuccess && result.data != null)
        ? result.data!
        : const <MediaSummaryEntity>[];

    emit(MediaLoading(mediaList: mediaList, favoritesOnly: true));
  }

  /// Contenido de una etiqueta, el de la rejilla de la pantalla de gestión de
  /// etiquetas.
  ///
  /// Como en las demás pantallas se parte de un estado limpio: cambiar de
  /// etiqueta es cambiar de rejilla, así que la selección de la anterior no tiene
  /// nada que ver con la nueva.
  void onLoadMediaByTag(LoadMediaByTagEvent event, Emitter<MediaStates> emit) async {
    emit(const MediaLoading());

    final result = await _getMediaByTagUseCase(params: event.tagId);
    final mediaList = (result is DataSuccess && result.data != null)
        ? result.data!
        : const <MediaSummaryEntity>[];

    emit(MediaLoading(mediaList: mediaList));
  }

  /// Quita la etiqueta de la selección de la rejilla.
  ///
  /// Los contenidos dejan de tener esa etiqueta, así que salen de la rejilla de la
  /// pantalla de gestión de etiquetas (que es justo la de esa etiqueta); en la
  /// base de datos siguen tal cual, con sus demás etiquetas.
  void onRemoveTagFromSelectedMedia(
    RemoveTagFromSelectedMediaEvent event,
    Emitter<MediaStates> emit,
  ) async {
    final selectedIds = state.selectedIds;
    if (selectedIds.isEmpty) return;

    final result = await _removeTagFromMediaUseCase(
      params: RemoveTagFromMediaParams(
        tagId: event.tagId,
        mediaIds: selectedIds.toList(),
      ),
    );
    if (result is! DataSuccess) return;

    emit(_withoutSelection((summary) => selectedIds.contains(summary.id)));
  }

  /// El corazón del visor: pone o quita la marca de favorito del contenido que
  /// se está viendo, y la escribe en el momento.
  ///
  /// En la pantalla de favoritos, quitarla es sacar el contenido de la lista:
  /// como al eliminar desde el visor, el estado se queda sin contenido actual y
  /// el visor se cierra. En cualquier otra pantalla el contenido se queda donde
  /// está y sólo cambia el corazón.
  void onToggleFavorite(ToggleFavoriteEvent event, Emitter<MediaStates> emit) async {
    final media = state.currentMedia;
    if (media == null) return;

    final isFavorite = !media.isFavorite;

    final result = await _setMediaFavoriteUseCase(
      params: (id: media.id, isFavorite: isFavorite),
    );
    if (result is! DataSuccess) return;

    if (!isFavorite && state.favoritesOnly) {
      emit(MediaLoading(
        mediaList: List<MediaSummaryEntity>.from(state.mediaList ?? const [])
          ..removeWhere((summary) => summary.id == media.id),
        selectedIds: Set<int>.from(state.selectedIds)..remove(media.id),
        favoritesOnly: true,
      ));
      return;
    }

    emit(state.copyWith(currentMedia: media.copyWith(isFavorite: isFavorite)));
  }

  /// Vuelve a la biblioteca completa, sin búsqueda ni selección.
  Future<void> _loadLibrary(Emitter<MediaStates> emit) async {
    emit(const MediaLoading());
    final result = await _getMediaListUsecase();
    if (result is DataSuccess && result.data != null) {
      emit(MediaLoading(mediaList: result.data!));
    } else {
      emit(const MediaLoading(mediaList: []));
    }
  }

  /// Búsqueda por texto: todo lo que se parezca a lo escrito.
  void onSearchMedia(SearchMediaEvent event, Emitter<MediaStates> emit) async {
    final term = event.query.trim();
    if (term.isEmpty) {
      await _loadLibrary(emit);
      return;
    }

    final result = await _searchMediaUseCase(params: term);
    if (result is! DataSuccess) return;

    final sections = result.data ?? const <MediaSearchSectionEntity>[];

    emit(_searchState(sections, query: term));
  }

  /// Búsqueda de la sugerencia elegida: sólo su contenido.
  ///
  /// El texto del buscador se queda como está (es el nombre de lo elegido), pero
  /// lo que manda a partir de aquí es la sugerencia: se guarda en el estado para
  /// que volver a la pantalla repita **esta** búsqueda y no la de su nombre.
  void onSearchSuggestionSelected(
    SearchSuggestionSelectedEvent event,
    Emitter<MediaStates> emit,
  ) async {
    final result = await _searchMediaBySuggestionUseCase(params: event.suggestion);
    if (result is! DataSuccess) return;

    emit(_searchState(
      result.data ?? const [],
      query: event.suggestion.label,
      suggestion: event.suggestion,
    ));
  }

  /// Estado de un resultado de búsqueda.
  ///
  /// La rejilla pinta los grupos, pero el visor se mueve por índice sobre una
  /// lista plana, así que se guardan las dos cosas: los grupos (todos, también
  /// los que el filtro esconde) y el contenido que se ve, aplanado en el mismo
  /// orden.
  ///
  /// El filtro se mantiene de una búsqueda a la siguiente: es cómo se quiere ver
  /// el buscador, no parte de un resultado concreto.
  MediaStates _searchState(
    List<MediaSearchSectionEntity> sections, {
    required String query,
    SearchSuggestionEntity? suggestion,
  }) {
    return MediaLoading(
      mediaList: _visibleMedia(sections, state.searchFilters),
      searchQuery: query,
      searchSections: sections,
      searchFilters: state.searchFilters,
      searchSuggestion: suggestion,
    );
  }

  /// Enciende o apaga un tipo de resultado en el filtro.
  ///
  /// No se vuelve a buscar: los grupos ya están en el estado, así que basta con
  /// rehacer la lista de lo que se ve. Lo que se esconde deja de estar marcado:
  /// las acciones de la cabecera trabajan sobre la selección y no pueden llevarse
  /// por delante contenido que no está a la vista.
  void onToggleSearchFilter(ToggleSearchFilterEvent event, Emitter<MediaStates> emit) {
    final filters = Set<SearchResultType>.from(state.searchFilters);
    if (!filters.remove(event.type)) filters.add(event.type);

    final sections = state.searchSections;
    if (sections == null) {
      emit(state.copyWith(searchFilters: filters));
      return;
    }

    final mediaList = _visibleMedia(sections, filters);
    final visibleIds = {for (final summary in mediaList) summary.id};

    emit(state.copyWith(
      searchFilters: filters,
      mediaList: mediaList,
      selectedIds: state.selectedIds.where(visibleIds.contains).toSet(),
    ));
  }

  /// El contenido de los grupos que [filters] deja pasar, aplanado en el orden en
  /// el que la rejilla los pinta.
  List<MediaSummaryEntity> _visibleMedia(
    List<MediaSearchSectionEntity> sections,
    Set<SearchResultType> filters,
  ) {
    return [
      for (final section in sections)
        if (filters.contains(section.type)) ...section.media,
    ];
  }

  void onClearMediaSearch(ClearMediaSearchEvent event, Emitter<MediaStates> emit) async {
    await _loadLibrary(emit);
  }

  void onUpdateMediaInfo(UpdateMediaInfoEvent event, Emitter<MediaStates> emit) {
    emit(state.copyWith(
      currentMedia: event.media,
      isModified: true,
    ));
  }

  void onUpdateMediaDescription(UpdateMediaDescriptionEvent event, Emitter<MediaStates> emit) {
    final media = state.currentMedia;
    if (media == null) return;

    emit(state.copyWith(
      currentMedia: media.copyWith(description: event.description),
      isModified: true,
    ));
  }

  void onSaveMedia(SaveMediaEvent event, Emitter<MediaStates> emit) async {
    final result = await _saveMediaUseCase(params: event.media);
    if (result is! DataSuccess) return;

    // Al guardar, la gestión de archivos puede haber llevado el fichero a otra
    // carpeta; el visor lo sigue enseñando, así que se queda con la ruta nueva.
    final newPath = result.data is String ? result.data as String : null;
    final saved = event.media.copyWith(isImported: true, path: newPath);

    // El contenido pasa a ser definitivo. Si la lista de la pantalla es la de
    // contenido pendiente de revisar (la de importación), el elemento deja de
    // pertenecer a ella y se quita; si ya era definitivo (la de media), se
    // queda donde está.
    final mediaList = List<MediaSummaryEntity>.from(state.mediaList ?? const []);
    final index = mediaList.indexWhere((summary) => summary.id == event.media.id);
    if (index != -1 && !mediaList[index].isImported) {
      mediaList.removeAt(index);
    } else if (index != -1) {
      // Se queda en la lista, pero con la ruta que tenga ahora el fichero.
      mediaList[index] = MediaSummaryEntity(
        id: saved.id,
        path: saved.path,
        isImported: true,
      );
    }

    // El índice del visor apunta a la lista que se acaba de recortar.
    final currentMediaIndex = mediaList.isEmpty
        ? 0
        : (state.currentMediaIndex ?? 0).clamp(0, mediaList.length - 1);

    emit(state.copyWith(
      currentMedia: saved,
      mediaList: mediaList,
      currentMediaIndex: currentMediaIndex,
      isModified: false,
      isNew: false,
    ));
  }

  /// Eliminar desde el visor. El contenido sale de la lista de la pantalla de la
  /// que venía y, al quedarse el estado sin contenido actual, el visor se cierra.
  ///
  /// Lo que ya estuviera marcado no se toca: en la pantalla de eliminados el
  /// botón no tiene nada que hacer, el borrado definitivo se fuerza desde su
  /// cabecera.
  void onDeleteMedia(DeleteMediaEvent event, Emitter<MediaStates> emit) async {
    final id = event.media.id;

    final isMarked = state.mediaList
            ?.any((summary) => summary.id == id && summary.isDeleted) ??
        false;
    if (isMarked) return;

    // El visor se abre desde cualquier pantalla, así que quien decide es el
    // propio contenido: si todavía está pendiente de revisar se descarta.
    final isPending = !event.media.isImported;
    final removed = await _removedContent(
      discarded: isPending ? [id] : const [],
      marked: isPending ? const [] : [id],
    );
    if (removed.isEmpty) return;

    final newList = List<MediaSummaryEntity>.from(state.mediaList ?? [])
      ..removeWhere((element) => element.id == id);

    emit(MediaLoading(
      mediaList: newList,
      selectedIds: Set<int>.from(state.selectedIds)..remove(id),
      searchQuery: state.searchQuery,
      searchSections: _sectionsWithout((summary) => summary.id == id),
      searchFilters: state.searchFilters,
      favoritesOnly: state.favoritesOnly,
    ));
  }

  /// Quita contenido de la aplicación de las dos maneras que hay, y devuelve los
  /// identificadores que se han llegado a quitar.
  ///
  /// [discarded] se borra de la base de datos y [marked] se marca para borrar. Es
  /// el único sitio donde se decide una cosa u otra: lo pendiente de revisar se
  /// descarta (descartarlo al importar es no quererlo, no guardarlo en la
  /// papelera, y su fichero sigue en el disco para volver a escanearlo) y lo
  /// definitivo pasa por la pantalla de eliminados.
  Future<Set<int>> _removedContent({
    required List<int> discarded,
    required List<int> marked,
  }) async {
    final removed = <int>{};

    if (discarded.isNotEmpty) {
      final result = await _deleteMediaListUseCase(params: discarded);
      if (result is DataSuccess) removed.addAll(discarded);
    }

    if (marked.isNotEmpty) {
      final result = await _markMediaDeletedUseCase(params: marked);
      if (result is DataSuccess) removed.addAll(marked);
    }

    return removed;
  }

  /// Un contenido no se ha podido pintar.
  ///
  /// Sólo desaparece si el motivo es que su fichero ya no está donde decía su
  /// ruta (borrado o movido por fuera de la aplicación); de eso se encarga el
  /// caso de uso, así que aquí basta con mirar si ha llegado a borrar la fila.
  void onMediaLoadFailed(MediaLoadFailedEvent event, Emitter<MediaStates> emit) async {
    final result = await _deleteMissingMediaUseCase(params: event.id);
    if (result is! DataSuccess || result.data != true) return;

    bool isMissing(MediaSummaryEntity summary) => summary.id == event.id;

    final mediaList = List<MediaSummaryEntity>.from(state.mediaList ?? const [])
      ..removeWhere(isMissing);
    final sections = _sectionsWithout(isMissing);
    final selectedIds = Set<int>.from(state.selectedIds)..remove(event.id);

    // Lo que ha desaparecido es justo lo que el visor está enseñando: hay que
    // pasar al siguiente contenido, que al recortar la lista ocupa ahora este
    // mismo índice.
    final wasCurrent = state.currentMedia?.id == event.id;
    final index = state.currentMediaIndex ?? 0;

    if (!wasCurrent) {
      // El visor (si está abierto) sigue enseñando lo suyo; sólo se ajusta el
      // índice, que al recortar la lista ha podido moverse.
      final current = state.currentMedia;
      final currentIndex = current == null
          ? null
          : mediaList.indexWhere((summary) => summary.id == current.id);

      emit(state.copyWith(
        mediaList: mediaList,
        searchSections: sections,
        selectedIds: selectedIds,
        currentMediaIndex: (currentIndex ?? -1) >= 0 ? currentIndex : null,
      ));
      return;
    }

    // Sin contenido no queda nada que enseñar: el estado se queda sin elemento
    // actual, que es la señal con la que el visor se cierra.
    if (mediaList.isEmpty) {
      emit(MediaLoading(
        mediaList: const [],
        selectedIds: selectedIds,
        showInfo: state.showInfo,
        searchQuery: state.searchQuery,
        searchSections: sections,
        searchFilters: state.searchFilters,
        searchSuggestion: state.searchSuggestion,
        favoritesOnly: state.favoritesOnly,
      ));
      return;
    }

    // Paso intermedio con la lista ya recortada: el visor sigue enseñando lo de
    // antes hasta que lleguen los detalles del siguiente, de modo que no pasa
    // por un instante sin contenido actual y no se cierra por error.
    emit(state.copyWith(
      mediaList: mediaList,
      searchSections: sections,
      selectedIds: selectedIds,
    ));

    final nextIndex = index.clamp(0, mediaList.length - 1);
    emit(await _detailsOf(mediaList[nextIndex], nextIndex));
  }

  /// Borrado masivo de la selección de la rejilla.
  ///
  /// Cada contenido va por donde le toca: lo que está pendiente de revisar (la
  /// pantalla de importación) se descarta de la base de datos y lo definitivo se
  /// marca y aparece en la pantalla de eliminados.
  void onDeleteSelectedMedia(DeleteSelectedMediaEvent event, Emitter<MediaStates> emit) async {
    final selectedIds = state.selectedIds;
    if (selectedIds.isEmpty) return;

    final selected = (state.mediaList ?? const <MediaSummaryEntity>[])
        .where((summary) => selectedIds.contains(summary.id));

    final removed = await _removedContent(
      discarded: [for (final summary in selected) if (!summary.isImported) summary.id],
      marked: [for (final summary in selected) if (summary.isImported) summary.id],
    );
    if (removed.isEmpty) return;

    emit(_withoutSelection((summary) => removed.contains(summary.id)));
  }

  /// Restablecimiento de la selección en la pantalla de eliminados: el contenido
  /// pierde la marca y vuelve a la pantalla que le toque, así que sale de esta.
  void onRestoreSelectedMedia(RestoreSelectedMediaEvent event, Emitter<MediaStates> emit) async {
    final selectedIds = state.selectedIds;
    if (selectedIds.isEmpty) return;

    final result = await _restoreMediaUseCase(params: selectedIds.toList());
    if (result is! DataSuccess) return;

    emit(_withoutSelection((summary) => selectedIds.contains(summary.id)));
  }

  /// Borrado definitivo de todo lo marcado, forzado desde la pantalla de
  /// eliminados: la pantalla se queda vacía porque ya no queda nada marcado.
  ///
  /// Los ficheros siguen en el disco, así que un escaneo posterior los recoge
  /// otra vez como contenido nuevo.
  void onPurgeDeletedMedia(PurgeDeletedMediaEvent event, Emitter<MediaStates> emit) async {
    final result = await _purgeDeletedMediaUseCase();
    if (result is! DataSuccess) return;

    emit(const MediaLoading(mediaList: []));
  }

  /// Confirmación masiva de la selección de la rejilla: los contenidos pasan a
  /// ser definitivos con los datos que tengan, revisados o no.
  ///
  /// Como en [onSaveMedia], salen de la lista los que estaban pendientes: esa
  /// lista es la de la pantalla de importación y ya no pertenecen a ella.
  void onConfirmSelectedMedia(ConfirmSelectedMediaEvent event, Emitter<MediaStates> emit) async {
    final selectedIds = state.selectedIds;
    if (selectedIds.isEmpty) return;

    final result = await _confirmMediaListUseCase(params: selectedIds.toList());
    if (result is! DataSuccess) return;

    emit(_withoutSelection(
      (summary) => selectedIds.contains(summary.id) && !summary.isImported,
    ));
  }

  /// Estado resultante de sacar de la lista los elementos que cumplen [remove].
  /// La selección se queda vacía: ya se ha actuado sobre ella.
  MediaStates _withoutSelection(bool Function(MediaSummaryEntity summary) remove) {
    final mediaList = List<MediaSummaryEntity>.from(state.mediaList ?? const [])
      ..removeWhere(remove);

    return MediaLoading(
      mediaList: mediaList,
      searchQuery: state.searchQuery,
      searchSections: _sectionsWithout(remove),
      searchFilters: state.searchFilters,
      searchSuggestion: state.searchSuggestion,
      favoritesOnly: state.favoritesOnly,
    );
  }

  /// Los grupos de la búsqueda sin los contenidos que cumplen [remove]; los
  /// grupos que se quedan vacíos desaparecen con su cabecera.
  ///
  /// Devuelve `null` si no hay búsqueda en marcha, que es lo que la rejilla
  /// entiende como "pinta la lista sin cabeceras".
  List<MediaSearchSectionEntity>? _sectionsWithout(
    bool Function(MediaSummaryEntity summary) remove,
  ) {
    final sections = state.searchSections;
    if (sections == null) return null;

    final result = <MediaSearchSectionEntity>[];
    for (final section in sections) {
      final media = section.media.where((summary) => !remove(summary)).toList();
      if (media.isEmpty) continue;

      result.add(MediaSearchSectionEntity(
        type: section.type,
        title: section.title,
        imagePath: section.imagePath,
        media: media,
      ));
    }
    return result;
  }

  void onToggleMediaSelection(ToggleMediaSelectionEvent event, Emitter<MediaStates> emit) {
    final selectedIds = Set<int>.from(state.selectedIds);
    if (!selectedIds.remove(event.media.id)) selectedIds.add(event.media.id);

    _selectionAnchorId = event.media.id;
    emit(state.copyWith(selectedIds: selectedIds));
  }

  /// Selección por rango: se marca todo lo que hay entre el último elemento con
  /// el que se ha interactuado y el de este evento, ambos incluidos.
  ///
  /// Lo que ya estuviera marcado sigue estándolo: el rango suma, nunca sustituye
  /// a la selección anterior.
  void onSelectMediaRange(SelectMediaRangeEvent event, Emitter<MediaStates> emit) {
    final orderedIds = event.orderedIds;
    final targetIndex = orderedIds.indexOf(event.media.id);
    if (targetIndex < 0) return;

    final anchorId = _selectionAnchorId;
    final anchorIndex = anchorId == null ? -1 : orderedIds.indexOf(anchorId);

    // Sin punto de partida (no hay nada marcado todavía, o lo que había ya no
    // está en la rejilla) no hay rango que valga: el clic marca este elemento y
    // deja aquí el punto de partida del siguiente.
    if (anchorIndex < 0) {
      _selectionAnchorId = event.media.id;
      emit(state.copyWith(selectedIds: {...state.selectedIds, event.media.id}));
      return;
    }

    final start = math.min(anchorIndex, targetIndex);
    final end = math.max(anchorIndex, targetIndex);

    emit(state.copyWith(selectedIds: {
      ...state.selectedIds,
      ...orderedIds.sublist(start, end + 1),
    }));
  }

  void onClearMediaSelection(ClearMediaSelectionEvent event, Emitter<MediaStates> emit) {
    _selectionAnchorId = null;
    emit(state.copyWith(selectedIds: const {}));
  }

  void onMediaClicked(MediaClickedEvent event, Emitter<MediaStates> emit) async {
    emit(MediaLoading(
      mediaList: state.mediaList,
      selectedIds: state.selectedIds,
      searchQuery: state.searchQuery,
      searchSections: state.searchSections,
      searchFilters: state.searchFilters,
      searchSuggestion: state.searchSuggestion,
      favoritesOnly: state.favoritesOnly,
    ));

    final index = state.mediaList!.indexWhere((element) => element.id == event.media.id);

    emit(await _detailsOf(event.media, index));
  }

  /// Estado del visor para un elemento de la rejilla.
  ///
  /// Los contenidos escaneados ya tienen fila de detalles (creador desconocido,
  /// sin descripción ni etiquetas), así que lo normal es leerla de la base;
  /// `isNew` sale de si el contenido ha sido revisado o no, no de si existe.
  /// El respaldo cubre las filas antiguas que se guardaron sólo como sumario.
  Future<DetailedMedia> _detailsOf(MediaSummaryEntity summary, int index) async {
    final databaseResult = await _getMediaDetailsUsecase(params: summary.id);

    final media = (databaseResult is DataSuccess && databaseResult.data != null)
        ? databaseResult.data!
        : MediaEntity(
            id: summary.id,
            path: summary.path,
            isImported: summary.isImported,
            downloaded: DateTime.now(),
            creator: unknownCreator,
          );

    return DetailedMedia(
      currentMediaIndex: index,
      currentMedia: media,
      mediaList: state.mediaList,
      isNew: !media.isImported,
      showInfo: state.showInfo,
      selectedIds: state.selectedIds,
      // El visor se abre sobre la rejilla: al volver, la búsqueda sigue
      // exactamente como estaba.
      searchQuery: state.searchQuery,
      searchSections: state.searchSections,
      searchFilters: state.searchFilters,
      searchSuggestion: state.searchSuggestion,
      favoritesOnly: state.favoritesOnly,
    );
  }

  void onScanDirectoryEvent(ScanDirectoryEvent event, Emitter<MediaStates> emit) async {
    List<MediaSummaryEntity> currentMedia = state.mediaList != null ? List.from(state.mediaList!) : [];
    final selectedIds = state.selectedIds;
    emit(MediaLoading(mediaList: currentMedia, selectedIds: selectedIds));

    final stream = await _scanDirectoryUseCase();

    await emit.forEach<DataState<MediaSummaryEntity>>(
      stream,
      onData: (dataState) {
        if (dataState is DataSuccess && dataState.data != null) {
          currentMedia = List.from(currentMedia)..add(dataState.data!);
          return MediaLoading(mediaList: currentMedia, selectedIds: selectedIds);
        }
        return state;
      },
    );
  }

  void onSelectAndScanDirectoryEvent(SelectAndScanDirectoryEvent event, Emitter<MediaStates> emit) async {
    List<MediaSummaryEntity> currentMedia = state.mediaList != null ? List.from(state.mediaList!) : [];
    final selectedIds = state.selectedIds;
    emit(MediaLoading(mediaList: currentMedia, selectedIds: selectedIds));

    final stream = await _selectAndScanDirectoryUsecase();

    await emit.forEach<DataState<MediaSummaryEntity>>(
      stream,
      onData: (dataState) {
        if (dataState is DataSuccess && dataState.data != null) {
          currentMedia = List.from(currentMedia)..add(dataState.data!);
          return MediaLoading(mediaList: currentMedia, selectedIds: selectedIds);
        }
        return state;
      },
    );
  }

  void onViewerNextEvent(ViewerNextEvent event, Emitter<MediaStates> emit) async {
    final int length = state.mediaList!.length;
    if (length == 0) return;

    final int offset = event.next ? 1 : -1;
    final nextIdx = (state.currentMediaIndex! + offset + length) % length;
    final nextMedia = state.mediaList![nextIdx];

    emit(await _detailsOf(nextMedia, nextIdx));
  }

  void onToggleInfoEvent(ToggleInfoEvent event, Emitter<MediaStates> emit) {
    emit(state.copyWith(showInfo: !state.showInfo));
  }

  void onSetInfoVisibility(SetInfoVisibilityEvent event, Emitter<MediaStates> emit) {
    if (state.showInfo == event.visible) return;
    emit(state.copyWith(showInfo: event.visible));
  }
}
