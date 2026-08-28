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

/// Qué se hace con una etiqueta soltada sobre otra.
///
/// **Son dos cosas distintas**, no dos formas de lo mismo: una cambia la
/// jerarquía y la otra crea un enlace entre dos etiquetas que siguen donde
/// están.
enum TagDropMode {
  /// Cuelga de aquella sobre la que se ha soltado.
  child,

  /// Queda relacionada con aquella: «cuando pongas ésta, pon también ésa».
  ///
  /// Ni madre ni hija — las dos se quedan donde estaban en el árbol. La relación
  /// es simétrica.
  related,
}

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
///
/// **La jerarquía también se toca desde aquí**: una etiqueta se arrastra sobre
/// otra y se elige si cuelga de ella o si se pone a su lado. Antes eso sólo se
/// podía hacer abriendo la ficha de cada una, y con el árbol grande era ir y
/// venir por una lista de doscientas.
class TagList extends StatefulWidget {
  final List<TagEntity> tags;

  /// Etiqueta marcada, por identificador: al guardar cambia el nombre y el
  /// avatar, pero el identificador es el mismo y la fila sigue marcada.
  final int? selectedTagId;

  final ValueChanged<TagEntity> onSelected;

  /// Qué hacer con una etiqueta soltada sobre otra.
  ///
  /// La lista sólo dice qué se ha soltado sobre qué y qué se ha elegido; lo que
  /// eso significa —colgar una de otra o relacionarlas— lo resuelve quien
  /// recibe esto, que es quien sabe guardar. Sin esto puesto, las filas no se
  /// arrastran.
  final void Function(TagEntity dragged, TagEntity target, TagDropMode mode)?
      onDropped;

  const TagList({
    super.key,
    required this.tags,
    required this.onSelected,
    this.selectedTagId,
    this.onDropped,
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

  /// De quién cuelga [id], o `null` si es raíz.
  ///
  /// Es lo que hace falta para poner una etiqueta «al lado de» otra: al lado
  /// significa colgando de la misma madre.
  static TagEntity? parentOf(List<TagEntity> tags, int id, {TagEntity? under}) {
    for (final tag in tags) {
      if (tag.id == id) return under;

      final found = parentOf(tag.children, id, under: tag);
      if (found != null) return found;
    }

    return null;
  }

  /// Si [id] está dentro de [tag], a cualquier profundidad.
  ///
  /// Sirve para no ofrecer lo imposible: una etiqueta no puede colgar de una de
  /// sus propias hijas — el árbol se mordería la cola y la rama entera se
  /// perdería de vista.
  static bool contains(TagEntity tag, int id) {
    for (final child in tag.children) {
      if (child.id == id || contains(child, id)) return true;
    }

    return false;
  }

  @override
  State<TagList> createState() => _TagListState();
}

class _TagListState extends State<TagList> {
  /// Lo escrito en el filtro. Vacío es el árbol entero.
  String _query = '';

  /// El menú de soltar, mientras está abierto.
  _Drop? _drop;

  /// Para pasar el punto donde se ha soltado a coordenadas de la pila.
  final _stackKey = GlobalKey();

  /// Lo que se pinta: el árbol con su sangría, o lo que encaje con el filtro.
  ///
  /// **Filtrando se pierde la sangría a propósito.** Lo que encaja puede estar a
  /// tres niveles de distancia de lo siguiente que encaja, y sangrar filas
  /// sueltas cuyas madres no se ven dibuja un árbol que no existe.
  List<TagRow> get _rows {
    final needle = _query.trim().toLowerCase();
    final all = TagList.flatten(widget.tags);

    if (needle.isEmpty) return all;

    return [
      for (final row in all)
        if (row.tag.name.toLowerCase().contains(needle))
          (tag: row.tag, depth: 0),
    ];
  }

  /// Si [dragged] se puede soltar sobre [target].
  bool _accepts(TagEntity dragged, TagEntity target) =>
      dragged.id != target.id && !TagList.contains(dragged, target.id);

  void _onDropped(TagEntity dragged, TagEntity target, Offset globalPosition) {
    final box = _stackKey.currentContext?.findRenderObject();
    if (box is! RenderBox) return;

    setState(() {
      _drop = _Drop(
        dragged: dragged,
        target: target,
        at: box.globalToLocal(globalPosition),
      );
    });
  }

  void _resolve(TagDropMode mode) {
    final drop = _drop;
    if (drop == null) return;

    setState(() => _drop = null);
    widget.onDropped?.call(drop.dragged, drop.target, mode);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final rows = _rows;

    // La lista va directamente sobre el fondo de la pantalla: la superficie de
    // esta pantalla es la de la ficha, no la de todo lo que hay en ella.
    return Stack(
      key: _stackKey,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: FernSectionHeader(
                icon: Symbols.label,
                title: texts.tagsTitle,
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
              // Las filas se pintan bajo demanda: las etiquetas pueden ser
              // muchas.
              child: ListView.builder(
                // Apartado por la derecha lo que ocupa la barra de
                // desplazamiento: sin ese carril la pastilla queda pegada al
                // borde de las fichas y parece parte de ellas.
                padding: const EdgeInsets.only(right: AppSizes.scrollbarLane),
                itemCount: rows.length,
                itemBuilder: (context, index) => _TagTile(
                  row: rows[index],
                  isSelected: rows[index].tag.id == widget.selectedTagId,
                  onTap: () => widget.onSelected(rows[index].tag),
                  isDraggable: widget.onDropped != null,
                  accepts: (dragged) => _accepts(dragged, rows[index].tag),
                  onDropped: (dragged, at) =>
                      _onDropped(dragged, rows[index].tag, at),
                ),
              ),
            ),
          ],
        ),
        if (_drop case final drop?)
          FernContextMenu(
            position: drop.at,
            onDismiss: () => setState(() => _drop = null),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DropOption(
                  icon: Symbols.subdirectory_arrow_right,
                  label: texts.tagDropAsChild(drop.target.name),
                  onTap: () => _resolve(TagDropMode.child),
                ),
                _DropOption(
                  icon: Symbols.link,
                  label: texts.tagDropAsSibling(drop.target.name),
                  onTap: () => _resolve(TagDropMode.related),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Una etiqueta soltada sobre otra, esperando a que se diga qué hacer con ella.
class _Drop {
  final TagEntity dragged;
  final TagEntity target;
  final Offset at;

  const _Drop({required this.dragged, required this.target, required this.at});
}

/// Una de las dos cosas que se pueden hacer al soltar.
class _DropOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DropOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      onPressed: onTap,
      leadingIcon: Icon(icon, size: AppSizes.iconMedium),
      // Con tope y recortado: el nombre de la etiqueta va dentro del texto, y un
      // nombre largo desbordaba el panel por la derecha.
      child: SizedBox(
        width: AppSizes.menuLabelWidth,
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

/// Fila de la lista: avatar y nombre de la etiqueta, sangrada según su nivel y
/// resaltada cuando es la elegida.
///
/// Se arrastra y recibe: es la forma de mover una etiqueta por el árbol sin
/// abrir su ficha.
class _TagTile extends StatelessWidget {
  final TagRow row;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDraggable;
  final bool Function(TagEntity dragged) accepts;
  final void Function(TagEntity dragged, Offset at) onDropped;

  const _TagTile({
    required this.row,
    required this.isSelected,
    required this.onTap,
    required this.isDraggable,
    required this.accepts,
    required this.onDropped,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDraggable) return _tile(context);

    return DragTarget<TagEntity>(
      onWillAcceptWithDetails: (details) => accepts(details.data),
      onAcceptWithDetails: (details) => onDropped(details.data, details.offset),
      builder: (context, candidate, _) => Draggable<TagEntity>(
        data: row.tag,
        // El puntero lleva la etiqueta, no la esquina de la fila: se está
        // señalando dónde soltarla, y con la fila colgando de una esquina lo
        // señalado y lo que se ve no coinciden.
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: _feedback(context),
        // Mientras viaja, su sitio se queda apagado: es lo que dice que lo que
        // se está moviendo es eso y no una copia.
        childWhenDragging: Opacity(opacity: draggingGhostOpacity, child: _tile(context)),
        child: _tile(context, isUnderDrag: candidate.isNotEmpty),
      ),
    );
  }

  /// Lo que sigue al ratón: el nombre y poco más.
  Widget _feedback(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FernSurface.raised(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FernAvatar(
              imagePath: row.tag.picturePath,
              fallbackIcon: Symbols.label,
              radius: AppSizes.avatarSmall,
              iconSize: AppSizes.iconSmall,
              backgroundColor: context.colors.secondary,
            ),
            const SizedBox(width: AppSpacing.s),
            Text(row.tag.name, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, {bool isUnderDrag = false}) {
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
          color: isSelected
              ? context.colors.primary
              : (isUnderDrag ? context.colors.stateLayer : Colors.transparent),
          borderRadius: borderRadius,
          // Con algo encima, el borde dice cuál es la fila que lo va a recibir:
          // el fondo solo se pierde sobre la que ya está marcada.
          border: isUnderDrag
              ? Border.all(
                  color: context.colors.primary,
                  width: AppSizes.borderRegular,
                )
              : null,
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
