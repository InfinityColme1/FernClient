import 'package:Fern/features/media/domain/usecases/delete_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_details_usecase.dart';
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
  final GetMediaDetailsUsecase _getMediaDetailsUsecase;
  final SaveMediaUseCase _saveMediaUseCase;
  final DeleteMediaUseCase _deleteMediaUseCase;

  MediaBloc({
    required SelectAndScanDirectoryUsecase selectAndScanDirectoryUsecase,
    required GetMediaDetailsUsecase getMediaDetailsUsecase,
    required SaveMediaUseCase saveMediaUseCase,
    required DeleteMediaUseCase deleteMediaUseCase,
  })  : _selectAndScanDirectoryUsecase = selectAndScanDirectoryUsecase,
        _getMediaDetailsUsecase = getMediaDetailsUsecase,
        _saveMediaUseCase = saveMediaUseCase,
        _deleteMediaUseCase = deleteMediaUseCase,
        super(const MediaLoading()) {
    on<ScanDirectoryEvent>(onScanDirectoryEvent);
    on<MediaClickedEvent>(onMediaClicked);
    on<ViewerNextEvent>(onViewerNextEvent);
    on<ToggleInfoEvent>(onToggleInfoEvent);
    on<SaveMediaEvent>(onSaveMedia);
    on<DeleteMediaEvent>(onDeleteMedia);
    on<UpdateMediaInfoEvent>(onUpdateMediaInfo);
  }

  void onUpdateMediaInfo(UpdateMediaInfoEvent event, Emitter<MediaStates> emit) {
    emit(state.copyWith(
      currentMedia: event.media,
      isModified: true,
    ));
  }

  void onSaveMedia(SaveMediaEvent event, Emitter<MediaStates> emit) async {
    final result = await _saveMediaUseCase(params: event.media);
    if (result is DataSuccess) {
      emit(state.copyWith(isModified: false, isNew: false));
    }
  }

  void onDeleteMedia(DeleteMediaEvent event, Emitter<MediaStates> emit) async {
    final result = await _deleteMediaUseCase(params: event.media.id);
    if (result is DataSuccess) {
      final newList = List<MediaSummaryEntity>.from(state.mediaList ?? [])
        ..removeWhere((element) => element.id == event.media.id);
      
      emit(MediaLoading(mediaList: newList));
    }
  }

  void onMediaClicked(MediaClickedEvent event, Emitter<MediaStates> emit) async {
    emit(MediaLoading(mediaList: state.mediaList));

    final index = state.mediaList!.indexWhere((element) => element.id == event.media.id);

    final databaseResult = await _getMediaDetailsUsecase(params: event.media.id);
    if (databaseResult is DataSuccess && databaseResult.data != null) {
      emit(DetailedMedia(
        currentMediaIndex: index,
        currentMedia: databaseResult.data!,
        mediaList: state.mediaList,
        isNew: false,
        showInfo: state.showInfo,
      ));
    } else {
      final newMedia = MediaEntity(
        id: event.media.id,
        path: event.media.path,
        downloaded: DateTime.now(),
        creator: unknownCreator,
      );

      emit(DetailedMedia(
        currentMediaIndex: index,
        currentMedia: newMedia,
        mediaList: state.mediaList,
        isNew: true,
        showInfo: state.showInfo,
      ));
    }
  }

  void onScanDirectoryEvent(ScanDirectoryEvent event, Emitter<MediaStates> emit) async {
    List<MediaSummaryEntity> currentMedia = [];
    emit(MediaLoading(mediaList: currentMedia));

    final stream = await _selectAndScanDirectoryUsecase();

    await emit.forEach<DataState<MediaSummaryEntity>>(
      stream,
      onData: (dataState) {
        if (dataState is DataSuccess && dataState.data != null) {
          currentMedia = List.from(currentMedia)..add(dataState.data!);
          return MediaLoading(mediaList: currentMedia);
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

    final databaseResult = await _getMediaDetailsUsecase(params: nextMedia.id);
    if (databaseResult is DataSuccess && databaseResult.data != null) {
      emit(DetailedMedia(
        currentMediaIndex: nextIdx,
        currentMedia: databaseResult.data!,
        mediaList: state.mediaList,
        isNew: false,
        showInfo: state.showInfo,
      ));
    } else {
      final newMedia = MediaEntity(
        id: nextMedia.id,
        path: nextMedia.path,
        downloaded: DateTime.now(),
        creator: unknownCreator,
      );

      emit(DetailedMedia(
        currentMediaIndex: nextIdx,
        currentMedia: newMedia,
        mediaList: state.mediaList,
        isNew: true,
        showInfo: state.showInfo,
      ));
    }
  }

  void onToggleInfoEvent(ToggleInfoEvent event, Emitter<MediaStates> emit) {
    emit(state.copyWith(showInfo: !state.showInfo));
  }
}
