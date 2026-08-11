import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/usecases/migrate_avatars_usecase.dart';
import 'package:Fern/features/media/domain/usecases/organize_library_files_usecase.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/usecases/get_settings_usecase.dart';
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

  SettingsBloc({
    required GetSettingsUseCase getSettings,
    required SaveSettingsUseCase saveSettings,
    required MigrateAvatarsUseCase migrateAvatars,
    required OrganizeLibraryFilesUseCase organizeLibraryFiles,
  })  : _getSettings = getSettings,
        _saveSettings = saveSettings,
        _migrateAvatars = migrateAvatars,
        _organizeLibraryFiles = organizeLibraryFiles,
        super(SettingsState(settings: getSettings())) {
    on<LoadSettingsEvent>(onLoadSettings);
    on<LanguageChangedEvent>(onLanguageChanged);
    on<SyncLocalFilesToggledEvent>(onSyncLocalFilesToggled);
    on<CopyFilesToggledEvent>(onCopyFilesToggled);
    on<LibraryDirectoryChangedEvent>(onLibraryDirectoryChanged);
    on<AvatarsDirectoryChangedEvent>(onAvatarsDirectoryChanged);
    on<FileOrganizationChangedEvent>(onFileOrganizationChanged);
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

  Future<void> onFileOrganizationChanged(
    FileOrganizationChangedEvent event,
    Emitter<SettingsState> emit,
  ) {
    return _apply(state.settings.copyWith(organization: event.criteria), emit);
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
