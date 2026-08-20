import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Todos los fernies de la aplicación, uno debajo de otro.
///
/// Es la lista de la pantalla de gestión de fernies: pulsar uno lo selecciona, y
/// es lo que decide qué enseñan la ficha y la rejilla que hay a su izquierda.
///
/// A diferencia de la de etiquetas no tiene jerarquía ni sangría: un fernie no
/// cuelga de otro. Lo que sí lleva cada fila es el recuento de regiones, que es
/// lo único que dice de un vistazo cuáles dan ya para entrenar.
class FernieList extends StatelessWidget {
  final List<FernieEntity> fernies;

  /// Fernie marcado, por identificador: al guardar cambian el nombre y el
  /// avatar, pero el identificador es el mismo y la fila sigue marcada.
  final int? selectedFernieId;

  final ValueChanged<FernieEntity> onSelected;

  const FernieList({
    super.key,
    required this.fernies,
    required this.onSelected,
    this.selectedFernieId,
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
            icon: Icons.face_retouching_natural_outlined,
            iconAsset: icFernie,
            title: texts.ferniesTitle,
          ),
        ),
        Expanded(
          // Las filas se pintan bajo demanda: los fernies pueden ser muchos.
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: fernies.length,
            itemBuilder: (context, index) => _FernieTile(
              fernie: fernies[index],
              isSelected: fernies[index].id == selectedFernieId,
              onTap: () => onSelected(fernies[index]),
            ),
          ),
        ),
      ],
    );
  }
}

/// Fila de la lista: avatar, nombre y cuántas regiones tiene.
class _FernieTile extends StatelessWidget {
  final FernieEntity fernie;
  final bool isSelected;
  final VoidCallback onTap;

  const _FernieTile({
    required this.fernie,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

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
        padding: const EdgeInsets.all(AppSpacing.s),
        child: Row(
          children: [
            FernAvatar(
              imagePath: fernie.picturePath,
              fallbackIcon: Icons.face_retouching_natural,
              fallbackAsset: icFernie,
              radius: AppSizes.avatarMedium,
              iconSize: AppSizes.iconMedium,
              backgroundColor: context.colors.secondary,
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fernie.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    texts.fernieRegionCount(fernie.regionCount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: context.colors.unremarked),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
