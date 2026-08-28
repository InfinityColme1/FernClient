import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_log_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Qué hicieron los modelos, contenido a contenido.
///
/// Existe por una pregunta que la aplicación no sabía contestar: «¿por qué aquí
/// no ha salido nada?». La respuesta útil casi nunca es «no vio nada» —suele ser
/// «lo vio al 27 % y tu listón está en el 35 %»—, y ésa es la que deja hacer
/// algo al respecto.
///
/// Con un solo contenido se abre ya desplegado: es lo que pasa al venir desde el
/// visor, y ahí no hay nada que elegir.
class RecognitionLogDialog extends StatefulWidget {
  final List<MediaRecognitionLog> logs;

  const RecognitionLogDialog({super.key, required this.logs});

  @override
  State<RecognitionLogDialog> createState() => _RecognitionLogDialogState();
}

class _RecognitionLogDialogState extends State<RecognitionLogDialog> {
  /// El parte, sin lo que ahora mismo no se puede enseñar.
  ///
  /// El parte se arma mientras se reconoce y lleva dentro los nombres y las
  /// caras de los modelos y de los fernies. Sin este filtro sería la puerta de
  /// atrás de todo lo demás: bastaría reconocer una tanda y abrir el parte para
  /// leer justo lo que el filtro esconde.
  ///
  /// Se calcula una vez, al abrir, y no en cada pintado: es una lista corta pero
  /// se recorre entera, y el diálogo se reconstruye al desplegar cada fila.
  late final List<MediaRecognitionLog> _logs = _visible(widget.logs);

  late final Set<int> _open =
      _logs.length == 1 ? {_logs.single.mediaId} : <int>{};

  /// Quita del parte los modelos escondidos y, de los que quedan, lo que dijeron
  /// de un fernie escondido.
  List<MediaRecognitionLog> _visible(List<MediaRecognitionLog> logs) {
    final visibility = getIt.isRegistered<NsfwVisibility>()
        ? getIt<NsfwVisibility>()
        : const ContentVisibility();

    return [
      for (final log in logs)
        MediaRecognitionLog(
          mediaId: log.mediaId,
          name: log.name,
          at: log.at,
          models: [
            for (final entry in log.models)
              if (!visibility.hidesModel(entry.modelId))
                RecognitionLogEntry(
                  modelId: entry.modelId,
                  modelName: entry.modelName,
                  picturePath: entry.picturePath,
                  verdict: entry.verdict,
                  threshold: entry.threshold,
                  sightings: [
                    for (final sighting in entry.sightings)
                      if (!visibility.hidesFernie(sighting.fernieId)) sighting,
                  ],
                ),
          ],
        ),
    ];
  }

  void _toggle(int mediaId) {
    setState(() {
      if (!_open.remove(mediaId)) _open.add(mediaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth,
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(texts.recognitionLogTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Text(
            texts.recognitionLogSubtitle(_logs.length),
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: context.colors.unremarked),
          ),
          const SizedBox(height: AppSpacing.l),
          // Con altura acotada y desplazable: un lote de trescientos contenidos
          // no cabe en ninguna pantalla, y un diálogo que se sale por abajo es
          // peor que uno que se desplaza.
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final log in _logs)
                    _MediaRow(
                      log: log,
                      isOpen: _open.contains(log.mediaId),
                      onTap: _logs.length == 1
                          ? null
                          : () => _toggle(log.mediaId),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Un contenido: su resumen y, desplegado, lo que dijo cada modelo.
class _MediaRow extends StatelessWidget {
  final MediaRecognitionLog log;
  final bool isOpen;
  final VoidCallback? onTap;

  const _MediaRow({required this.log, required this.isOpen, this.onTap});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                if (onTap != null)
                  Icon(
                    isOpen ? Symbols.expand_more : Symbols.chevron_right,
                    size: AppSizes.iconMedium,
                    color: context.colors.unremarked,
                  ),
                Expanded(
                  child: Text(
                    log.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  log.proposed > 0
                      ? texts.recognitionLogProposed(log.proposed)
                      : log.hasNearMisses
                          ? texts.recognitionLogNearMiss
                          : texts.recognitionLogNothing,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: log.proposed > 0
                        ? context.colors.terciary
                        : context.colors.unremarked,
                  ),
                ),
              ],
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.l,
                top: AppSpacing.s,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in log.models) _ModelRow(entry: entry),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Lo que un modelo dijo, y con cuánta seguridad.
class _ModelRow extends StatelessWidget {
  final RecognitionLogEntry entry;

  const _ModelRow({required this.entry});

  /// El veredicto, dicho de forma que se pueda hacer algo con él.
  String _verdict(AppLocalizations texts) {
    return switch (entry.verdict) {
      RecognitionVerdict.proposed => texts.recognitionLogVerdictProposed,
      RecognitionVerdict.belowThreshold =>
        texts.recognitionLogVerdictBelow((entry.threshold * 100).round()),
      RecognitionVerdict.sawNothing => texts.recognitionLogVerdictNothing,
      RecognitionVerdict.notReached => texts.recognitionLogVerdictNotReached,
      RecognitionVerdict.untrained => texts.recognitionLogVerdictUntrained,
    };
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final isGood = entry.verdict == RecognitionVerdict.proposed;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // La cara del modelo, la misma del árbol. El log es una lista de
              // nombres parecidos, y es lo que deja encontrar el que interesa
              // sin leerlos uno a uno.
              FernAvatar(
                imagePath: entry.picturePath,
                fallbackIcon: Symbols.hub,
                radius: AppSizes.avatarSmall,
                iconSize: AppSizes.iconSmall,
                backgroundColor: context.colors.secondary,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  entry.modelName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                _verdict(texts),
                style: theme.textTheme.labelSmall?.copyWith(
                  color:
                      isGood ? context.colors.terciary : context.colors.unremarked,
                ),
              ),
            ],
          ),
          // Lo que vio, pasara o no el listón. Lo que no pasó va tachado: se ve
          // de un vistazo que el modelo **sí** reconoció algo y que lo que falló
          // fue el listón, que es lo único que el usuario puede mover.
          for (final sighting in entry.sightings)
            Padding(
              // Alineado con el nombre del modelo, no con su cara: lo que vio es
              // suyo, y colgarlo del nombre es lo que lo dice.
              padding: const EdgeInsets.only(
                left: AppSizes.avatarSmall * 2 + AppSpacing.s,
              ),
              child: Text(
                '${sighting.fernieName} · ${sighting.percent} %',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: context.colors.unremarked,
                  decoration: sighting.confidence < entry.threshold
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
