import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Todos los creadores de la aplicación, uno debajo de otro.
///
/// Es la lista de la pantalla de gestión de creadores: pulsar uno lo selecciona,
/// y es lo que decide qué enseñan la ficha y la rejilla que hay a su izquierda.
///
/// Es la hermana de `TagList` sin la jerarquía: un creador no cuelga de otro, así
/// que no hay ni sangría ni árbol que recorrer, sólo la lista tal y como llega
/// (ordenada por nombre).
class CreatorList extends StatelessWidget {
  final List<CreatorEntity> creators;

  /// Creador marcado, por identificador: al guardar cambian el nombre y el
  /// avatar, pero el identificador es el mismo y la fila sigue marcada.
  final int? selectedCreatorId;

  final ValueChanged<CreatorEntity> onSelected;

  const CreatorList({
    super.key,
    required this.creators,
    required this.onSelected,
    this.selectedCreatorId,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    // La lista va directamente sobre el fondo de la pantalla: la superficie de
    // esta pantalla es la de la ficha, no la de todo lo que hay en ella.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: FernSectionHeader(
            icon: Icons.person_outline,
            title: texts.creatorsTitle,
          ),
        ),
        Expanded(
          // Las filas se pintan bajo demanda: los creadores pueden ser muchos.
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: creators.length,
            itemBuilder: (context, index) => _CreatorTile(
              creator: creators[index],
              isSelected: creators[index].id == selectedCreatorId,
              onTap: () => onSelected(creators[index]),
            ),
          ),
        ),
      ],
    );
  }
}

/// Fila de la lista: avatar y nombre del creador, resaltado cuando es el
/// elegido.
class _CreatorTile extends StatelessWidget {
  final CreatorEntity creator;
  final bool isSelected;
  final VoidCallback onTap;

  const _CreatorTile({
    required this.creator,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppSizes.radiusLarge);

    return InkWell(
      onTap: onTap,
      mouseCursor: WidgetStateMouseCursor.clickable,
      borderRadius: borderRadius,
      child: Container(
        // Sin superficie debajo, lo marcado se redondea por su cuenta: es una
        // píldora sobre el fondo de la pantalla, no una franja de una lista.
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: borderRadius,
        ),
        padding: const EdgeInsets.all(AppSpacing.s),
        // Como las filas de la lista de etiquetas, con el nombre recortado: la
        // lista es estrecha y un nombre largo desbordaría la fila.
        child: Row(
          children: [
            FernAvatar(
              imagePath: creator.picturePath,
              fallbackIcon: Icons.person,
              radius: AppSizes.avatarMedium,
              iconSize: AppSizes.iconMedium,
              backgroundColor: AppColors.secondary,
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                creator.name,
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
