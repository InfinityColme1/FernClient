import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Una etiqueta de la lista y el nivel que ocupa en la jerarquía.
typedef TagRow = ({TagEntity tag, int depth});

/// Todas las etiquetas de la aplicación, una debajo de otra y con la jerarquía a
/// la vista.
///
/// Es la lista de la pantalla de gestión de etiquetas: pulsar una etiqueta la
/// selecciona, y es lo que decide qué enseñan la tarjeta y la rejilla que hay a
/// su izquierda.
///
/// Como en el menú lateral, la jerarquía se cuenta con la sangría de cada fila:
/// [tags] llega en forma de árbol (sólo las raíces, con sus descendientes
/// colgando) y aquí se recorre en el orden en el que se ve, madres antes que
/// hijas.
class TagList extends StatelessWidget {
  final List<TagEntity> tags;

  /// Etiqueta marcada, por identificador: al guardar cambia el nombre y el
  /// avatar, pero el identificador es el mismo y la fila sigue marcada.
  final int? selectedTagId;

  final ValueChanged<TagEntity> onSelected;

  const TagList({
    super.key,
    required this.tags,
    required this.onSelected,
    this.selectedTagId,
  });

  /// Las etiquetas aplanadas en el orden en el que se pintan, cada una con su
  /// nivel.
  static List<TagRow> flatten(List<TagEntity> tags, {int depth = 0}) {
    return [
      for (final tag in tags) ...[
        (tag: tag, depth: depth),
        ...flatten(tag.children, depth: depth + 1),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final rows = flatten(tags);

    // La lista va directamente sobre el fondo de la pantalla: la superficie de
    // esta pantalla es la de la ficha, no la de todo lo que hay en ella.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: FernSectionHeader(
            icon: Symbols.label,
            title: texts.tagsTitle,
          ),
        ),
        Expanded(
          // Las filas se pintan bajo demanda: las etiquetas pueden ser muchas.
          child: ListView.builder(
            // Apartado por la derecha lo que ocupa la barra de
            // desplazamiento: sin ese carril la pastilla queda pegada al borde
            // de las fichas y parece parte de ellas.
            padding: const EdgeInsets.only(right: AppSizes.scrollbarLane),
            itemCount: rows.length,
            itemBuilder: (context, index) => _TagTile(
              row: rows[index],
              isSelected: rows[index].tag.id == selectedTagId,
              onTap: () => onSelected(rows[index].tag),
            ),
          ),
        ),
      ],
    );
  }
}

/// Fila de la lista: avatar y nombre de la etiqueta, sangrada según su nivel y
/// resaltada cuando es la elegida.
class _TagTile extends StatelessWidget {
  final TagRow row;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagTile({
    required this.row,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tag = row.tag;

    final borderRadius = BorderRadius.circular(AppSizes.radiusLarge);

    return InkWell(
      onTap: onTap,
      mouseCursor: WidgetStateMouseCursor.clickable,
      borderRadius: borderRadius,
      child: Container(
        // Sin superficie debajo, lo marcado se redondea por su cuenta: es una
        // píldora sobre el fondo de la pantalla, no una franja de una lista.
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : Colors.transparent,
          borderRadius: borderRadius,
        ),
        padding: EdgeInsets.only(
          left: AppSpacing.s + row.depth * tagListDepthIndent,
          right: AppSpacing.s,
          top: AppSpacing.s,
          bottom: AppSpacing.s,
        ),
        // Como las etiquetas del panel de información (avatar y nombre, sin
        // píldora), pero con el nombre recortado: la lista es estrecha y un
        // nombre largo desbordaría la fila.
        child: Row(
          children: [
            FernAvatar(
              imagePath: tag.picturePath,
              fallbackIcon: Symbols.label,
              radius: AppSizes.avatarMedium,
              iconSize: AppSizes.iconMedium,
              backgroundColor: context.colors.secondary,
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                tag.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
