import 'package:Fern/features/media/domain/usecases/confirm_media_list_usecase.dart';
import 'package:Fern/features/media/domain/usecases/delete_media_list_usecase.dart';
import 'package:Fern/features/media/domain/usecases/delete_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_scanned_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_details_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_list_usercase.dart';
import 'package:Fern/features/media/domain/usecases/scan_directory_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_media_by_suggestion_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/select_scan_directory_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/entities/media/media_entity.dart';
import '../../domain/entities/media/media_summary_entity.dart';
import '../../domain/entities/search/media_search_section_entity.dart';
import '../../domain/entities/search/search_suggestion_entity.dart';
import 'media_events.dart';
import 'media_states.dart';

class MediaBloc extends Bloc<MediaEvents, MediaStates> {
  final SelectAndScanDirectoryUsecase _selectAndScanDirectoryUsecase;
  final ScanDirectoryUseCase _scanDirectoryUseCase;
  final GetMediaDetailsUsecase _getMediaDetailsUsecase;
  final SaveMediaUseCase _saveMediaUseCase;
  final DeleteMediaUseCase _deleteMediaUseCase;
  final DeleteMediaListUseCase _deleteMediaListUseCase;
  final ConfirmMediaListUseCase _confirmMediaListUseCase;
  final GetScannedMediaUseCase _getScannedMediaUseCase;
  final GetMediaListUsercase _getMediaListUsecase;
  final SearchMediaUseCase _searchMediaUseCase;
  final SearchMediaBySuggestionUseCase _searchMediaBySuggestionUseCase;

  MediaBloc({
    required SelectAndScanDirectoryUsecase selectAndScanDirectoryUsecase,
    required ScanDirectoryUseCase scanDirectoryUseCase,
    required GetMediaDetailsUsecase getMediaDetailsUsecase,
    required SaveMediaUseCase saveMediaUseCase,
    required DeleteMediaUseCase deleteMediaUseCase,
    required DeleteMediaListUseCase deleteMediaListUseCase,
    required ConfirmMediaListUseCase confirmMediaListUseCase,
    required GetScannedMediaUseCase getScannedMediaUseCase,
    required GetMediaListUsercase getMediaListUsecase,
    required SearchMediaUseCase searchMediaUseCase,
    required SearchMediaBySuggestionUseCase searchMediaBySuggestionUseCase,
  })  : _selectAndScanDirectoryUsecase = selectAndScanDirectoryUsecase,
        _scanDirectoryUseCase = scanDirectoryUseCase,
        _getMediaDetailsUsecase = getMediaDetailsUsecase,
        _saveMediaUseCase = saveMediaUseCase,
        _deleteMediaUseCase = deleteMediaUseCase,
        _deleteMediaListUseCase = deleteMediaListUseCase,
        _confirmMediaListUseCase = confirmMediaListUseCase,
        _getScannedMediaUseCase = getScannedMediaUseCase,
        _getMediaListUsecase = getMediaListUsecase,
        _searchMediaUseCase = searchMediaUseCase,
        _searchMediaBySuggestionUseCase = searchMediaBySuggestionUseCase,
        super(const MediaLoading()) {
    on<LoadScannedMediaEvent>(onLoadScannedMedia);
    on<LoadMediaLibraryEvent>(onLoadMediaLibrary);
    on<SearchMediaEvent>(onSearchMedia);
    on<SearchSuggestionSelectedEvent>(onSearchSuggestionSelected);
    on<ClearMediaSearchEvent>(onClearMediaSearch);
    on<ScanDirectoryEvent>(onScanDirectoryEvent);
    on<SelectAndScanDirectoryEvent>(onSelectAndScanDirectoryEvent);
    on<MediaClickedEvent>(onMediaClicked);
    on<ToggleMediaSelectionEvent>(onToggleMediaSelection);
    on<ClearMediaSelectionEvent>(onClearMediaSelection);
    on<ViewerNextEvent>(onViewerNextEvent);
    on<ToggleInfoEvent>(onToggleInfoEvent);
    on<SetInfoVisibilityEvent>(onSetInfoVisibility);
    on<SaveMediaEvent>(onSaveMedia);
    on<DeleteMediaEvent>(onDeleteMedia);
    on<DeleteSelectedMediaEvent>(onDeleteSelectedMedia);
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
  /// lista plana, así que se guardan las dos cosas: los grupos y su contenido
  /// aplanado en el mismo orden en el que se ve.
  MediaStates _searchState(
    List<MediaSearchSectionEntity> sections, {
    required String query,
    SearchSuggestionEntity? suggestion,
  }) {
    return MediaLoading(
      mediaList: sections.expand((section) => section.media).toList(),
      searchQuery: query,
      searchSections: sections,
      searchSuggestion: suggestion,
    );
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

  void onDeleteMedia(DeleteMediaEvent event, Emitter<MediaStates> emit) async {
    final result = await _deleteMediaUseCase(params: event.media.id);
    if (result is DataSuccess) {
      final newList = List<MediaSummaryEntity>.from(state.mediaList ?? [])
        ..removeWhere((element) => element.id == event.media.id);

      emit(MediaLoading(
        mediaList: newList,
        selectedIds: Set<int>.from(state.selectedIds)..remove(event.media.id),
        searchQuery: state.searchQuery,
        searchSections: _sectionsWithout((summary) => summary.id == event.media.id),
      ));
    }
  }

  /// Borrado masivo de la selección de la rejilla.
  void onDeleteSelectedMedia(DeleteSelectedMediaEvent event, Emitter<MediaStates> emit) async {
    final selectedIds = state.selectedIds;
    if (selectedIds.isEmpty) return;

    final result = await _deleteMediaListUseCase(params: selectedIds.toList());
    if (result is! DataSuccess) return;

    emit(_withoutSelection((summary) => selectedIds.contains(summary.id)));
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
      searchSuggestion: state.searchSuggestion,
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

    emit(state.copyWith(selectedIds: selectedIds));
  }

  void onClearMediaSelection(ClearMediaSelectionEvent event, Emitter<MediaStates> emit) {
    emit(state.copyWith(selectedIds: const {}));
  }

  void onMediaClicked(MediaClickedEvent event, Emitter<MediaStates> emit) async {
    emit(MediaLoading(
      mediaList: state.mediaList,
      selectedIds: state.selectedIds,
      searchQuery: state.searchQuery,
      searchSections: state.searchSections,
      searchSuggestion: state.searchSuggestion,
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
      searchSuggestion: state.searchSuggestion,
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
