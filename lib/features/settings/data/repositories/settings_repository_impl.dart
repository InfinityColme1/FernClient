import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/danbooru_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/gelbooru_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:Fern/features/notifications/domain/entities/app_notification.dart';
import 'package:Fern/features/settings/domain/entities/pawchive_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/pinterest_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/pixiv_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/reddit_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/theme_settings_entity.dart';
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

  /// La carpeta de reconocimiento de fábrica, resuelta al arrancar por lo mismo
  /// que [defaultAvatarsPath]: cuelga del directorio de datos de la aplicación,
  /// que sólo se sabe de forma asíncrona.
  final String defaultRecognitionPath;

  SettingsRepositoryImpl({
    required SharedPreferences preferences,
    required this.defaultAvatarsPath,
    required this.defaultRecognitionPath,
  }) : _preferences = preferences;

  String _customColorKey(CustomThemeColor slot) =>
      '$customColorPreferenceKeyPrefix${slot.id}';

  /// El color que el usuario haya puesto en [slot], o `null` si no lo ha
  /// tocado: la ausencia de la preferencia es lo que dice que ese color se
  /// hereda del tema de fábrica.
  int? _customColor(CustomThemeColor slot) =>
      _preferences.getInt(_customColorKey(slot));

  /// Cómo avisa cada clase de aviso.
  ///
  /// Se guarda una clave por clase y por vía en lugar de un objeto serializado:
  /// así una clase nueva nace con sus valores de fábrica sin tener que migrar
  /// nada, que es justo lo que va a pasar según lleguen las fases.
  NotificationSettingsEntity _notifications() {
    return NotificationSettingsEntity(
      enabled: _preferences.getBool(notificationsEnabledPreferenceKey) ?? true,
      muted: _preferences.getBool(notificationsMutedPreferenceKey) ?? false,
      volume: _preferences.getInt(notificationsVolumePreferenceKey) ??
          defaultNotificationVolume,
      maxSeconds: _preferences.getInt(notificationsMaxSecondsPreferenceKey) ??
          defaultNotificationSeconds,
      channels: {
        for (final kind in NotificationKind.values)
          kind: NotificationChannelEntity(
            badge: _preferences
                    .getBool('$notificationBadgePreferenceKeyPrefix${kind.id}') ??
                true,
            sound: _preferences
                    .getBool('$notificationSoundPreferenceKeyPrefix${kind.id}') ??
                true,
            soundPath: _preferences
                .getString('$notificationSoundPathPreferenceKeyPrefix${kind.id}'),
          ),
      },
    );
  }

  Future<void> _saveNotifications(NotificationSettingsEntity settings) async {
    await _preferences.setBool(
      notificationsEnabledPreferenceKey,
      settings.enabled,
    );
    await _preferences.setBool(notificationsMutedPreferenceKey, settings.muted);
    await _preferences.setInt(
      notificationsVolumePreferenceKey,
      settings.volume,
    );
    await _preferences.setInt(
      notificationsMaxSecondsPreferenceKey,
      settings.maxSeconds,
    );

    for (final kind in NotificationKind.values) {
      final channel = settings.channel(kind);

      await _preferences.setBool(
        '$notificationBadgePreferenceKeyPrefix${kind.id}',
        channel.badge,
      );
      await _preferences.setBool(
        '$notificationSoundPreferenceKeyPrefix${kind.id}',
        channel.sound,
      );

      final key = '$notificationSoundPathPreferenceKeyPrefix${kind.id}';
      final path = channel.soundPath;

      // Sin fichero elegido se borra la clave en vez de guardar vacío: la
      // ausencia es lo que dice "suena el de fábrica".
      if (path == null || path.isEmpty) {
        await _preferences.remove(key);
      } else {
        await _preferences.setString(key, path);
      }
    }
  }

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
      recognitionPath: _preferences.getString(recognitionPathPreferenceKey) ??
          defaultRecognitionPath,
      organization: FileOrganizationCriteria.fromId(
        _preferences.getString(fileOrganizationPreferenceKey),
      ),
      autoTagRemoteSource:
          _preferences.getBool(autoTagRemoteSourcePreferenceKey) ?? false,
      showListAvatars:
          _preferences.getBool(showListAvatarsPreferenceKey) ?? true,
      pauseWhenSeeking:
          _preferences.getBool(pauseWhenSeekingPreferenceKey) ?? false,
      themeMode: AppThemeMode.fromId(
        _preferences.getString(themeModePreferenceKey),
      ),
      customTheme: CustomThemeEntity(
        primary: _customColor(CustomThemeColor.primary),
        secondary: _customColor(CustomThemeColor.secondary),
        terciary: _customColor(CustomThemeColor.terciary),
        error: _customColor(CustomThemeColor.error),
        background: _customColor(CustomThemeColor.background),
        surface: _customColor(CustomThemeColor.surface),
        foreground: _customColor(CustomThemeColor.foreground),
      ),
      viewerSaveBehavior: ViewerSaveBehavior.fromId(
        _preferences.getString(viewerSaveBehaviorPreferenceKey),
      ),
      reddit: RedditSettingsEntity(
        clientId: _preferences.getString(redditClientIdPreferenceKey) ?? '',
        clientSecret:
            _preferences.getString(redditClientSecretPreferenceKey) ?? '',
        username: _preferences.getString(redditUsernamePreferenceKey) ?? '',
        password: _preferences.getString(redditPasswordPreferenceKey) ?? '',
      ),
      browserHome: _preferences.getString(browserHomePreferenceKey) ??
          browserHomeUrl,
      pawchive: PawchiveSettingsEntity(
        sessionId:
            _preferences.getString(pawchiveSessionIdPreferenceKey) ?? '',
        byFavoriteCreators:
            _preferences.getBool(pawchiveByCreatorsPreferenceKey) ?? false,
      ),
      pinterest: PinterestSettingsEntity(
        username: _preferences.getString(pinterestUsernamePreferenceKey) ?? '',
        sessionId:
            _preferences.getString(pinterestSessionIdPreferenceKey) ?? '',
      ),
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
      notifications: _notifications(),
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
    await _preferences.setString(
      recognitionPathPreferenceKey,
      settings.recognitionPath,
    );

    await _preferences.setBool(
      autoTagRemoteSourcePreferenceKey,
      settings.autoTagRemoteSource,
    );

    await _preferences.setBool(
      showListAvatarsPreferenceKey,
      settings.showListAvatars,
    );

    await _preferences.setBool(
      pauseWhenSeekingPreferenceKey,
      settings.pauseWhenSeeking,
    );

    await _preferences.setString(
      themeModePreferenceKey,
      settings.themeMode.id,
    );

    await _preferences.setString(
      viewerSaveBehaviorPreferenceKey,
      settings.viewerSaveBehavior.id,
    );

    // Un color sin poner no se guarda: se borra su preferencia, que es como se
    // vuelve al del tema de fábrica.
    for (final slot in CustomThemeColor.values) {
      final color = settings.customTheme.colorOf(slot);
      if (color == null) {
        await _preferences.remove(_customColorKey(slot));
      } else {
        await _preferences.setInt(_customColorKey(slot), color);
      }
    }

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

    final pinterest = settings.pinterest;
    await _preferences.setString(
      pinterestUsernamePreferenceKey,
      pinterest.username,
    );
    await _preferences.setString(
      pinterestSessionIdPreferenceKey,
      pinterest.sessionId,
    );

    await _preferences.setString(
      pawchiveSessionIdPreferenceKey,
      settings.pawchive.sessionId,
    );
    await _preferences.setBool(
      pawchiveByCreatorsPreferenceKey,
      settings.pawchive.byFavoriteCreators,
    );

    await _preferences.setString(
      browserHomePreferenceKey,
      settings.browserHome,
    );

    await _saveNotifications(settings.notifications);

    final libraryPath = settings.libraryPath;
    if (libraryPath == null) {
      await _preferences.remove(libraryPathPreferenceKey);
    } else {
      await _preferences.setString(libraryPathPreferenceKey, libraryPath);
    }
  }
}
