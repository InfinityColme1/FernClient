import 'dart:async';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/tag_log_entry_entity.dart';
import 'package:Fern/features/media/domain/usecases/get_media_tag_log_usecase.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// De dónde ha salido cada etiqueta y el creador de un contenido.
///
/// La aplicación etiqueta sola por cinco caminos —la dirección de la que se
/// bajó, la etiqueta que traía la plataforma, lo que arrastran la rama y las
/// hermanas, lo que propone un modelo y lo que enlaza un fernie— y en el panel
/// todo se ve igual: una etiqueta más. Cuando aparece una que nadie esperaba, la
/// pregunta es de dónde salió, y hasta ahora no había ningún sitio donde
/// mirarlo.
///
/// Lo del contenido anterior al registro **se deduce y se dice que se deduce**:
/// es una lectura de cómo están los datos ahora, no de lo que pasó, y cambiar la
/// dirección de una etiqueta mañana cambiaría la respuesta.
class TagLogDialog extends StatefulWidget {
  final int mediaId;

  /// El registro ya leído. Normalmente llega `null` y se lee al abrir; se puede
  /// dar hecho desde fuera, que es lo que hacen las pruebas.
  final MediaTagLogView? view;

  const TagLogDialog({super.key, required this.mediaId, this.view});

  @override
  State<TagLogDialog> createState() => _TagLogDialogState();
}

class _TagLogDialogState extends State<TagLogDialog> {
  late MediaTagLogView? _view = widget.view;

  @override
  void initState() {
    super.initState();

    if (widget.view == null) unawaited(_load());
  }

  Future<void> _load() async {
    final result = await getIt<GetMediaTagLogUseCase>()(params: widget.mediaId);
    if (!mounted) return;

    setState(() => _view = result is DataSuccess
        ? result.data
        : (entries: const <TagLogEntryEntity>[], isGuess: false));
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final view = _view;

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(texts.tagLogTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Text(
            // Dos avisos distintos y no uno matizado: lo que se deduce y lo que
            // consta no son la misma clase de cosa, y leerlos igual haría que lo
            // segundo no valiera para nada. Se mezclan, así que manda el aviso
            // de lo deducido en cuanto haya una línea que lo sea.
            view == null
                ? texts.tagLogLoading
                : view.isGuess
                    ? texts.tagLogGuessNote
                    : texts.tagLogNote,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.colors.gray,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          if (view != null)
            Flexible(
              child: view.entries.isEmpty
                  ? Text(
                      texts.tagLogEmpty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.colors.unremarked,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final entry in view.entries)
                            _LogRow(entry: entry),
                        ],
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  final TagLogEntryEntity entry;

  const _LogRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // El avatar de la etiqueta y no un icono por motivo: es cómo se
          // reconoce una etiqueta en el resto de la aplicación —el menú, el
          // panel, las pastillas— y el porqué ya se lee debajo del nombre. Con
          // un icono por motivo había que aprenderse siete dibujos para saber
          // algo que la línea de abajo dice con palabras.
          FernAvatar(
            imagePath: entry.imagePath,
            // La de reserva distingue lo único que aquí no se ve en el nombre:
            // si la línea habla de una etiqueta o de un creador.
            fallbackIcon: entry.isCreator ? Symbols.person : Symbols.sell,
            radius: AppSizes.avatarSmall,
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.label, style: theme.textTheme.bodyLarge),
                Text(
                  // Lo deducido va marcado línea a línea: en una lista mezclada,
                  // el aviso de arriba no dice **cuáles** no constan, y ésa es
                  // justo la diferencia que hay que poder ver.
                  entry.isGuess
                      ? '${_whyOf(texts, entry)} · ${texts.tagLogGuessed}'
                      : _whyOf(texts, entry),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.colors.unremarked,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// El porqué en una línea, con el detalle dentro cuando lo hay: «heredada de
/// Miraculous» dice mucho más que «heredada».
String _whyOf(AppLocalizations texts, TagLogEntryEntity entry) {
  final detail = entry.detail;

  return switch (entry.reason) {
    TagLogReason.manual => texts.tagLogManual,
    TagLogReason.sourceUrl => texts.tagLogSourceUrl,
    TagLogReason.platform => texts.tagLogPlatform,
    TagLogReason.ancestor =>
      detail == null ? texts.tagLogAncestor : texts.tagLogAncestorOf(detail),
    TagLogReason.sibling =>
      detail == null ? texts.tagLogSibling : texts.tagLogSiblingOf(detail),
    TagLogReason.recognition => texts.tagLogRecognition,
    TagLogReason.fernie =>
      detail == null ? texts.tagLogFernie : texts.tagLogFernieOf(detail),
    TagLogReason.unknown => texts.tagLogUnknown,
  };
}
