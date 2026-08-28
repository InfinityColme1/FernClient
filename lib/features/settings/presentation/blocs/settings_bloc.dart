import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/usecases/migrate_avatars_usecase.dart';
import 'package:Fern/features/media/domain/usecases/organize_library_files_usecase.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:Fern/features/settings/domain/usecases/migrate_recognition_data_usecase.dart';
import 'package:Fern/features/settings/domain/usecases/save_settings_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'settings_events.dart';
import 'settings_states.dart';

/// Ajustes de la aplicación.
///
/// Cada cambio se guarda en cuanto se hace: la pantalla no tiene botón de
/// aceptar, igual que los ajustes de cualquier aplicación de escritorio.
class SettingsBloc extends Bloc<SettingsEvents, SettingsState> {
  final GetSettingsUseCase _getSettings;
  final SaveSettingsUseCase _saveSettings;
  final MigrateAvatarsUseCase _migrateAvatars;
  final OrganizeLibraryFilesUseCase _organizeLibraryFiles;
  final MigrateRecognitionDataUseCase _migrateRecognitionData;

  /// A quién avisar de que ha cambiado **qué** esconde el filtro NSFW.
  ///
  /// Casi ningún ajuste lo mueve: los de vista dicen cómo se pinta lo que ya se
  /// ha decidido, y se leen al vuelo. Éste sí, porque cambia el conjunto de
  /// etiquetas marcadas, y ese conjunto está en un índice que hay que rehacer
  /// antes de que se pinte nada.
  final Future<void> Function()? _onNsfwScopeChanged;

  SettingsBloc({
    required GetSettingsUseCase getSettings,
    required SaveSettingsUseCase saveSettings,
    required MigrateAvatarsUseCase migrateAvatars,
    required OrganizeLibraryFilesUseCase organizeLibraryFiles,
    required MigrateRecognitionDataUseCase migrateRecognitionData,
    Future<void> Function()? onNsfwScopeChanged,
  })  : _getSettings = getSettings,
        _saveSettings = saveSettings,
        _migrateAvatars = migrateAvatars,
        _organizeLibraryFiles = organizeLibraryFiles,
        _migrateRecognitionData = migrateRecognitionData,
        _onNsfwScopeChanged = onNsfwScopeChanged,
        super(SettingsState(settings: getSettings())) {
    on<LoadSettingsEvent>(onLoadSettings);
    on<LanguageChangedEvent>(onLanguageChanged);
    on<SyncLocalFilesToggledEvent>(onSyncLocalFilesToggled);
    on<CopyFilesToggledEvent>(onCopyFilesToggled);
    on<LibraryDirectoryChangedEvent>(onLibraryDirectoryChanged);
    on<AvatarsDirectoryChangedEvent>(onAvatarsDirectoryChanged);
    on<RecognitionDirectoryChangedEvent>(onRecognitionDirectoryChanged);
    on<NotificationSettingsChangedEvent>(onNotificationSettingsChanged);
    on<FileOrganizationChangedEvent>(onFileOrganizationChanged);
    on<AutoTagRemoteSourceToggledEvent>(onAutoTagRemoteSourceToggled);
    on<ShowListAvatarsToggledEvent>(onShowListAvatarsToggled);
    on<PauseWhenSeekingToggledEvent>(onPauseWhenSeekingToggled);
    on<ReturnToViewedMediaToggledEvent>(onReturnToViewedMediaToggled);
    on<RecognizeOnImportToggledEvent>(onRecognizeOnImportToggled);
    on<ReturnRecognizedToggledEvent>(onReturnRecognizedToggled);
    on<ThemeModeChangedEvent>(onThemeModeChanged);
    on<CustomThemeColorChangedEvent>(onCustomThemeColorChanged);
    on<ViewerSaveBehaviorChangedEvent>(onViewerSaveBehaviorChanged);
    on<AutomaticDuplicateScanToggledEvent>(onAutomaticDuplicateScanToggled);
    on<DuplicateScanPeriodChangedEvent>(onDuplicateScanPeriodChanged);
    on<DuplicateScanMovingToggledEvent>(onDuplicateScanMovingToggled);
    on<NsfwChildTagsToggledEvent>(onNsfwChildTagsToggled);
    on<NsfwUnlockedViewChangedEvent>(onNsfwUnlockedViewChanged);
    on<NsfwLockedViewChangedEvent>(onNsfwLockedViewChanged);
    on<DuplicateThresholdChangedEvent>(onDuplicateThresholdChanged);
    on<RedditSettingsChangedEvent>(onRedditSettingsChanged);
    on<DanbooruSettingsChangedEvent>(onDanbooruSettingsChanged);
    on<GelbooruSettingsChangedEvent>(onGelbooruSettingsChanged);
    on<PinterestSettingsChangedEvent>(onPinterestSettingsChanged);
    on<PawchiveSettingsChangedEvent>(onPawchiveSettingsChanged);
    on<BrowserHomeChangedEvent>(onBrowserHomeChanged);
    on<BrowserAsideChangedEvent>(onBrowserAsideChanged);
    on<RemoteSessionCapturedEvent>(onRemoteSessionCaptured);
    on<MigrateLibraryRequestedEvent>(onMigrateLibraryRequested);
  }

  void onLoadSettings(LoadSettingsEvent event, Emitter<SettingsState> emit) {
    emit(SettingsState(settings: _getSettings()));
  }

  /// Guarda [settings] y los deja en el estado. Todos los cambios de una
  /// casilla o un desplegable pasan por aquí.
  Future<void> _apply(AppSettingsEntity settings, Emitter<SettingsState> emit) async {
    await _saveSettings(params: settings);
    emit(state.copyWith(settings: settings));
  }

  Future<void> onLanguageChanged(
    LanguageChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(state.settings.copyWith(language: event.language), emit);
  }

  /// Al apagar la sincronización se apaga también el copiado: es una opción
  /// suya, y dejarla marcada de fondo confundiría al volver a encenderla.
  Future<void> onSyncLocalFilesToggled(
    SyncLocalFilesToggledEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(
        syncLocalFiles: event.enabled,
        copyFiles: event.enabled && state.settings.copyFiles,
      ),
      emit,
    );
  }

  Future<void> onCopyFilesToggled(
    CopyFilesToggledEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(state.settings.copyWith(copyFiles: event.enabled), emit);
  }

  /// La carpeta nueva no arrastra por sí sola lo que ya hay: para eso está el
  /// botón de migrar, que es una decisión del usuario y puede tardar.
  Future<void> onLibraryDirectoryChanged(
    LibraryDirectoryChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(state.settings.copyWith(libraryPath: event.path), emit);
  }

  /// Los avatares sí se mueven en el momento: la aplicación los carga siempre
  /// de esta carpeta, así que dejarlos atrás sería quedarse sin ellos.
  Future<void> onAvatarsDirectoryChanged(
    AvatarsDirectoryChangedEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final previous = state.settings.avatarsPath;
    if (previous == event.path) return;

    emit(state.copyWith(isWorking: true));

    final result = await _migrateAvatars(
      params: MigrateAvatarsParams(
        targetDirectory: event.path,
        previousDirectory: previous,
      ),
    );

    final settings = state.settings.copyWith(avatarsPath: event.path);
    await _saveSettings(params: settings);

    emit(SettingsState(
      settings: settings,
      lastResult: result is DataSuccess
          ? SettingsResult(SettingsStatus.avatarsMigrated, count: result.data ?? 0)
          : const SettingsResult(SettingsStatus.avatarsFailed),
    ));
  }

  /// Como los avatares: se mueve en el momento, porque los modelos se cargan de
  /// esta carpeta. Puede tardar bastante (son varios gigas), de ahí el
  /// [SettingsState.isWorking] mientras dura.
  Future<void> onRecognitionDirectoryChanged(
    RecognitionDirectoryChangedEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final previous = state.settings.recognitionPath;
    if (previous == event.path) return;

    emit(state.copyWith(isWorking: true));

    final result = await _migrateRecognitionData(
      params: MigrateRecognitionDataParams(
        targetDirectory: event.path,
        previousDirectory: previous,
      ),
    );

    final settings = state.settings.copyWith(recognitionPath: event.path);
    await _saveSettings(params: settings);

    emit(SettingsState(
      settings: settings,
      lastResult: result is DataSuccess
          ? SettingsResult(
              SettingsStatus.recognitionMigrated,
              count: result.data ?? 0,
            )
          : const SettingsResult(SettingsStatus.recognitionFailed),
    ));
  }

  Future<void> onNotificationSettingsChanged(
    NotificationSettingsChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(notifications: event.notifications),
      emit,
    );
  }

  Future<void> onFileOrganizationChanged(
    FileOrganizationChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(state.settings.copyWith(organization: event.criteria), emit);
  }

  /// Vale para la próxima importación: lo que ya está guardado no se reetiqueta
  /// hacia atrás, igual que cambiar el criterio de carpetas no mueve nada hasta
  /// que se pide la migración.
  Future<void> onAutoTagRemoteSourceToggled(
    AutoTagRemoteSourceToggledEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(autoTagRemoteSource: event.enabled),
      emit,
    );
  }

  Future<void> onRecognizeOnImportToggled(
    RecognizeOnImportToggledEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(recognizeOnImport: event.enabled),
      emit,
    );
  }

  Future<void> onReturnRecognizedToggled(
    ReturnRecognizedToggledEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(returnRecognizedToImport: event.enabled),
      emit,
    );
  }

  Future<void> onPauseWhenSeekingToggled(
    PauseWhenSeekingToggledEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(pauseWhenSeeking: event.enabled),
      emit,
    );
  }

  Future<void> onReturnToViewedMediaToggled(
    ReturnToViewedMediaToggledEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(returnToViewedMedia: event.enabled),
      emit,
    );
  }

  /// Se ve en el momento: el menú lateral escucha estos ajustes, así que la
  /// lista de etiquetas cambia sin salir de los ajustes.
  Future<void> onShowListAvatarsToggled(
    ShowListAvatarsToggledEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(showListAvatars: event.enabled),
      emit,
    );
  }

  /// Se ve en el momento: el tema cuelga de la raíz de la aplicación, así que
  /// cambia hasta la pantalla de ajustes desde la que se ha elegido.
  Future<void> onThemeModeChanged(
    ThemeModeChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(state.settings.copyWith(themeMode: event.mode), emit);
  }

  /// Los colores a medida se guardan siempre, se esté o no en el tema a medida:
  /// mirar otro tema y volver no puede perder lo que el usuario había elegido.
  Future<void> onCustomThemeColorChanged(
    CustomThemeColorChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(
        customTheme: state.settings.customTheme.withColor(
          event.slot,
          event.color,
        ),
      ),
      emit,
    );
  }

  Future<void> onViewerSaveBehaviorChanged(
    ViewerSaveBehaviorChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(viewerSaveBehavior: event.behavior),
      emit,
    );
  }

  Future<void> onAutomaticDuplicateScanToggled(
    AutomaticDuplicateScanToggledEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(automaticDuplicateScan: event.enabled),
      emit,
    );
  }

  /// Cambia qué esconde el filtro, así que hay que rehacer el índice **antes**
  /// de que la pantalla vuelva a pintar: si no, la rejilla seguiría enseñando lo
  /// que acaba de esconderse, o escondiendo lo que acaba de dejar de estarlo.
  ///
  /// No reescribe ninguna etiqueta: la rama se resuelve al leerla, así que esto
  /// se enciende y se apaga sin consecuencias.
  Future<void> onNsfwChildTagsToggled(
    NsfwChildTagsToggledEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _apply(
      state.settings.copyWith(nsfwMarksChildTags: event.marksChildren),
      emit,
    );

    await _onNsfwScopeChanged?.call();
  }

  Future<void> onNsfwUnlockedViewChanged(
    NsfwUnlockedViewChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(nsfwUnlockedView: event.view),
      emit,
    );
  }

  Future<void> onNsfwLockedViewChanged(
    NsfwLockedViewChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(nsfwLockedView: event.view),
      emit,
    );
  }

  /// Encenderlo no lanza ningún escaneo: lo que decide es qué se mira en el
  /// siguiente. Ponerse a abrir vídeos porque alguien acaba de tocar un
  /// interruptor de los ajustes es justo lo que no espera quien lo toca.
  Future<void> onDuplicateScanMovingToggled(
    DuplicateScanMovingToggledEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(duplicateScanIncludesMoving: event.enabled),
      emit,
    );
  }

  Future<void> onDuplicateScanPeriodChanged(
    DuplicateScanPeriodChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(duplicateScanPeriod: event.period),
      emit,
    );
  }

  /// Mover el listón no vuelve a agrupar nada por su cuenta: lo ya guardado se
  /// hizo con el criterio de entonces y rehacerlo aquí tiraría los descartes
  /// que el usuario ya había decidido. El listón nuevo entra en el escaneo
  /// siguiente, que es quien lee este ajuste.
  Future<void> onDuplicateThresholdChanged(
    DuplicateThresholdChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(
      state.settings.copyWith(
        duplicateThreshold: event.threshold.clamp(0, maxDuplicateThreshold),
      ),
      emit,
    );
  }

  /// Las credenciales se guardan según se escriben, como el resto de ajustes.
  /// Nadie las comprueba aquí: hasta que no se lanza una importación no hay
  /// forma de saber si son buenas.
  Future<void> onRedditSettingsChanged(
    RedditSettingsChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(state.settings.copyWith(reddit: event.reddit), emit);
  }

  Future<void> onDanbooruSettingsChanged(
    DanbooruSettingsChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(state.settings.copyWith(danbooru: event.danbooru), emit);
  }

  Future<void> onGelbooruSettingsChanged(
    GelbooruSettingsChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(state.settings.copyWith(gelbooru: event.gelbooru), emit);
  }

  Future<void> onPinterestSettingsChanged(
    PinterestSettingsChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(state.settings.copyWith(pinterest: event.pinterest), emit);
  }

  Future<void> onPawchiveSettingsChanged(
    PawchiveSettingsChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(state.settings.copyWith(pawchive: event.pawchive), emit);
  }

  Future<void> onBrowserHomeChanged(
    BrowserHomeChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(state.settings.copyWith(browserHome: event.url), emit);
  }

  Future<void> onBrowserAsideChanged(
    BrowserAsideChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(state.settings.copyWith(browserAside: event.policy), emit);
  }

  Future<void> onRemoteSessionCaptured(
    RemoteSessionCapturedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(event.settings, emit);
  }

  Future<void> onMigrateLibraryRequested(
    MigrateLibraryRequestedEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (!state.settings.managesFiles) return;

    emit(state.copyWith(isWorking: true));

    final result = await _organizeLibraryFiles();

    emit(SettingsState(
      settings: state.settings,
      lastResult: result is DataSuccess
          ? SettingsResult(SettingsStatus.filesOrganized, count: result.data ?? 0)
          : const SettingsResult(SettingsStatus.filesFailed),
    ));
  }
}
