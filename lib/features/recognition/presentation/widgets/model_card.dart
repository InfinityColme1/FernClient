import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Una celda de la rejilla de modelos.
///
/// Dice de un vistazo las cuatro cosas que importan: quién es, qué pregunta
/// responde, cuánto material tiene para aprender y **si sirve ya para algo**. Lo
/// último es lo que separa un modelo entrenado de una carpeta de buenas
/// intenciones, así que va con color y no sólo con texto.
class ModelCard extends StatefulWidget {
  final RecognitionModelEntity model;
  final VoidCallback? onTap;

  /// Qué hacer al pulsar el botón de borrar. Sin esto, la tarjeta no lo enseña.
  final VoidCallback? onDelete;

  /// Por dónde va el entrenamiento, de 0 a 1, mientras esté en marcha. `null`
  /// cuando no se sabe todavía, que es lo que distingue una barra que avanza de
  /// una que da vueltas.
  final double? progress;

  const ModelCard({
    super.key,
    required this.model,
    this.onTap,
    this.onDelete,
    this.progress,
  });

  @override
  State<ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends State<ModelCard> {
  bool _isHovered = false;

  /// Quién sabe si este modelo está marcado. Se pregunta al pintar, como en la
  /// lista de fernies: con el filtro puesto la tarjeta ni se pinta, así que esto
  /// sólo se ve sin él.
  ContentVisibility get _visibility => getIt.isRegistered<NsfwVisibility>()
      ? getIt<NsfwVisibility>()
      : const ContentVisibility();

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Stack(
        children: [
          _card(context, texts, theme),
          if (widget.onDelete != null) _deleteButton(context, texts),
        ],
      ),
    );
  }

  void _setHovered(bool value) {
    if (_isHovered == value) return;
    setState(() => _isHovered = value);
  }

  Widget _card(BuildContext context, AppLocalizations texts, ThemeData theme) {
    final model = widget.model;

    return AnimatedContainer(
      duration: hoverAnimationDuration,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        // La silueta: con el cursor encima la tarjeta se recorta del fondo, que
        // es lo que dice que se puede hacer algo con ella.
        border: Border.all(
          color: _isHovered ? context.colors.terciary : Colors.transparent,
          width: AppSizes.borderRegular,
        ),
      ),
      child: FernSurface(
        child: InkWell(
          onTap: widget.onTap,
          // Sin esto el cursor sigue siendo la flecha de siempre y la tarjeta no
          // parece pulsable, por mucho que se remarque al pasar por encima.
          mouseCursor: WidgetStateMouseCursor.clickable,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FernAvatar(
                  imagePath: model.picturePath,
                  fallbackIcon: Symbols.hub,
                  radius: AppSizes.avatarXLarge,
                  iconSize: AppSizes.iconExtraLarge,
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        model.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    if (_visibility.marksModel(model.id)) ...[
                      const SizedBox(width: AppSpacing.s),
                      const NsfwTagMark(),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),

                // La función **efectiva**, no la elegida: si con un solo fernie
                // se comporta como booleano, eso es lo que hace y eso es lo que
                // hay que enseñar.
                Text(
                  _functionLabel(texts),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.colors.unremarked,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${texts.modelFernieCount(model.fernieCount)} · '
                  '${texts.modelRegionCount(model.regionCount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.colors.unremarked,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                _status(context, texts),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// El botón de borrar, en el borde de arriba.
  ///
  /// Sólo con el cursor encima: una papelera permanente en cada tarjeta invita a
  /// pulsarla sin querer, y aquí lo que se borra no vuelve.
  Widget _deleteButton(BuildContext context, AppLocalizations texts) {
    return Positioned(
      top: AppSpacing.xs,
      right: AppSpacing.xs,
      child: AnimatedOpacity(
        opacity: _isHovered ? 1 : 0,
        duration: hoverAnimationDuration,
        child: IgnorePointer(
          ignoring: !_isHovered,
          child: Material(
            color: context.colors.white,
            shape: const CircleBorder(),
            elevation: contextMenuElevation,
            child: IconButton(
              tooltip: texts.modelDeleteTitle,
              onPressed: widget.onDelete,
              icon: Icon(
                Symbols.delete,
                size: AppSizes.iconMedium,
                color: context.colors.error,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _functionLabel(AppLocalizations texts) {
    final model = widget.model;
    final label = switch (model.effectiveFunction) {
      ModelFunction.boolean => texts.modelFunctionBoolean,
      ModelFunction.classification => texts.modelFunctionClassification,
    };

    // Con la función degradada se marca: lo que se ve no es lo que se eligió, y
    // callarlo haría pensar que el modelo se ha cambiado solo por capricho.
    return model.isDegraded ? '$label *' : label;
  }

  /// El estado, con su color.
  ///
  /// Entrenando enseña además por dónde va, que es lo único que hace llevadera
  /// una espera de veinte minutos.
  Widget _status(BuildContext context, AppLocalizations texts) {
    final (label, color) = switch (widget.model.status) {
      ModelTrainingStatus.untrained => (
        texts.modelStatusUntrained,
        context.colors.unremarked,
      ),
      ModelTrainingStatus.training => (
        texts.modelStatusTraining,
        context.colors.terciary,
      ),
      ModelTrainingStatus.ready => (
        texts.modelStatusReady,
        context.colors.gray,
      ),
      ModelTrainingStatus.failed => (
        texts.modelStatusFailed,
        context.colors.error,
      ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSpacing.s,
              height: AppSpacing.s,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
        if (widget.model.status == ModelTrainingStatus.training) ...[
          const SizedBox(height: AppSpacing.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            child: LinearProgressIndicator(
              value: widget.progress,
              minHeight: trackHeight,
              backgroundColor: context.colors.lightgray,
              color: context.colors.terciary,
            ),
          ),
        ],
      ],
    );
  }
}
