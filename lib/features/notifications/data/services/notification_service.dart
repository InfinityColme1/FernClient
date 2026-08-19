import 'dart:async';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/notifications/data/services/notification_sound_service.dart';
import 'package:Fern/features/notifications/domain/entities/app_notification.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lo que la aplicación tiene pendiente de contarle al usuario.
///
/// Guarda un contador por clase de aviso y avisa a quien escuche. Los contadores
/// se persisten porque un aviso tiene que sobrevivir a cerrar la aplicación: si
/// el escaneo de repetidos encontró doce anoche, hoy siguen ahí.
///
/// No hay histórico de avisos sueltos: lo que se enseña es un número sobre un
/// botón del menú, y una lista que nadie consulta sería estado de más.
class NotificationService {
  final SharedPreferences _preferences;
  final SettingsRepository _settingsRepository;
  final NotificationSoundService _sounds;

  final StreamController<AppNotificationCounts> _controller =
      StreamController<AppNotificationCounts>.broadcast();

  NotificationService({
    required SharedPreferences preferences,
    required SettingsRepository settingsRepository,
    required NotificationSoundService sounds,
  })  : _preferences = preferences,
        _settingsRepository = settingsRepository,
        _sounds = sounds;

  String _countKey(NotificationKind kind) =>
      '$notificationCountPreferenceKeyPrefix${kind.id}';

  /// Cuántos avisos hay sin mirar, por clase.
  AppNotificationCounts get counts => AppNotificationCounts({
        for (final kind in NotificationKind.values)
          kind: _preferences.getInt(_countKey(kind)) ?? 0,
      });

  Stream<AppNotificationCounts> get changes => _controller.stream;

  /// Da un aviso de [kind], sumando [count] a lo que hubiera pendiente.
  ///
  /// El contador sube aunque el usuario haya apagado el sonido: lo que se apaga
  /// es cómo se le cuenta, no que haya pasado. Con los avisos apagados del todo
  /// no se anota nada, que es lo que el usuario ha pedido.
  Future<void> notify(NotificationKind kind, {int count = 1}) async {
    final settings = _settingsRepository.getSettings().notifications;
    if (!settings.enabled) return;

    if (settings.showsBadge(kind)) {
      final updated = (_preferences.getInt(_countKey(kind)) ?? 0) + count;
      await _preferences.setInt(_countKey(kind), updated);
      _controller.add(counts);
    }

    if (settings.playsSound(kind)) {
      await _sounds.play(kind, settings: settings);
    }
  }

  /// Da por vistos los avisos que llevaban a [route].
  ///
  /// Se llama al entrar en la pantalla, no al pasar el ratón por encima del
  /// botón: lo que apaga el aviso es haber ido a mirar.
  Future<void> markRouteSeen(String route) async {
    var changed = false;

    for (final kind in NotificationKind.values) {
      if (kind.route != route) continue;
      if ((_preferences.getInt(_countKey(kind)) ?? 0) == 0) continue;

      await _preferences.remove(_countKey(kind));
      changed = true;
    }

    if (changed) _controller.add(counts);
  }

  /// Borra todos los contadores. Lo usa el ajuste que apaga los avisos: dejar
  /// números encendidos que ya no se van a actualizar confundiría.
  Future<void> clearAll() async {
    for (final kind in NotificationKind.values) {
      await _preferences.remove(_countKey(kind));
    }

    _controller.add(counts);
  }

  Future<void> dispose() => _controller.close();
}
