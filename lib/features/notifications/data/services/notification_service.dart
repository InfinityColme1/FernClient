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

  /// Con qué clave se recuerda a dónde lleva un aviso.
  String _routeKey(NotificationKind kind) => '${_countKey(kind)}_route';

  String _countKey(NotificationKind kind) =>
      '$notificationCountPreferenceKeyPrefix${kind.id}';

  /// Cuántos avisos hay sin mirar, por clase.
  AppNotificationCounts get counts => AppNotificationCounts(
        {
          for (final kind in NotificationKind.values)
            kind: _preferences.getInt(_countKey(kind)) ?? 0,
        },
        routes: {
          for (final kind in NotificationKind.values)
            if (_preferences.getString(_routeKey(kind)) case final route?)
              kind: route,
        },
      );

  Stream<AppNotificationCounts> get changes => _controller.stream;

  /// Da un aviso de [kind], sumando [count] a lo que hubiera pendiente.
  ///
  /// El contador sube aunque el usuario haya apagado el sonido: lo que se apaga
  /// es cómo se le cuenta, no que haya pasado. Con los avisos apagados del todo
  /// no se anota nada, que es lo que el usuario ha pedido.
  /// Avisa de algo.
  ///
  /// Con [route] se dice a dónde lleva este aviso en concreto, cuando no es a la
  /// pantalla de siempre de su tipo: reconocer contenido definitivo termina en
  /// la pantalla de contenido, y llevar allí a la de importación es mandar al
  /// usuario donde no está lo que acaba de reconocer.
  Future<void> notify(
    NotificationKind kind, {
    int count = 1,
    String? route,
  }) async {
    final settings = _settingsRepository.getSettings().notifications;
    if (!settings.enabled) return;

    if (settings.showsBadge(kind)) {
      final updated = (_preferences.getInt(_countKey(kind)) ?? 0) + count;
      await _preferences.setInt(_countKey(kind), updated);

      // Manda el último: si dos reconocimientos seguidos acaban en pantallas
      // distintas, el contador es uno solo y tiene que estar en alguna. La del
      // último es la que el usuario tiene fresca.
      if (route != null) {
        await _preferences.setString(_routeKey(kind), route);
      }

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

    final current = counts;

    for (final kind in NotificationKind.values) {
      // Por donde lleva **ahora**, no por su pantalla de siempre: un aviso de
      // reconocimiento puede haber acabado en la de contenido, y darlo por visto
      // al pasar por importación lo apagaría sin que nadie lo haya mirado.
      if (current.routeOf(kind) != route) continue;
      if ((_preferences.getInt(_countKey(kind)) ?? 0) == 0) continue;

      await _preferences.remove(_countKey(kind));
      await _preferences.remove(_routeKey(kind));
      changed = true;
    }

    if (changed) _controller.add(counts);
  }

  /// Borra todos los contadores. Lo usa el ajuste que apaga los avisos: dejar
  /// números encendidos que ya no se van a actualizar confundiría.
  Future<void> clearAll() async {
    for (final kind in NotificationKind.values) {
      await _preferences.remove(_countKey(kind));
      await _preferences.remove(_routeKey(kind));
    }

    _controller.add(counts);
  }

  Future<void> dispose() => _controller.close();
}
