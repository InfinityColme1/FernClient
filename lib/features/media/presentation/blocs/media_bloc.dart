import 'package:Fern/core/services/import_cancellation.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/domain/entities/media_deletion_kind.dart';
import 'package:Fern/features/media/domain/entities/empty_source.dart';
import 'package:Fern/features/media/domain/entities/remote_session_expired.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:Fern/features/media/domain/usecases/confirm_media_list_usecase.dart';
import 'package:Fern/features/media/domain/usecases/delete_media_list_usecase.dart';
import 'package:Fern/features/media/domain/usecases/delete_missing_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_deleted_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_favorite_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_by_creator_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_by_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/remove_creator_from_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_last_import_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_scanned_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/remove_tag_from_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/mark_media_deleted_usecase.dart';
import 'package:Fern/features/media/domain/usecases/purge_deleted_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/purge_expired_deleted_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/restore_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_details_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_list_usercase.dart';
import 'package:Fern/features/media/domain/usecases/scan_source_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_media_by_suggestion_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/set_media_favorite_usecase.dart';
import 'package:Fern/features/media/domain/usecases/set_media_list_favorite_usecase.dart';
import 'package:Fern/features/media/domain/usecases/select_scan_directory_usecase.dart';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/entities/import_source.dart';
import '../../domain/entities/media/media_entity.dart';
import '../../domain/entities/media/media_summary_entity.dart';
import '../../domain/entities/search/media_search_section_entity.dart';
import '../../domain/entities/search/search_result_type.dart';
import '../../domain/entities/search/search_suggestion_entity.dart';
import 'media_events.dart';
import 'media_states.dart';

class MediaBloc extends Bloc<MediaEvents, MediaStates> {
  final SelectAndScanDirectoryUsecase _selectAndScanDirectoryUsecase;
  final ScanSourceUseCase _scanSourceUseCase;
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
  final GetLastImportUseCase _getLastImportUseCase;
  final GetMediaListUsercase _getMediaListUsecase;
  final GetDeletedMediaUseCase _getDeletedMediaUseCase;
  final GetFavoriteMediaUseCase _getFavoriteMediaUseCase;
  final GetMediaByTagUseCase _getMediaByTagUseCase;
  final RemoveTagFromMediaUseCase _removeTagFromMediaUseCase;
  final GetMediaByCreatorUseCase _getMediaByCreatorUseCase;
  final RemoveCreatorFromMediaUseCase _removeCreatorFromMediaUseCase;
  final SetMediaFavoriteUseCase _setMediaFavoriteUseCase;
  final SetMediaListFavoriteUseCase _setMediaListFavoriteUseCase;
  final SearchMediaUseCase _searchMediaUseCase;
  final SearchMediaBySuggestionUseCase _searchMediaBySuggestionUseCase;

  /// Hace falta para el vaciado automático de la papelera, que es el único
  /// borrado sin aviso: de aquí sale lo que el usuario respondió la última vez
  /// que la vació a mano.
  final PreferencesService _preferences;

  /// La señal con la que se para una importación en marcha. La levanta el botón
  /// de la rejilla y la miran los recorridos de las fuentes.
  final ImportCancellation _cancellation;

  /// Por donde la importación pregunta al usuario qué hacer con lo que no puede
  /// decidir sola.
  final ImportDecisions _decisions;

  /// Punto de partida de la selección por rango: el último elemento que se ha
  /// marcado o desmarcado a mano. No forma parte del estado porque no se pinta,
  /// sólo decide desde dónde se extiende el siguiente mayúsculas + clic.
  int? _selectionAnchorId;

  MediaBloc({
    required SelectAndScanDirectoryUsecase selectAndScanDirectoryUsecase,
    required ScanSourceUseCase scanSourceUseCase,
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
    required GetLastImportUseCase getLastImportUseCase,
    required GetMediaListUsercase getMediaListUsecase,
    required GetDeletedMediaUseCase getDeletedMediaUseCase,
    required GetFavoriteMediaUseCase getFavoriteMediaUseCase,
    required GetMediaByTagUseCase getMediaByTagUseCase,
    required RemoveTagFromMediaUseCase removeTagFromMediaUseCase,
    required GetMediaByCreatorUseCase getMediaByCreatorUseCase,
    required RemoveCreatorFromMediaUseCase removeCreatorFromMediaUseCase,
    required SetMediaFavoriteUseCase setMediaFavoriteUseCase,
    required SetMediaListFavoriteUseCase setMediaListFavoriteUseCase,
    required SearchMediaUseCase searchMediaUseCase,
    required SearchMediaBySuggestionUseCase searchMediaBySuggestionUseCase,
    required PreferencesService preferences,
    required ImportCancellation cancellation,
    required ImportDecisions decisions,
  })  : _selectAndScanDirectoryUsecase = selectAndScanDirectoryUsecase,
        _scanSourceUseCase = scanSourceUseCase,
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
        _getLastImportUseCase = getLastImportUseCase,
        _getMediaListUsecase = getMediaListUsecase,
        _getDeletedMediaUseCase = getDeletedMediaUseCase,
        _getFavoriteMediaUseCase = getFavoriteMediaUseCase,
        _getMediaByTagUseCase = getMediaByTagUseCase,
        _removeTagFromMediaUseCase = removeTagFromMediaUseCase,
        _getMediaByCreatorUseCase = getMediaByCreatorUseCase,
        _removeCreatorFromMediaUseCase = removeCreatorFromMediaUseCase,
        _setMediaFavoriteUseCase = setMediaFavoriteUseCase,
        _setMediaListFavoriteUseCase = setMediaListFavoriteUseCase,
        _searchMediaUseCase = searchMediaUseCase,
        _searchMediaBySuggestionUseCase = searchMediaBySuggestionUseCase,
        _preferences = preferences,
        _cancellation = cancellation,
        _decisions = decisions,
        super(const MediaLoading()) {
    on<LoadScannedMediaEvent>(onLoadScannedMedia);
    on<LoadMediaLibraryEvent>(onLoadMediaLibrary);
    on<LoadDeletedMediaEvent>(onLoadDeletedMedia);
    on<LoadFavoriteMediaEvent>(onLoadFavoriteMedia);
    on<LoadMediaByTagEvent>(onLoadMediaByTag);
    on<RemoveTagFromSelectedMediaEvent>(onRemoveTagFromSelectedMedia);
    on<LoadMediaByCreatorEvent>(onLoadMediaByCreator);
    on<RemoveCreatorFromSelectedMediaEvent>(onRemoveCreatorFromSelectedMedia);
    on<ToggleFavoriteEvent>(onToggleFavorite);
    on<SearchMediaEvent>(onSearchMedia);
    on<SearchSuggestionSelectedEvent>(onSearchSuggestionSelected);
    on<ToggleSearchFilterEvent>(onToggleSearchFilter);
    on<ToggleSourceFilterEvent>(onToggleSourceFilter);
    on<ClearMediaSearchEvent>(onClearMediaSearch);
    on<ImportSourceChangedEvent>(onImportSourceChanged);
    on<ScanSourceEvent>(onScanSource);
    on<StopImportEvent>(onStopImport);
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
    on<PurgeMediaEvent>(onPurgeMedia);
    on<RestoreMediaEvent>(onRestoreMedia);
    on<MediaLoadFailedEvent>(onMediaLoadFailed);
    on<DeleteSelectedMediaEvent>(onDeleteSelectedMedia);
    on<FavoriteSelectedMediaEvent>(onFavoriteSelectedMedia);
    on<RestoreSelectedMediaEvent>(onRestoreSelectedMedia);
    on<PurgeDeletedMediaEvent>(onPurgeDeletedMedia);
    on<ConfirmSelectedMediaEvent>(onConfirmSelectedMedia);
    on<UpdateMediaInfoEvent>(onUpdateMediaInfo);
    on<UpdateMediaDescriptionEvent>(onUpdateMediaDescription);
  }

  /// El estado tal cual, pero sin la señal de espera.
  ///
  /// Es lo que se emite cuando una operación termina sin cambiar nada (porque ha
  /// fallado o porque no había nada que hacer): la pantalla se queda como estaba
  /// y el indicador de espera desaparece, que es lo que no puede olvidarse en
  /// ninguna salida.
  MediaStates get _idle => state.copyWith(isBusy: false);

  void onLoadScannedMedia(LoadScannedMediaEvent event, Emitter<MediaStates> emit) async {
    await _loadScanned(state.importSource, emit);
  }

  /// Cambiar de fuente cambia lo que se ve: la rejilla pasa a enseñar sólo lo
  /// que llegó de ella (o todo, con la opción de todas), así que se vuelve a
  /// leer con el filtro nuevo.
  void onImportSourceChanged(
    ImportSourceChangedEvent event,
    Emitter<MediaStates> emit,
  ) async {
    if (state.importSource == event.source) return;

    await _loadScanned(event.source, emit);
  }

  /// Contenido pendiente de revisar de [source], el de la pantalla de
  /// importación. Se parte de un estado limpio: la selección de lo que se estaba
  /// viendo no tiene nada que ver con lo que llega.
  Future<void> _loadScanned(ImportSource source, Emitter<MediaStates> emit) async {
    emit(MediaLoading(
      importSource: source,
      lastImportAt: await _getLastImportUseCase(params: source),
      isBusy: true,
    ));

    final result = await _getScannedMediaUseCase(params: source);
    final mediaList = (result is DataSuccess && result.data != null)
        ? result.data!
        : const <MediaSummaryEntity>[];

    emit(MediaLoading(
      mediaList: mediaList,
      importSource: source,
      lastImportAt: state.lastImportAt,
    ));
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
    emit(const MediaLoading(isBusy: true));

    // La caducidad se pasa sola, así que no hay aviso en el que preguntar por
    // los ficheros: se hace lo mismo que la última vez que se vació la papelera
    // a mano.
    await _purgeExpiredDeletedMediaUseCase(
      params: _preferences.getDeleteFiles(MediaDeletionKind.trash),
    );

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
    emit(const MediaLoading(favoritesOnly: true, isBusy: true));

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
    emit(const MediaLoading(isBusy: true));

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

    emit(state.copyWith(isBusy: true));

    final result = await _removeTagFromMediaUseCase(
      params: RemoveTagFromMediaParams(
        tagId: event.tagId,
        mediaIds: selectedIds.toList(),
      ),
    );
    if (result is! DataSuccess) {
      emit(_idle);
      return;
    }

    emit(_withoutSelection((summary) => selectedIds.contains(summary.id)));
  }

  /// Contenido de un creador, el de la rejilla de la pantalla de gestión de
  /// creadores.
  ///
  /// Como con las etiquetas se parte de un estado limpio: cambiar de creador es
  /// cambiar de rejilla, así que la selección del anterior no tiene nada que ver
  /// con la nueva.
  void onLoadMediaByCreator(
    LoadMediaByCreatorEvent event,
    Emitter<MediaStates> emit,
  ) async {
    emit(const MediaLoading(isBusy: true));

    final result = await _getMediaByCreatorUseCase(params: event.creatorId);
    final mediaList = (result is DataSuccess && result.data != null)
        ? result.data!
        : const <MediaSummaryEntity>[];

    emit(MediaLoading(mediaList: mediaList));
  }

  /// Quita el creador de la selección de la rejilla.
  ///
  /// Los contenidos pasan al creador desconocido, así que salen de la rejilla de
  /// la pantalla de gestión de creadores (que es justo la de ese creador); en la
  /// base de datos siguen tal cual, con sus etiquetas y su fichero.
  void onRemoveCreatorFromSelectedMedia(
    RemoveCreatorFromSelectedMediaEvent event,
    Emitter<MediaStates> emit,
  ) async {
    final selectedIds = state.selectedIds;
    if (selectedIds.isEmpty) return;

    emit(state.copyWith(isBusy: true));

    final result = await _removeCreatorFromMediaUseCase(
      params: RemoveCreatorFromMediaParams(
        creatorId: event.creatorId,
        mediaIds: selectedIds.toList(),
      ),
    );
    if (result is! DataSuccess) {
      emit(_idle);
      return;
    }

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

    emit(state.copyWith(isBusy: true));

    final result = await _setMediaFavoriteUseCase(
      params: (id: media.id, isFavorite: isFavorite),
    );
    if (result is! DataSuccess) {
      emit(_idle);
      return;
    }

    if (!isFavorite && state.favoritesOnly) {
      emit(MediaLoading(
        mediaList: List<MediaSummaryEntity>.from(state.mediaList ?? const [])
          ..removeWhere((summary) => summary.id == media.id),
        selectedIds: Set<int>.from(state.selectedIds)..remove(media.id),
        favoritesOnly: true,
      ));
      return;
    }

    emit(state.copyWith(
      currentMedia: media.copyWith(isFavorite: isFavorite),
      isBusy: false,
    ));
  }

  /// Vuelve a la biblioteca completa, sin búsqueda ni selección.
  ///
  /// El filtro de fuentes no es de la búsqueda sino de cómo se quiere ver la
  /// rejilla, así que se mantiene y recorta también la biblioteca.
  Future<void> _loadLibrary(Emitter<MediaStates> emit) async {
    final sourceFilters = state.sourceFilters;

    emit(MediaLoading(sourceFilters: sourceFilters, isBusy: true));

    final result = await _getMediaListUsecase();
    final mediaList = (result is DataSuccess && result.data != null)
        ? result.data!.where((summary) =>
            sourceFilters.contains(summary.importSource)).toList()
        : const <MediaSummaryEntity>[];

    emit(MediaLoading(mediaList: mediaList, sourceFilters: sourceFilters));
  }

  /// Búsqueda por texto: todo lo que se parezca a lo escrito.
  void onSearchMedia(SearchMediaEvent event, Emitter<MediaStates> emit) async {
    final term = event.query.trim();
    if (term.isEmpty) {
      await _loadLibrary(emit);
      return;
    }

    emit(state.copyWith(isBusy: true));

    final result = await _searchMediaUseCase(params: term);
    if (result is! DataSuccess) {
      emit(_idle);
      return;
    }

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
    emit(state.copyWith(isBusy: true));

    final result = await _searchMediaBySuggestionUseCase(params: event.suggestion);
    if (result is! DataSuccess) {
      emit(_idle);
      return;
    }

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
      mediaList: _visibleMedia(sections, state.searchFilters, state.sourceFilters),
      searchQuery: query,
      searchSections: sections,
      searchFilters: state.searchFilters,
      sourceFilters: state.sourceFilters,
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

    emit(_refiltered(sections, filters, state.sourceFilters));
  }

  /// Enciende o apaga una fuente en el filtro.
  ///
  /// Con una búsqueda en marcha se rehace lo que se ve a partir de los grupos que
  /// ya están en el estado, como con los tipos. Sin búsqueda hay que volver a la
  /// base de datos: la rejilla es la biblioteca entera y lo que se ha dejado
  /// fuera no está guardado en ninguna parte a la que volver.
  void onToggleSourceFilter(
    ToggleSourceFilterEvent event,
    Emitter<MediaStates> emit,
  ) async {
    final filters = Set<ImportSource>.from(state.sourceFilters);
    if (!filters.remove(event.source)) filters.add(event.source);

    final sections = state.searchSections;
    if (sections == null) {
      emit(state.copyWith(sourceFilters: filters));
      await _loadLibrary(emit);
      return;
    }

    emit(_refiltered(sections, state.searchFilters, filters));
  }

  /// El estado con los filtros nuevos aplicados sobre los grupos de la búsqueda.
  ///
  /// No se vuelve a buscar: los grupos siguen enteros en el estado, así que
  /// volver a encender algo lo devuelve a la rejilla tal cual estaba. Lo que se
  /// esconde deja de estar marcado: las acciones de la cabecera trabajan sobre la
  /// selección y no pueden llevarse por delante contenido que no está a la vista.
  MediaStates _refiltered(
    List<MediaSearchSectionEntity> sections,
    Set<SearchResultType> searchFilters,
    Set<ImportSource> sourceFilters,
  ) {
    final mediaList = _visibleMedia(sections, searchFilters, sourceFilters);
    final visibleIds = {for (final summary in mediaList) summary.id};

    return state.copyWith(
      searchFilters: searchFilters,
      sourceFilters: sourceFilters,
      mediaList: mediaList,
      selectedIds: state.selectedIds.where(visibleIds.contains).toSet(),
    );
  }

  /// El contenido de los grupos que [filters] deja pasar, sin lo que venga de una
  /// fuente apagada, aplanado en el orden en el que la rejilla los pinta.
  List<MediaSummaryEntity> _visibleMedia(
    List<MediaSearchSectionEntity> sections,
    Set<SearchResultType> filters,
    Set<ImportSource> sourceFilters,
  ) {
    return [
      for (final section in sections)
        if (filters.contains(section.type))
          for (final summary in section.media)
            if (sourceFilters.contains(summary.importSource)) summary,
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
    emit(state.copyWith(isBusy: true));

    final result = await _saveMediaUseCase(params: event.media);
    if (result is! DataSuccess) {
      emit(_idle);
      return;
    }

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
    var hasLeftTheList = false;
    if (index != -1 && !mediaList[index].isImported) {
      mediaList.removeAt(index);
      hasLeftTheList = true;
    } else if (index != -1) {
      // Se queda en la lista, pero con la ruta que tenga ahora el fichero.
      mediaList[index] = MediaSummaryEntity(
        id: saved.id,
        path: saved.path,
        isImported: true,
        importSource: mediaList[index].importSource,
      );
    }

    // El índice del visor apunta a la lista que se acaba de recortar.
    final currentMediaIndex = mediaList.isEmpty
        ? 0
        : (state.currentMediaIndex ?? 0).clamp(0, mediaList.length - 1);

    // Al guardar sin salir del visor, el contenido que se acaba de dar por
    // definitivo ya no está en la lista, así que el sitio al que apuntaba el
    // índice lo ocupa ahora el siguiente: pasar a él es leer sus detalles.
    if (event.goToNext && hasLeftTheList) {
      // La lista recortada tiene que estar en el estado antes de pedir los
      // detalles: es de ahí de donde los lee.
      emit(state.copyWith(
        currentMedia: saved,
        mediaList: mediaList,
        currentMediaIndex: currentMediaIndex,
        isModified: false,
        isNew: false,
        isBusy: true,
      ));

      // No queda nada que revisar: el visor se cierra solo al quedarse el
      // estado sin contenido, igual que cuando se borra el último.
      if (mediaList.isEmpty) {
        _emitWithoutViewerMedia(saved.id, emit);
        return;
      }

      emit(await _detailsOf(mediaList[currentMediaIndex], currentMediaIndex));
      return;
    }

    emit(state.copyWith(
      currentMedia: saved,
      mediaList: mediaList,
      currentMediaIndex: currentMediaIndex,
      isModified: false,
      isNew: false,
      isBusy: false,
    ));
  }

  /// Eliminar desde el visor. El contenido sale de la lista de la pantalla de la
  /// que venía y, al quedarse el estado sin contenido actual, el visor se cierra.
  ///
  /// Lo que ya estuviera marcado no pasa por aquí: desde la papelera, borrar es
  /// borrar del todo, y de eso se encarga [onPurgeMedia].
  void onDeleteMedia(DeleteMediaEvent event, Emitter<MediaStates> emit) async {
    final id = event.media.id;
    if (_isMarkedForDeletion(id)) return;

    emit(state.copyWith(isBusy: true));

    // El visor se abre desde cualquier pantalla, así que quien decide es el
    // propio contenido: si todavía está pendiente de revisar se descarta.
    final isPending = !event.media.isImported;
    final removed = await _removedContent(
      discarded: isPending ? [id] : const [],
      marked: isPending ? const [] : [id],
      deleteFiles: event.deleteFiles,
    );
    if (removed.isEmpty) {
      emit(_idle);
      return;
    }

    _emitWithoutViewerMedia(id, emit);
  }

  /// Si el contenido [id] está marcado para borrar, según la lista que se está
  /// viendo. Es lo que distingue el visor abierto desde la papelera del que se
  /// abre desde cualquier otra pantalla.
  bool _isMarkedForDeletion(int id) {
    return state.mediaList
            ?.any((summary) => summary.id == id && summary.isDeleted) ??
        false;
  }

  /// Borrado definitivo desde el visor, el del contenido que ya estaba marcado.
  ///
  /// Sale de la base de datos con todo lo demás igual que si se hubiera vaciado
  /// la papelera entera, sólo que de uno en uno.
  void onPurgeMedia(PurgeMediaEvent event, Emitter<MediaStates> emit) async {
    final id = event.media.id;
    if (!_isMarkedForDeletion(id)) return;

    emit(state.copyWith(isBusy: true));

    final result = await _deleteMediaListUseCase(
      params: (ids: [id], deleteFiles: event.deleteFiles),
    );
    if (result is! DataSuccess) {
      emit(_idle);
      return;
    }

    _emitWithoutViewerMedia(id, emit);
  }

  /// Restablecer desde el visor: el contenido pierde la marca y vuelve a la
  /// pantalla que le toque, así que sale de la de eliminados igual que si se
  /// hubiera borrado desde ella.
  void onRestoreMedia(RestoreMediaEvent event, Emitter<MediaStates> emit) async {
    final id = event.media.id;
    if (!_isMarkedForDeletion(id)) return;

    emit(state.copyWith(isBusy: true));

    final result = await _restoreMediaUseCase(params: [id]);
    if (result is! DataSuccess) {
      emit(_idle);
      return;
    }

    _emitWithoutViewerMedia(id, emit);
  }

  /// Deja el estado sin el contenido [id].
  ///
  /// Es la salida común de todo lo que quita del visor lo que se está viendo
  /// (borrarlo, borrarlo del todo o restablecerlo): la lista se recorta y, al
  /// quedarse el estado sin contenido actual, el visor se cierra solo.
  void _emitWithoutViewerMedia(int id, Emitter<MediaStates> emit) {
    final newList = List<MediaSummaryEntity>.from(state.mediaList ?? [])
      ..removeWhere((element) => element.id == id);

    emit(MediaLoading(
      mediaList: newList,
      selectedIds: Set<int>.from(state.selectedIds)..remove(id),
      searchQuery: state.searchQuery,
      searchSections: _sectionsWithout((summary) => summary.id == id),
      searchFilters: state.searchFilters,
      sourceFilters: state.sourceFilters,
      favoritesOnly: state.favoritesOnly,
      importSource: state.importSource,
      lastImportAt: state.lastImportAt,
    ));
  }

  /// Quita contenido de la aplicación de las dos maneras que hay, y devuelve los
  /// identificadores que se han llegado a quitar.
  ///
  /// [discarded] se borra de la base de datos y [marked] se marca para borrar. Es
  /// el único sitio donde se decide una cosa u otra: lo pendiente de revisar se
  /// descarta (descartarlo al importar es no quererlo, no guardarlo en la
  /// papelera) y lo definitivo pasa por la pantalla de eliminados.
  ///
  /// [deleteFiles] sólo afecta a lo que se descarta, que es lo único que sale
  /// aquí de la base de datos; lo marcado sigue en ella con su fichero.
  Future<Set<int>> _removedContent({
    required List<int> discarded,
    required List<int> marked,
    bool deleteFiles = false,
  }) async {
    final removed = <int>{};

    if (discarded.isNotEmpty) {
      final result = await _deleteMediaListUseCase(
        params: (ids: discarded, deleteFiles: deleteFiles),
      );
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
        sourceFilters: state.sourceFilters,
        searchSuggestion: state.searchSuggestion,
        favoritesOnly: state.favoritesOnly,
        importSource: state.importSource,
      lastImportAt: state.lastImportAt,
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

    emit(state.copyWith(isBusy: true));

    final removed = await _removedContent(
      discarded: [for (final summary in selected) if (!summary.isImported) summary.id],
      marked: [for (final summary in selected) if (summary.isImported) summary.id],
      deleteFiles: event.deleteFiles,
    );
    if (removed.isEmpty) {
      emit(_idle);
      return;
    }

    emit(_withoutSelection((summary) => removed.contains(summary.id)));
  }

  /// Marcado masivo como favorito de la selección de la rejilla.
  ///
  /// No quita la marca a nada: es una acción y no un interruptor, porque el
  /// sumario que llena la rejilla no dice si un contenido es favorito y no hay
  /// forma de saber qué habría que alternar. La selección se deshace al
  /// terminar, como en el resto de acciones masivas.
  void onFavoriteSelectedMedia(
    FavoriteSelectedMediaEvent event,
    Emitter<MediaStates> emit,
  ) async {
    final selectedIds = state.selectedIds;
    if (selectedIds.isEmpty) return;

    emit(state.copyWith(isBusy: true));

    final result = await _setMediaListFavoriteUseCase(
      params: (ids: selectedIds.toList(), isFavorite: true),
    );
    if (result is! DataSuccess) {
      emit(_idle);
      return;
    }

    emit(state.copyWith(selectedIds: const {}, isBusy: false));
  }

  /// Restablecimiento de la selección en la pantalla de eliminados: el contenido
  /// pierde la marca y vuelve a la pantalla que le toque, así que sale de esta.
  void onRestoreSelectedMedia(RestoreSelectedMediaEvent event, Emitter<MediaStates> emit) async {
    final selectedIds = state.selectedIds;
    if (selectedIds.isEmpty) return;

    emit(state.copyWith(isBusy: true));

    final result = await _restoreMediaUseCase(params: selectedIds.toList());
    if (result is! DataSuccess) {
      emit(_idle);
      return;
    }

    emit(_withoutSelection((summary) => selectedIds.contains(summary.id)));
  }

  /// Borrado definitivo de todo lo marcado, forzado desde la pantalla de
  /// eliminados: la pantalla se queda vacía porque ya no queda nada marcado.
  ///
  /// Si el aviso no ha dicho lo contrario, los ficheros siguen en el disco y un
  /// escaneo posterior los recoge otra vez como contenido nuevo.
  void onPurgeDeletedMedia(PurgeDeletedMediaEvent event, Emitter<MediaStates> emit) async {
    emit(state.copyWith(isBusy: true));

    final result = await _purgeDeletedMediaUseCase(params: event.deleteFiles);
    if (result is! DataSuccess) {
      emit(_idle);
      return;
    }

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

    emit(state.copyWith(isBusy: true));

    final result = await _confirmMediaListUseCase(params: selectedIds.toList());
    if (result is! DataSuccess) {
      emit(_idle);
      return;
    }

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
      sourceFilters: state.sourceFilters,
      searchSuggestion: state.searchSuggestion,
      favoritesOnly: state.favoritesOnly,
      importSource: state.importSource,
      lastImportAt: state.lastImportAt,
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
    // Los detalles se leen de la base de datos, así que la rejilla espera con su
    // indicador hasta que el visor tiene qué enseñar.
    emit(MediaLoading(
      mediaList: state.mediaList,
      selectedIds: state.selectedIds,
      searchQuery: state.searchQuery,
      searchSections: state.searchSections,
      searchFilters: state.searchFilters,
      sourceFilters: state.sourceFilters,
      searchSuggestion: state.searchSuggestion,
      favoritesOnly: state.favoritesOnly,
      importSource: state.importSource,
      lastImportAt: state.lastImportAt,
      isBusy: true,
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
      sourceFilters: state.sourceFilters,
      searchSuggestion: state.searchSuggestion,
      favoritesOnly: state.favoritesOnly,
      importSource: state.importSource,
      lastImportAt: state.lastImportAt,
    );
  }

  /// Parar no emite nada: el recorrido se entera por la señal y termina como
  /// termina cualquier importación, dejando lo que ya se había traído.
  void onStopImport(StopImportEvent event, Emitter<MediaStates> emit) {
    _cancellation.cancel();
  }

  void onScanSource(ScanSourceEvent event, Emitter<MediaStates> emit) async {
    await _scan(
      emit,
      () => _scanSourceUseCase(
        params: (source: state.importSource, limit: event.limit),
      ),
    );
  }

  void onSelectAndScanDirectoryEvent(SelectAndScanDirectoryEvent event, Emitter<MediaStates> emit) async {
    await _scan(emit, () => _selectAndScanDirectoryUsecase(params: event.limit));
  }

  /// Escaneo de una carpeta: el contenido que va apareciendo se añade a lo que ya
  /// hay en la rejilla, uno a uno, conforme el escaneo lo encuentra.
  ///
  /// Es de lo que más tarda de la aplicación (recorre el disco y escribe en la
  /// base de datos), así que la rejilla espera con su indicador de principio a
  /// fin, aunque ya se estén viendo los primeros resultados: mientras el
  /// indicador esté puesto quedan cosas por llegar.
  Future<void> _scan(
    Emitter<MediaStates> emit,
    Future<Stream<DataState<MediaSummaryEntity>>> Function() scan,
  ) async {
    // La importación empieza sin nadie que la haya parado: lo que se pidiera
    // parar la vez anterior ya se paró.
    _cancellation.reset();

    // Y sin respuestas heredadas: lo que se dijo que valía "para todo" valía
    // para la importación anterior, no para ésta.
    _decisions.reset();

    List<MediaSummaryEntity> currentMedia = state.mediaList != null ? List.from(state.mediaList!) : [];
    final selectedIds = state.selectedIds;
    emit(MediaLoading(
      mediaList: currentMedia,
      selectedIds: selectedIds,
      importSource: state.importSource,
      lastImportAt: state.lastImportAt,
      isBusy: true,
    ));

    final stream = await scan();

    // Una sesión rechazada no es un contenido que no llega: es que a esa
    // plataforma no se le puede pedir nada hasta que el usuario vuelva a entrar,
    // y hay que decírselo al acabar.
    ImportSource? expiredSession;

    // Lo que haya fallado por el camino. Se queda el primero: es el que explica
    // por qué lo demás no ha llegado.
    String? importError;

    // Y la fuente que no tenía nada, que no es lo mismo que un fallo.
    EmptySourceException? empty;

    await emit.forEach<DataState<MediaSummaryEntity>>(
      stream,
      onData: (dataState) {
        if (dataState is DataSuccess && dataState.data != null) {
          currentMedia = List.from(currentMedia)..add(dataState.data!);
          return MediaLoading(
            mediaList: currentMedia,
            selectedIds: selectedIds,
            importSource: state.importSource,
            lastImportAt: state.lastImportAt,
            isBusy: true,
          );
        }

        switch (dataState.exception) {
          case final RemoteSessionExpiredException error:
            expiredSession = error.source;
          case final EmptySourceException error:
            empty = error;
          case final Exception error:
            importError ??= error.toString();
          case null:
            break;
        }

        return state;
      },
    );

    // El escaneo ha terminado: se queda lo encontrado, se retira el indicador y
    // se recoge la fecha que acaba de sellar el caso de uso.
    if (emit.isDone) return;
    emit(MediaLoading(
      mediaList: state.mediaList,
      selectedIds: state.selectedIds,
      searchQuery: state.searchQuery,
      searchSections: state.searchSections,
      searchFilters: state.searchFilters,
      sourceFilters: state.sourceFilters,
      searchSuggestion: state.searchSuggestion,
      favoritesOnly: state.favoritesOnly,
      importSource: state.importSource,
      lastImportAt: await _getLastImportUseCase(params: state.importSource),
      expiredSession: expiredSession,
      importError: importError,
      emptySource: empty?.source,
      emptyHint: empty?.hint,
    ));
  }

  void onViewerNextEvent(ViewerNextEvent event, Emitter<MediaStates> emit) async {
    final int length = state.mediaList!.length;
    if (length == 0) return;

    final int offset = event.next ? 1 : -1;
    final nextIdx = (state.currentMediaIndex! + offset + length) % length;
    final nextMedia = state.mediaList![nextIdx];

    // El visor sigue enseñando el contenido anterior mientras se leen los
    // detalles del siguiente, con el indicador de espera encima.
    emit(state.copyWith(isBusy: true));

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
