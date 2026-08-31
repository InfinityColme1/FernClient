import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Lo que se ha pedido marcar: qué etiqueta y con cuántos fotogramas por vídeo.
@immutable
class TagRegionsRequest {
  final TagEntity tag;
  final int frameSamples;

  const TagRegionsRequest({required this.tag, required this.frameSamples});
}

/// Pide qué etiqueta marcar entera como regiones de un fernie.
///
/// Un fernie se entrena con regiones, y montar uno desde cero era abrir
/// contenido a contenido y marcar el fotograma entero en cada uno. Cuando la
/// etiqueta ya dice de qué va todo lo que lleva, ese trabajo es mecánico.
///
/// No guarda nada: devuelve lo elegido y quien lo abre encola el trabajo. El
/// recuento se pide fuera por lo mismo — la pantalla que lo abre es la que sabe
/// consultar.
class ImportTagRegionsDialog extends StatefulWidget {
  /// Cómo se llama el fernie que va a recibir las regiones, para poder decirlo.
  final String fernieName;

  /// Cuántos fotogramas por vídeo se ofrecen de entrada. El del ajuste.
  final int defaultSamples;

  final Future<List<TagEntity>> Function(String query) searchTags;

  /// Cuántos contenidos lleva la etiqueta elegida, para decir a qué se está
  /// diciendo que sí antes de decirlo.
  final Future<int> Function(TagEntity tag) countOf;

  const ImportTagRegionsDialog({
    super.key,
    required this.fernieName,
    required this.searchTags,
    required this.countOf,
    this.defaultSamples = defaultFrameSamples,
  });

  @override
  State<ImportTagRegionsDialog> createState() => _ImportTagRegionsDialogState();
}

class _ImportTagRegionsDialogState extends State<ImportTagRegionsDialog> {
  TagEntity? _tag;
  late int _samples = widget.defaultSamples;

  /// Cuántos contenidos lleva la etiqueta elegida. `null` mientras se cuentan.
  int? _count;

  Future<void> _choose(TagEntity tag) async {
    setState(() {
      _tag = tag;
      _count = null;
    });

    final count = await widget.countOf(tag);
    if (!mounted || _tag?.id != tag.id) return;

    setState(() => _count = count);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      leftContent: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(texts.fernieImportTagTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.fernieImportTagNote,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.colors.gray,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            FernEntitySearchField<TagEntity>(
              label: texts.tagsTitle,
              hintText: texts.searchEllipsisHint,
              search: widget.searchTags,
              labelOf: (tag) => tag.name,
              onSelected: _choose,
              debounce: searchDebounceDuration,
            ),

            // A qué se está diciendo que sí. Doscientos contenidos y dos no se
            // parecen en nada, y desde el nombre de la etiqueta no se adivina.
            //
            // Sólo con la cuenta hecha: mientras se cuenta no se pinta nada, que
            // es preferible a un texto de relleno para un instante.
            if (_count case final count?) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                texts.fernieImportTagCount(count),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.colors.unremarked,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.l),
            Text(texts.fernieImportTagFrames, style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              texts.fernieImportTagFramesNote,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.colors.gray,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            FernDropdownPill<int>(
              value: _samples,
              items: [for (var each = 1; each <= maxFrameSamples; each++) each],
              labelBuilder: (value) => '$value',
              onChanged: (value) =>
                  setState(() => _samples = value ?? _samples),
            ),
          ],
        ),
      ),
      actionButton: FernActionButton(
        label: texts.fernieImportTagAction,
        // Sin etiqueta no hay nada que marcar, y con una vacía tampoco: el botón
        // encendido sobre cero contenidos promete un trabajo que no ocurre.
        onPressed: _tag == null || _count == 0
            ? null
            : () => Navigator.of(context).pop(
                  TagRegionsRequest(tag: _tag!, frameSamples: _samples),
                ),
      ),
    );
  }
}
