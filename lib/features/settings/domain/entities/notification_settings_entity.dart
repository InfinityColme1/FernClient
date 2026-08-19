import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/notifications/domain/entities/app_notification.dart';
import 'package:equatable/equatable.dart';

/// Cómo avisa una clase concreta de aviso.
///
/// Las dos vías se encienden por separado porque no molestan igual: el contador
/// del menú se puede dejar puesto siempre, y el sonido es lo primero que se
/// quita quien trabaja con la aplicación abierta todo el día.
class NotificationChannelEntity extends Equatable {
  final bool badge;
  final bool sound;

  /// El fichero que suena. `null` mientras el usuario no elija uno: entonces
  /// suena el de fábrica que le corresponda a esa clase de aviso.
  final String? soundPath;

  const NotificationChannelEntity({
    this.badge = true,
    this.sound = true,
    this.soundPath,
  });

  NotificationChannelEntity copyWith({
    bool? badge,
    bool? sound,
    String? soundPath,
    bool clearSoundPath = false,
  }) {
    return NotificationChannelEntity(
      badge: badge ?? this.badge,
      sound: sound ?? this.sound,
      soundPath: clearSoundPath ? null : (soundPath ?? this.soundPath),
    );
  }

  @override
  List<Object?> get props => [badge, sound, soundPath];
}

/// Los avisos de la aplicación.
class NotificationSettingsEntity extends Equatable {
  /// El interruptor general. Apagado, no hay ni contadores ni sonidos.
  final bool enabled;

  /// Silencio: los contadores siguen, los sonidos no.
  final bool muted;

  /// De 0 a 100.
  final int volume;

  /// Cuánto se deja sonar un aviso. Lo que dure de más se corta al reproducir;
  /// el fichero del usuario no se toca.
  final int maxSeconds;

  final Map<NotificationKind, NotificationChannelEntity> channels;

  const NotificationSettingsEntity({
    this.enabled = true,
    this.muted = false,
    this.volume = defaultNotificationVolume,
    this.maxSeconds = defaultNotificationSeconds,
    this.channels = const {},
  });

  NotificationChannelEntity channel(NotificationKind kind) =>
      channels[kind] ?? const NotificationChannelEntity();

  /// Si esta clase de aviso tiene que poner contador ahora mismo.
  bool showsBadge(NotificationKind kind) => enabled && channel(kind).badge;

  /// Si esta clase de aviso tiene que sonar ahora mismo.
  bool playsSound(NotificationKind kind) =>
      enabled && !muted && volume > 0 && channel(kind).sound;

  NotificationSettingsEntity copyWith({
    bool? enabled,
    bool? muted,
    int? volume,
    int? maxSeconds,
    Map<NotificationKind, NotificationChannelEntity>? channels,
  }) {
    return NotificationSettingsEntity(
      enabled: enabled ?? this.enabled,
      muted: muted ?? this.muted,
      volume: volume ?? this.volume,
      maxSeconds: maxSeconds ?? this.maxSeconds,
      channels: channels ?? this.channels,
    );
  }

  /// Cambia sólo lo de una clase de aviso, dejando las demás como estaban.
  NotificationSettingsEntity withChannel(
    NotificationKind kind,
    NotificationChannelEntity channel,
  ) {
    return copyWith(channels: {...channels, kind: channel});
  }

  @override
  List<Object?> get props => [enabled, muted, volume, maxSeconds, channels];
}
