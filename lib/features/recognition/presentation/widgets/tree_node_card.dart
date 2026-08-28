import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Un modelo dentro del árbol.
///
/// Dice lo justo: quién es, si se puede ejecutar y si está elegido. Los detalles
/// —los fernies, el reparto, las métricas— viven en su pantalla, y repetirlos
/// aquí haría la tarjeta ilegible justo cuando hay quince.
///
/// Con el lienzo muy alejado se queda sólo con el nombre: a ese tamaño lo demás
/// no se lee y sólo emborrona.
class TreeNodeCard extends StatelessWidget {
  final ModelTreeNodeEntity node;
  final bool isSelected;

  /// El lienzo está tan alejado que no merece la pena el detalle.
  final bool isSimplified;

  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const TreeNodeCard({
    super.key,
    required this.node,
    this.isSelected = false,
    this.isSimplified = false,
    this.onTap,
    this.onRemove,
  });

  /// Quién sabe si este modelo esconde algo. Con el filtro puesto el nodo ni se
  /// pinta —el bloc lo saca del árbol—, así que esto sólo se ve sin él: es
  /// entonces cuando hace falta saber qué rama del árbol trabaja con lo marcado.
  ContentVisibility get _visibility => getIt.isRegistered<NsfwVisibility>()
      ? getIt<NsfwVisibility>()
      : const ContentVisibility();

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      width: AppSizes.treeNodeWidth,
      height: AppSizes.treeNodeHeight,
      child: Material(
        color: context.colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: InkWell(
          onTap: onTap,
          mouseCursor: WidgetStateMouseCursor.clickable,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              // Elegido con borde y no con fondo: el fondo cambiaría el contraste
              // del texto y de los avisos que lleva dentro.
              border: Border.all(
                color: isSelected
                    ? context.colors.terciary
                    : context.colors.lightgray,
                width: isSelected ? AppSizes.borderRegular : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FernAvatar(
                      imagePath: node.model.picturePath,
                      fallbackIcon: Symbols.hub,
                      radius: AppSizes.avatarSmall,
                      iconSize: AppSizes.iconSmall,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Text(
                        node.model.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    // Alejado no: la tarjeta simplificada es un rótulo con una
                    // cara, y un distintivo más a ese tamaño no se lee.
                    if (!isSimplified &&
                        _visibility.marksModel(node.model.id)) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const NsfwTagMark(),
                    ],
                    if (onRemove != null && !isSimplified)
                      IconButton(
                        tooltip: texts.treeRemoveNode,
                        onPressed: onRemove,
                        iconSize: AppSizes.iconSmall,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Symbols.close,
                          color: context.colors.unremarked,
                        ),
                      ),
                  ],
                ),
                if (!isSimplified) ...[
                  const Spacer(),
                  _status(context, texts),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Si este nodo va a hacer algo al reconocer.
  ///
  /// Un modelo sin entrenar se salta: no bloquea el reconocimiento, pero todo lo
  /// que cuelga de él se queda sin ejecutar, y eso no se ve mirando el árbol si
  /// no se dice aquí.
  Widget _status(BuildContext context, AppLocalizations texts) {
    final theme = Theme.of(context);

    if (!node.isRunnable) {
      return Row(
        children: [
          Icon(
            Symbols.warning_amber,
            size: AppSizes.iconSmall,
            color: context.colors.error,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Expanded(
            child: Text(
              texts.treeNodeNotTrained,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: context.colors.error),
            ),
          ),
        ],
      );
    }

    return Text(
      texts.modelFernieCount(node.model.fernieCount),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style:
          theme.textTheme.bodySmall?.copyWith(color: context.colors.unremarked),
    );
  }
}
