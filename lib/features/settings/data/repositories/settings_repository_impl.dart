import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/danbooru_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/gelbooru_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/pixiv_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/reddit_settings_entity.dart';
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
      autoTagRemoteSource:
          _preferences.getBool(autoTagRemoteSourcePreferenceKey) ?? false,
      showListAvatars:
          _preferences.getBool(showListAvatarsPreferenceKey) ?? true,
      reddit: RedditSettingsEntity(
        clientId: _preferences.getString(redditClientIdPreferenceKey) ?? '',
        clientSecret:
            _preferences.getString(redditClientSecretPreferenceKey) ?? '',
        username: _preferences.getString(redditUsernamePreferenceKey) ?? '',
        password: _preferences.getString(redditPasswordPreferenceKey) ?? '',
      ),
      browserHome: _preferences.getString(browserHomePreferenceKey) ??
          browserHomeUrl,
      gelbooru: GelbooruSettingsEntity(
        userId: _preferences.getString(gelbooruUserIdPreferenceKey) ?? '',
        apiKey: _preferences.getString(gelbooruApiKeyPreferenceKey) ?? '',
      ),
      danbooru: DanbooruSettingsEntity(
        username: _preferences.getString(danbooruUsernamePreferenceKey) ?? '',
        apiKey: _preferences.getString(danbooruApiKeyPreferenceKey) ?? '',
      ),
      pixiv: PixivSettingsEntity(
        sessionId: _preferences.getString(pixivSessionIdPreferenceKey) ?? '',
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

    await _preferences.setBool(
      autoTagRemoteSourcePreferenceKey,
      settings.autoTagRemoteSource,
    );

    await _preferences.setBool(
      showListAvatarsPreferenceKey,
      settings.showListAvatars,
    );

    final reddit = settings.reddit;
    await _preferences.setString(redditClientIdPreferenceKey, reddit.clientId);
    await _preferences.setString(
      redditClientSecretPreferenceKey,
      reddit.clientSecret,
    );
    await _preferences.setString(redditUsernamePreferenceKey, reddit.username);
    await _preferences.setString(redditPasswordPreferenceKey, reddit.password);

    await _preferences.setString(
      pixivSessionIdPreferenceKey,
      settings.pixiv.sessionId,
    );

    final danbooru = settings.danbooru;
    await _preferences.setString(
      danbooruUsernamePreferenceKey,
      danbooru.username,
    );
    await _preferences.setString(danbooruApiKeyPreferenceKey, danbooru.apiKey);

    final gelbooru = settings.gelbooru;
    await _preferences.setString(gelbooruUserIdPreferenceKey, gelbooru.userId);
    await _preferences.setString(gelbooruApiKeyPreferenceKey, gelbooru.apiKey);

    await _preferences.setString(
      browserHomePreferenceKey,
      settings.browserHome,
    );

    final libraryPath = settings.libraryPath;
    if (libraryPath == null) {
      await _preferences.remove(libraryPathPreferenceKey);
    } else {
      await _preferences.setString(libraryPathPreferenceKey, libraryPath);
    }
  }
}
