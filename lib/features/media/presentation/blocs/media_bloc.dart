import 'package:Fern/features/media/domain/usecases/delete_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_scanned_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_details_usecase.dart';
import 'package:Fern/features/media/domain/usecases/scan_directory_usecase.dart';
import 'package:Fern/features/media/domain/usecases/select_scan_directory_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/entities/media/media_entity.dart';
import '../../domain/entities/media/media_summary_entity.dart';
import 'media_events.dart';
import 'media_states.dart';

class MediaBloc extends Bloc<MediaEvents, MediaStates> {
  final SelectAndScanDirectoryUsecase _selectAndScanDirectoryUsecase;
  final ScanDirectoryUseCase _scanDirectoryUseCase;
  final GetMediaDetailsUsecase _getMediaDetailsUsecase;
  final SaveMediaUseCase _saveMediaUseCase;
  final DeleteMediaUseCase _deleteMediaUseCase;
  final GetScannedMediaUseCase _getScannedMediaUseCase;

  MediaBloc({
    required SelectAndScanDirectoryUsecase selectAndScanDirectoryUsecase,
    required ScanDirectoryUseCase scanDirectoryUseCase,
    required GetMediaDetailsUsecase getMediaDetailsUsecase,
    required SaveMediaUseCase saveMediaUseCase,
    required DeleteMediaUseCase deleteMediaUseCase,
    required GetScannedMediaUseCase getScannedMediaUseCase,
  })  : _selectAndScanDirectoryUsecase = selectAndScanDirectoryUsecase,
        _scanDirectoryUseCase = scanDirectoryUseCase,
        _getMediaDetailsUsecase = getMediaDetailsUsecase,
        _saveMediaUseCase = saveMediaUseCase,
        _deleteMediaUseCase = deleteMediaUseCase,
        _getScannedMediaUseCase = getScannedMediaUseCase,
        super(const MediaLoading()) {
    on<LoadScannedMediaEvent>(onLoadScannedMedia);
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

    // El contenido pasa a ser definitivo: se refleja también en el sumario de
    // la rejilla para que el visor y la lista no se contradigan.
    final mediaList = state.mediaList
        ?.map((summary) => summary.id == event.media.id
            ? MediaSummaryEntity(
                id: summary.id,
                path: summary.path,
                isImported: true,
              )
            : summary)
        .toList();

    emit(state.copyWith(
      currentMedia: event.media.copyWith(isImported: true),
      mediaList: mediaList,
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
      ));
    }
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
    emit(MediaLoading(mediaList: state.mediaList, selectedIds: state.selectedIds));

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
