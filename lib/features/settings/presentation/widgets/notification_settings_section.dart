import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/notifications/data/services/notification_sound_service.dart';
import 'package:Fern/features/notifications/domain/entities/app_notification.dart';
import 'package:Fern/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

/// Cómo se nombra cada clase de aviso en la pantalla. El dominio sólo guarda su
/// identificador.
extension NotificationKindLabels on NotificationKind {
  String label(AppLocalizations texts) => switch (this) {
        NotificationKind.duplicatesFound => texts.notifyDuplicates,
        NotificationKind.trainingFinished => texts.notifyTraining,
        NotificationKind.recognitionFinished => texts.notifyRecognition,
        NotificationKind.importFinished => texts.notifyImport,
        NotificationKind.linkReview => texts.notifyLinkReview,
      };
}

/// Los avisos: cuáles se dan, cuáles suenan y con qué sonido.
class NotificationSettingsSection extends StatefulWidget {
  const NotificationSettingsSection({super.key});

  @override
  State<NotificationSettingsSection> createState() =>
      _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState
    extends State<NotificationSettingsSection> {
  final _sounds = getIt<NotificationSoundService>();

  /// Lo que dura el audio elegido de cada aviso, según se va sabiendo. Leerlo
  /// obliga a abrir el fichero, así que se hace una vez y se recuerda.
  final Map<NotificationKind, Duration?> _durations = {};
  final Set<NotificationKind> _measuring = {};

  /// Mide el audio de [kind] si no se ha hecho ya.
  Future<void> _measure(NotificationKind kind, String path) async {
    if (_durations.containsKey(kind) || _measuring.contains(kind)) return;

    _measuring.add(kind);
    final duration = await _sounds.durationOf(path);

    if (!mounted) return;
    setState(() {
      _measuring.remove(kind);
      _durations[kind] = duration;
    });
  }

  Future<void> _pickSound(
    NotificationKind kind,
    NotificationSettingsEntity notifications,
  ) async {
    final result = await FilePicker.pickFiles(type: FileType.audio);
    final picked = result?.files.single.path;
    if (picked == null || !mounted) return;

    // Se guarda una copia nuestra, como con los avatares: mover o borrar el
    // original no puede dejar el aviso mudo.
    final stored = await _sounds.store(picked);

    // Y la copia anterior se tira: probar cinco audios no puede dejar cinco
    // ficheros en la carpeta para siempre.
    await _discardCopy(kind, notifications);
    if (!mounted) return;

    setState(() => _durations.remove(kind));

    context.read<SettingsBloc>().add(NotificationSettingsChangedEvent(
          notifications.withChannel(
            kind,
            notifications.channel(kind).copyWith(soundPath: stored),
          ),
        ));
  }

  Future<void> _resetSound(
    NotificationKind kind,
    NotificationSettingsEntity notifications,
  ) async {
    await _discardCopy(kind, notifications);
    if (!mounted) return;

    setState(() => _durations.remove(kind));

    context.read<SettingsBloc>().add(NotificationSettingsChangedEvent(
          notifications.withChannel(
            kind,
            notifications.channel(kind).copyWith(clearSoundPath: true),
          ),
        ));
  }

  /// Borra la copia que tenía [kind], si era suya y de nadie más.
  ///
  /// Lo de "de nadie más" no es teórico: si el usuario elige como sonido de un
  /// aviso un fichero que ya estaba en la carpeta, [NotificationSoundService.store]
  /// lo devuelve tal cual en lugar de copiarlo otra vez, así que dos avisos
  /// pueden acabar apuntando al mismo sitio. Borrarlo dejaría mudo al otro.
  Future<void> _discardCopy(
    NotificationKind kind,
    NotificationSettingsEntity notifications,
  ) async {
    final current = notifications.channel(kind).soundPath;
    if (current == null || current.isEmpty) return;

    final sharedWithAnother = NotificationKind.values.any(
      (other) => other != kind && notifications.channel(other).soundPath == current,
    );
    if (sharedWithAnother) return;

    await _sounds.remove(current);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final notifications = state.settings.notifications;
        final bloc = context.read<SettingsBloc>();

        void apply(NotificationSettingsEntity updated) =>
            bloc.add(NotificationSettingsChangedEvent(updated));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context, texts.notificationsTitle),
            _description(context, texts.notificationsDescription),
            const SizedBox(height: AppSpacing.l),
            FernCheckboxTile(
              label: texts.notificationsEnabled,
              description: texts.notificationsEnabledDescription,
              value: notifications.enabled,
              onChanged: (value) => apply(notifications.copyWith(enabled: value)),
            ),
            FernCheckboxTile(
              label: texts.notificationsMuted,
              description: texts.notificationsMutedDescription,
              value: notifications.muted,
              onChanged: notifications.enabled
                  ? (value) => apply(notifications.copyWith(muted: value))
                  : null,
            ),

            _separator(),
            _title(context, texts.notificationsSoundTitle),
            const SizedBox(height: AppSpacing.s),
            _slider(
              context,
              label: texts.notificationsVolume,
              value: notifications.volume.toDouble(),
              min: 0,
              max: 100,
              suffix: '${notifications.volume} %',
              onChanged: notifications.enabled && !notifications.muted
                  ? (value) =>
                      apply(notifications.copyWith(volume: value.round()))
                  : null,
            ),
            const SizedBox(height: AppSpacing.m),
            _slider(
              context,
              label: texts.notificationsMaxSeconds,
              value: notifications.maxSeconds.toDouble(),
              min: minNotificationSeconds.toDouble(),
              max: maxNotificationSeconds.toDouble(),
              suffix: texts.notificationsSeconds(notifications.maxSeconds),
              onChanged: notifications.enabled
                  ? (value) =>
                      apply(notifications.copyWith(maxSeconds: value.round()))
                  : null,
            ),
            _description(context, texts.notificationsMaxSecondsDescription),

            _separator(),
            _title(context, texts.notificationsEventsTitle),
            _description(context, texts.notificationsEventsDescription),
            const SizedBox(height: AppSpacing.l),
            for (final kind in NotificationKind.values)
              _eventRow(context, texts, notifications, kind, apply),
          ],
        );
      },
    );
  }

  /// Una fila por clase de aviso: si pone contador, si suena, con qué suena y un
  /// botón para escucharlo tal y como sonará.
  Widget _eventRow(
    BuildContext context,
    AppLocalizations texts,
    NotificationSettingsEntity notifications,
    NotificationKind kind,
    void Function(NotificationSettingsEntity) apply,
  ) {
    final channel = notifications.channel(kind);
    final soundPath = _sounds.resolveSound(kind, notifications);
    final isCustom = channel.soundPath != null && channel.soundPath!.isNotEmpty;

    if (isCustom) unawaitedMeasure(kind, soundPath);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kind.label(texts),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: FernCheckboxTile(
                  label: texts.notificationsBadge,
                  value: channel.badge,
                  onChanged: notifications.enabled
                      ? (value) => apply(notifications.withChannel(
                            kind,
                            channel.copyWith(badge: value),
                          ))
                      : null,
                ),
              ),
              Expanded(
                child: FernCheckboxTile(
                  label: texts.notificationsSound,
                  value: channel.sound,
                  onChanged: notifications.enabled && !notifications.muted
                      ? (value) => apply(notifications.withChannel(
                            kind,
                            channel.copyWith(sound: value),
                          ))
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Expanded(
                child: Text(
                  _soundLabel(texts, kind, soundPath, isCustom),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: context.colors.gray),
                ),
              ),
              IconButton(
                tooltip: texts.notificationsPreview,
                iconSize: AppSizes.iconMedium,
                onPressed: () => _sounds.preview(
                  soundPath,
                  volume: notifications.volume,
                  maxSeconds: notifications.maxSeconds,
                ),
                icon: const Icon(Icons.play_arrow),
              ),
              IconButton(
                tooltip: texts.notificationsChooseSound,
                iconSize: AppSizes.iconMedium,
                onPressed: notifications.enabled
                    ? () => _pickSound(kind, notifications)
                    : null,
                icon: const Icon(Icons.folder_open),
              ),
              if (isCustom)
                IconButton(
                  tooltip: texts.notificationsResetSound,
                  iconSize: AppSizes.iconMedium,
                  onPressed: () => _resetSound(kind, notifications),
                  icon: const Icon(Icons.restore),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Qué suena y cuánto dura, con el aviso de que se va a cortar si se pasa.
  String _soundLabel(
    AppLocalizations texts,
    NotificationKind kind,
    String path,
    bool isCustom,
  ) {
    if (!isCustom) return texts.notificationsDefaultSound;

    final name = p.basename(path);
    final duration = _durations[kind];

    if (duration == null) return name;

    final seconds = duration.inSeconds;
    final formatted =
        '${duration.inMinutes}:${(seconds % 60).toString().padLeft(2, '0')}';

    return '$name · $formatted';
  }

  /// Mide sin bloquear la construcción: el resultado llega con un `setState`.
  void unawaitedMeasure(NotificationKind kind, String path) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure(kind, path));
  }

  Widget _slider(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required String suffix,
    ValueChanged<double>? onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: AppSizes.settingsLabelWidth,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: AppSizes.settingsValueWidth,
          child: Text(
            suffix,
            textAlign: TextAlign.end,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.colors.gray),
          ),
        ),
      ],
    );
  }

  Widget _title(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _description(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: context.colors.gray),
    );
  }

  Widget _separator() => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Divider(),
      );
}
