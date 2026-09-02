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
import 'package:Fern/core/services/secret_storage.dart';
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

  /// Dónde van las credenciales, cifradas.
  ///
  /// Va por parámetro y no se monta aquí para poder probar el repositorio sin
  /// tocar la API de Windows: sin él, lo de siempre —el fichero de
  /// preferencias, en claro—, que es lo que había antes de esto.
  final SecretStorage? _secrets;

  SettingsRepositoryImpl({
    required SharedPreferences preferences,
    required this.defaultAvatarsPath,
    required this.defaultRecognitionPath,
    SecretStorage? secrets,
  })  : _preferences = preferences,
        _secrets = secrets;

  /// Un secreto guardado, o cadena vacía si no hay ninguno.
  ///
  /// Las credenciales llegan a la interfaz como cadenas y vacío significa «no
  /// hay»: un `null` aquí sería otro caso que tratar en cada campo de cada
  /// fuente, y todos harían lo mismo.
  String _secret(String key) {
    final storage = _secrets;
    if (storage == null) return _preferences.getString(key) ?? '';

    return storage.read(key) ?? '';
  }

  Future<void> _saveSecret(String key, String value) async {
    final storage = _secrets;

    if (storage == null) {
      await _preferences.setString(key, value);
      return;
    }

    await storage.write(key, value);
  }

  /// Las claves que llevan un secreto dentro.
  ///
  /// Están juntas porque hay dos sitios que las necesitan todas: la migración de
  /// lo que se guardó en claro y esta lista misma, que es donde se mira al
  /// añadir una fuente nueva. Lo que no esté aquí se guarda en claro y nadie se
  /// entera.
  static const secretKeys = [
    redditClientSecretPreferenceKey,
    redditPasswordPreferenceKey,
    pixivSessionIdPreferenceKey,
    danbooruApiKeyPreferenceKey,
    gelbooruApiKeyPreferenceKey,
    pinterestSessionIdPreferenceKey,
    pawchiveSessionIdPreferenceKey,
  ];

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
      // Acotado al leerlo y no sólo al escribirlo: un valor imposible en las
      // preferencias —tocado a mano, o de una versión con otros límites— dejaría
      // la biblioteca reconociéndose durante horas.
      returnRecognizedToImport:
          _preferences.getBool(returnRecognizedPreferenceKey) ?? true,
      returnToViewedMedia:
          _preferences.getBool(returnToViewedMediaPreferenceKey) ?? true,
      recognizeOnImport:
          _preferences.getBool(recognizeOnImportPreferenceKey) ?? true,
      // Acotado al leer y no sólo al escribir: una preferencia guardada por una
      // versión anterior, o tocada a mano, no puede dejar el escaneo agrupando
      // por un número imposible.
      duplicateThreshold:
          (_preferences.getInt(duplicateThresholdPreferenceKey) ??
                  defaultDuplicateThreshold)
              .clamp(0, maxDuplicateThreshold),
      automaticDuplicateScan:
          _preferences.getBool(automaticDuplicateScanPreferenceKey) ?? true,
      duplicateScanIncludesMoving:
          _preferences.getBool(duplicateScanMovingPreferenceKey) ?? true,
      nsfwMarksChildTags:
          _preferences.getBool(nsfwChildTagsPreferenceKey) ?? true,
      nsfwTagsHideMedia:
          _preferences.getBool(nsfwTagsHideMediaPreferenceKey) ?? true,
      nsfwUnlockedView: NsfwUnlockedView.fromId(
        _preferences.getString(nsfwUnlockedViewPreferenceKey),
      ),
      nsfwLockedView: NsfwLockedView.fromId(
        _preferences.getString(nsfwLockedViewPreferenceKey),
      ),
      duplicateScanPeriod: DuplicateScanPeriod.fromId(
        _preferences.getString(duplicateScanPeriodPreferenceKey),
      ),
      frameSamples:
          (_preferences.getInt(frameSamplesPreferenceKey) ?? defaultFrameSamples)
              .clamp(minFrameSamples, maxFrameSamples),
      maxDetectionsPerClass:
          _preferences.getInt(maxDetectionsPreferenceKey) ??
              defaultMaxDetectionsPerClass,
      recognitionPath: _preferences.getString(recognitionPathPreferenceKey) ??
          defaultRecognitionPath,
      organization: FileOrganizationCriteria.fromId(
        _preferences.getString(fileOrganizationPreferenceKey),
      ),
      autoTagRemoteSource:
          _preferences.getBool(autoTagRemoteSourcePreferenceKey) ?? false,
      showListAvatars:
          _preferences.getBool(showListAvatarsPreferenceKey) ?? true,
      keepsSelectionOnDrop:
          _preferences.getBool(keepsSelectionOnDropPreferenceKey) ?? false,
      // Sin preferencia guardada, encendido: es el comportamiento que se quiere
      // sin tocar nada, y quien no lo quiera lo apaga.
      showsTagBranchOnFilter:
          _preferences.getBool(showsTagBranchOnFilterPreferenceKey) ?? true,
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
        clientSecret: _secret(redditClientSecretPreferenceKey),
        username: _preferences.getString(redditUsernamePreferenceKey) ?? '',
        password: _secret(redditPasswordPreferenceKey),
      ),
      browserHome: _preferences.getString(browserHomePreferenceKey) ??
          browserHomeUrl,
      browserAside: BrowserAsidePolicy.fromId(
        _preferences.getString(browserAsidePreferenceKey),
      ),
      pawchive: PawchiveSettingsEntity(
        sessionId: _secret(pawchiveSessionIdPreferenceKey),
        byFavoriteCreators:
            _preferences.getBool(pawchiveByCreatorsPreferenceKey) ?? false,
      ),
      pinterest: PinterestSettingsEntity(
        username: _preferences.getString(pinterestUsernamePreferenceKey) ?? '',
        sessionId: _secret(pinterestSessionIdPreferenceKey),
      ),
      gelbooru: GelbooruSettingsEntity(
        userId: _preferences.getString(gelbooruUserIdPreferenceKey) ?? '',
        apiKey: _secret(gelbooruApiKeyPreferenceKey),
      ),
      danbooru: DanbooruSettingsEntity(
        username: _preferences.getString(danbooruUsernamePreferenceKey) ?? '',
        apiKey: _secret(danbooruApiKeyPreferenceKey),
      ),
      pixiv: PixivSettingsEntity(
        sessionId: _secret(pixivSessionIdPreferenceKey),
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
      returnRecognizedPreferenceKey,
      settings.returnRecognizedToImport,
    );
    await _preferences.setBool(
      returnToViewedMediaPreferenceKey,
      settings.returnToViewedMedia,
    );
    await _preferences.setBool(
      recognizeOnImportPreferenceKey,
      settings.recognizeOnImport,
    );
    await _preferences.setInt(
      duplicateThresholdPreferenceKey,
      settings.duplicateThreshold.clamp(0, maxDuplicateThreshold),
    );
    await _preferences.setBool(
      automaticDuplicateScanPreferenceKey,
      settings.automaticDuplicateScan,
    );
    await _preferences.setString(
      duplicateScanPeriodPreferenceKey,
      settings.duplicateScanPeriod.id,
    );
    await _preferences.setBool(
      duplicateScanMovingPreferenceKey,
      settings.duplicateScanIncludesMoving,
    );
    await _preferences.setBool(
      nsfwChildTagsPreferenceKey,
      settings.nsfwMarksChildTags,
    );
    await _preferences.setBool(
      nsfwTagsHideMediaPreferenceKey,
      settings.nsfwTagsHideMedia,
    );
    await _preferences.setString(
      nsfwUnlockedViewPreferenceKey,
      settings.nsfwUnlockedView.id,
    );
    await _preferences.setString(
      nsfwLockedViewPreferenceKey,
      settings.nsfwLockedView.id,
    );
    await _preferences.setInt(
      frameSamplesPreferenceKey,
      settings.frameSamples.clamp(minFrameSamples, maxFrameSamples),
    );

    await _preferences.setInt(
      maxDetectionsPreferenceKey,
      settings.maxDetectionsPerClass,
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
      keepsSelectionOnDropPreferenceKey,
      settings.keepsSelectionOnDrop,
    );

    await _preferences.setBool(
      showsTagBranchOnFilterPreferenceKey,
      settings.showsTagBranchOnFilter,
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
    await _saveSecret(redditClientSecretPreferenceKey, reddit.clientSecret);
    await _preferences.setString(redditUsernamePreferenceKey, reddit.username);
    await _saveSecret(redditPasswordPreferenceKey, reddit.password);

    await _saveSecret(pixivSessionIdPreferenceKey, settings.pixiv.sessionId);

    final danbooru = settings.danbooru;
    await _preferences.setString(
      danbooruUsernamePreferenceKey,
      danbooru.username,
    );
    await _saveSecret(danbooruApiKeyPreferenceKey, danbooru.apiKey);

    final gelbooru = settings.gelbooru;
    await _preferences.setString(gelbooruUserIdPreferenceKey, gelbooru.userId);
    await _saveSecret(gelbooruApiKeyPreferenceKey, gelbooru.apiKey);

    final pinterest = settings.pinterest;
    await _preferences.setString(
      pinterestUsernamePreferenceKey,
      pinterest.username,
    );
    await _saveSecret(pinterestSessionIdPreferenceKey, pinterest.sessionId);

    await _saveSecret(
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

    await _preferences.setString(
      browserAsidePreferenceKey,
      settings.browserAside.id,
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
