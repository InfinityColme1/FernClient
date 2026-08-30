import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Todos los fernies de la aplicación, uno debajo de otro.
///
/// Es la lista de la pantalla de gestión de fernies: pulsar uno lo selecciona, y
/// es lo que decide qué enseñan la ficha y la rejilla que hay a su izquierda.
///
/// A diferencia de la de etiquetas no tiene jerarquía ni sangría: un fernie no
/// cuelga de otro. Lo que sí lleva cada fila es el recuento de regiones, que es
/// lo único que dice de un vistazo cuáles dan ya para entrenar.
///
/// Y su filtro, como las de etiquetas y creadores: con cincuenta fernies, ir
/// buscando uno a ojo por la lista es lo que se acaba haciendo.
class FernieList extends StatefulWidget {
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
  State<FernieList> createState() => _FernieListState();
}

class _FernieListState extends State<FernieList> {
  /// Lo escrito en el filtro. Vacío es la lista entera.
  String _query = '';

  /// Los que encajan con lo escrito.
  ///
  /// Se compara sin distinguir mayúsculas y por cualquier parte del nombre, no
  /// sólo por el principio: es lo mismo que hacen las otras dos listas, y con
  /// cincuenta fernies acordarse de cómo empieza uno es justo lo que no pasa.
  List<FernieEntity> get _visible {
    final needle = _query.trim().toLowerCase();
    if (needle.isEmpty) return widget.fernies;

    return [
      for (final fernie in widget.fernies)
        if (fernie.name.toLowerCase().contains(needle)) fernie,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final fernies = _visible;

    // La lista va directamente sobre el fondo de la pantalla: la superficie de
    // esta pantalla es la de la ficha, no la de todo lo que hay en ella.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: FernSectionHeader(
            icon: Symbols.face_retouching_natural,
            title: texts.ferniesTitle,
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
          // Las filas se pintan bajo demanda: los fernies pueden ser muchos.
          child: ListView.builder(
            // Apartado por la derecha lo que ocupa la barra de desplazamiento,
            // como en las otras dos listas: sin ese carril la pastilla queda
            // pegada al borde de la ficha y parece parte de ella.
            padding: const EdgeInsets.only(right: AppSizes.scrollbarLane),
            itemCount: fernies.length,
            itemBuilder: (context, index) => _FernieTile(
              fernie: fernies[index],
              isSelected: fernies[index].id == widget.selectedFernieId,
              onTap: () => widget.onSelected(fernies[index]),
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

  /// Quién sabe si este fernie esconde algo. Se pregunta al pintar, como en la
  /// celda de contenido: la lista se rehace al marcar, y así no hace falta que
  /// nadie la avise.
  ContentVisibility get _visibility => getIt.isRegistered<NsfwVisibility>()
      ? getIt<NsfwVisibility>()
      : const ContentVisibility();

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
              fallbackIcon: Symbols.face_retouching_natural,
              radius: AppSizes.avatarMedium,
              iconSize: AppSizes.iconMedium,
              backgroundColor: context.colors.secondary,
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          fernie.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      // Con el filtro puesto este fernie ni aparece, así que
                      // esto sólo se ve sin él: es entonces cuando hace falta
                      // saber cuál de los que se están usando esconde algo.
                      if (_visibility.marksFernie(fernie.id)) ...[
                        const SizedBox(width: AppSpacing.s),
                        const NsfwTagMark(),
                      ],
                    ],
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
