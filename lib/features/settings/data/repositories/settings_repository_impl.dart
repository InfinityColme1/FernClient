import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ajustes guardados en las preferencias del sistema.
///
/// [defaultAvatarsPath] es la carpeta a la que van los avatares mientras el
/// usuario no elija otra; se resuelve al arrancar (necesita el directorio de
/// datos de la aplicación, que es asíncrono) y se inyecta ya resuelta para que
/// la lectura de ajustes pueda ser síncrona.
class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _preferences;
  final String defaultAvatarsPath;

  SettingsRepositoryImpl({
    required SharedPreferences preferences,
    required this.defaultAvatarsPath,
  }) : _preferences = preferences;

  @override
  AppSettingsEntity getSettings() {
    return AppSettingsEntity(
      language: AppLanguage.fromCode(
        _preferences.getString(languagePreferenceKey),
      ),
      syncLocalFiles: _preferences.getBool(syncLocalFilesPreferenceKey) ?? false,
      copyFiles: _preferences.getBool(copyFilesPreferenceKey) ?? false,
      libraryPath: _preferences.getString(libraryPathPreferenceKey),
      avatarsPath: _preferences.getString(avatarsPathPreferenceKey) ??
          defaultAvatarsPath,
      organization: FileOrganizationCriteria.fromId(
        _preferences.getString(fileOrganizationPreferenceKey),
      ),
    );
  }

  @override
  Future<void> saveSettings(AppSettingsEntity settings) async {
    await _preferences.setString(
      languagePreferenceKey,
      settings.language.code,
    );
    await _preferences.setBool(
      syncLocalFilesPreferenceKey,
      settings.syncLocalFiles,
    );
    await _preferences.setBool(copyFilesPreferenceKey, settings.copyFiles);
    await _preferences.setString(
      fileOrganizationPreferenceKey,
      settings.organization.id,
    );
    await _preferences.setString(
      avatarsPathPreferenceKey,
      settings.avatarsPath,
    );

    final libraryPath = settings.libraryPath;
    if (libraryPath == null) {
      await _preferences.remove(libraryPathPreferenceKey);
    } else {
      await _preferences.setString(libraryPathPreferenceKey, libraryPath);
    }
  }
}
