import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Todos los creadores de la aplicación, uno debajo de otro.
///
/// Es la lista de la pantalla de gestión de creadores: pulsar uno lo selecciona,
/// y es lo que decide qué enseñan la ficha y la rejilla que hay a su izquierda.
///
/// Es la hermana de `TagList` sin la jerarquía: un creador no cuelga de otro, así
/// que no hay ni sangría ni árbol que recorrer, sólo la lista tal y como llega
/// (ordenada por nombre).
class CreatorList extends StatefulWidget {
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
  State<CreatorList> createState() => _CreatorListState();
}

class _CreatorListState extends State<CreatorList> {
  /// Lo escrito en el filtro. Vacío es la lista entera.
  String _query = '';

  /// Los que encajan con lo escrito.
  ///
  /// Se compara sin distinguir mayúsculas y por cualquier parte del nombre, no
  /// sólo por el principio: con doscientos creadores, acordarse de cómo empieza
  /// uno es justo lo que no pasa.
  List<CreatorEntity> get _visible {
    final needle = _query.trim().toLowerCase();
    if (needle.isEmpty) return widget.creators;

    return [
      for (final creator in widget.creators)
        if (creator.name.toLowerCase().contains(needle)) creator,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final creators = _visible;

    // La lista va directamente sobre el fondo de la pantalla: la superficie de
    // esta pantalla es la de la ficha, no la de todo lo que hay en ella.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: FernSectionHeader(
            icon: Symbols.person,
            title: texts.creatorsTitle,
          ),
        ),
        // Encima de la lista y debajo del rótulo: filtra lo que hay justo
        // debajo, así que es donde se busca sin pensarlo.
        Padding(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.s,
            right: AppSizes.scrollbarLane,
          ),
          child: FernFilterField(
            hintText: texts.filterByNameHint,
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          // Las filas se pintan bajo demanda: los creadores pueden ser muchos.
          child: ListView.builder(
            // Apartado por la derecha lo que ocupa la barra de
            // desplazamiento: sin ese carril la pastilla queda pegada al borde
            // de las fichas y parece parte de ellas.
            padding: const EdgeInsets.only(right: AppSizes.scrollbarLane),
            itemCount: creators.length,
            itemBuilder: (context, index) => _CreatorTile(
              creator: creators[index],
              isSelected: creators[index].id == widget.selectedCreatorId,
              onTap: () => widget.onSelected(creators[index]),
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

  /// Quién sabe si este creador esconde algo. Se pregunta al pintar, como en la
  /// fila de un fernie: la lista se rehace al marcar, y así no hace falta que
  /// nadie la avise.
  ContentVisibility get _visibility => getIt.isRegistered<NsfwVisibility>()
      ? getIt<NsfwVisibility>()
      : const ContentVisibility();

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
          color: isSelected ? context.colors.primary : Colors.transparent,
          borderRadius: borderRadius,
        ),
        padding: const EdgeInsets.all(AppSpacing.s),
        // Como las filas de la lista de etiquetas, con el nombre recortado: la
        // lista es estrecha y un nombre largo desbordaría la fila.
        child: Row(
          children: [
            FernAvatar(
              imagePath: creator.picturePath,
              fallbackIcon: Symbols.person,
              radius: AppSizes.avatarMedium,
              iconSize: AppSizes.iconMedium,
              backgroundColor: context.colors.secondary,
            ),
            const SizedBox(width: AppSpacing.m),
            Flexible(
              child: Text(
                creator.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            // Con el filtro puesto este creador ni aparece, así que esto sólo se
            // ve sin él: es entonces cuando hace falta saber cuál de los que se
            // están usando esconde algo.
            if (_visibility.marksCreator(creator.id)) ...[
              const SizedBox(width: AppSpacing.s),
              const NsfwTagMark(),
            ],
          ],
        ),
      ),
    );
  }
}
