import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/services/tag_relations_layout.dart';
import 'package:Fern/core/ui/display/nsfw_tag_mark.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Con quién se relaciona una etiqueta: de quién cuelga y con quiénes va a la
/// par.
@immutable
class TagRelations {
  final TagEntity? parent;
  final List<TagEntity> siblings;

  const TagRelations({this.parent, this.siblings = const []});
}

/// De quién cuelga una etiqueta y con quiénes va a la par, en un árbol.
///
/// Estaba en la ficha, con un campo de texto para la madre y otro para las
/// hermanas más la lista de las que había. Entre las tres cosas ocupaban tanto
/// que la rejilla de contenido de debajo se salía de la pantalla, y aun así no
/// se veía lo único que importa de esto: **la forma** que tienen las relaciones.
///
/// Aquí se ve. La etiqueta en el centro, su madre encima y sus hermanas a los
/// lados, que es literalmente lo que significan las tres cosas.
///
/// Devuelve lo elegido al cerrarse y no guarda nada: quien lo abre ya sabe
/// guardar una madre y unas hermanas, y hacerlo también aquí sería tener dos
/// sitios que escriben lo mismo.
class TagRelationsDialog extends StatefulWidget {
  final TagEntity tag;
  final TagEntity? parent;
  final List<TagEntity> siblings;

  /// Con qué se rellenan los buscadores. Va por parámetro para poder montar el
  /// diálogo sin base de datos.
  final Future<List<TagEntity>> Function(String query) searchParents;
  final Future<List<TagEntity>> Function(String query) searchSiblings;

  /// Crea una etiqueta que todavía no existe y la devuelve.
  ///
  /// Hace falta aquí porque muchas veces la etiqueta madre **no existe todavía**:
  /// se está organizando un montón de etiquetas sueltas y la que las agrupa hay
  /// que inventarla en ese momento. Mandar al usuario a crearla a otra pantalla y
  /// volver es perder el hilo de lo que estaba montando.
  final Future<TagEntity?> Function()? createTag;

  const TagRelationsDialog({
    super.key,
    required this.tag,
    required this.searchParents,
    required this.searchSiblings,
    this.parent,
    this.siblings = const [],
    this.createTag,
  });

  @override
  State<TagRelationsDialog> createState() => _TagRelationsDialogState();
}

class _TagRelationsDialogState extends State<TagRelationsDialog> {
  late TagEntity? _parent = widget.parent;
  late List<TagEntity> _siblings = [...widget.siblings];

  /// El buscador se rehace al elegir para que se vacíe solo.
  Key _searchKey = UniqueKey();

  /// Qué se está añadiendo ahora mismo, o nada.
  _Adding? _adding;

  /// Todas las etiquetas del árbol, por identificador, para poder pintarlas
  /// sabiendo sólo el número que da la colocación.
  Map<int, TagEntity> get _byId => {
        widget.tag.id: widget.tag,
        if (_parent case final parent?) parent.id: parent,
        for (final sibling in _siblings) sibling.id: sibling,
      };

  void _choose(TagEntity tag) {
    setState(() {
      if (_adding == _Adding.parent) {
        _parent = tag;
      } else {
        _siblings = [..._siblings, tag];
      }

      _adding = null;
      _searchKey = UniqueKey();
    });
  }

  /// Crea una etiqueta y la pone en el sitio que se estuviera rellenando.
  Future<void> _create() async {
    final created = await widget.createTag?.call();
    if (created == null || !mounted) return;

    _choose(created);
  }

  void _remove(int tagId) {
    setState(() {
      if (_parent?.id == tagId) {
        _parent = null;
        return;
      }

      _siblings = [for (final one in _siblings) if (one.id != tagId) one];
    });
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final slots = tagRelationsLayout(
      tagId: widget.tag.id,
      parentId: _parent?.id,
      siblingIds: [for (final one in _siblings) one.id],
    );

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      leftContent: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texts.tagRelationsTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.tagRelationsNote,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),
            const SizedBox(height: AppSpacing.l),
            _canvas(slots),
            const SizedBox(height: AppSpacing.l),
            _actions(texts),
          ],
        ),
      ),
      actionButton: FernActionButton(
        label: texts.actionSave,
        onPressed: () => Navigator.of(context).pop(
          TagRelations(parent: _parent, siblings: _siblings),
        ),
      ),
    );
  }

  /// El árbol: las tarjetas en su sitio y las líneas por debajo.
  ///
  /// Se desplaza a lo ancho porque el número de hermanas no tiene tope, y
  /// encoger las tarjetas para que quepan haría ilegible justo lo que se ha
  /// venido a leer.
  Widget _canvas(List<TagRelationSlot> slots) {
    final columns = tagRelationsColumns(slots);
    final hasParent = _parent != null;

    final width = columns.count * AppSizes.treeNodeWidth +
        (columns.count - 1) * AppSizes.treeColumnGap;
    final rows = hasParent ? 2 : 1;
    final height = rows * AppSizes.treeNodeHeight +
        (rows - 1) * AppSizes.treeRowGap;

    final byId = _byId;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            // Las líneas debajo de las tarjetas: entran por el borde, y encima
            // las cruzarían.
            Positioned.fill(
              child: CustomPaint(
                painter: _RelationsPainter(
                  slots: slots,
                  tagId: widget.tag.id,
                  parentId: _parent?.id,
                  firstColumn: columns.first,
                  topRow: hasParent ? parentRow : selfRow,
                  color: context.colors.lightgray,
                ),
              ),
            ),
            for (final slot in slots)
              if (byId[slot.tagId] case final tag?)
                Positioned(
                  left: (slot.column - columns.first) *
                      (AppSizes.treeNodeWidth + AppSizes.treeColumnGap),
                  top: (slot.row - (hasParent ? parentRow : selfRow)) *
                      (AppSizes.treeNodeHeight + AppSizes.treeRowGap),
                  child: _TagNode(
                    tag: tag,
                    isSelf: tag.id == widget.tag.id,
                    // La etiqueta que se está editando no se puede quitar del
                    // árbol: es de quien es el árbol.
                    onRemove:
                        tag.id == widget.tag.id ? null : () => _remove(tag.id),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  /// Los dos botones de añadir y, cuando se pulsa uno, su buscador.
  ///
  /// El buscador aparece **debajo** y no en su propio diálogo: abrir un diálogo
  /// sobre otro para escribir un nombre tapa justo el árbol que se está
  /// montando.
  Widget _actions(AppLocalizations texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.m,
          runSpacing: AppSpacing.s,
          children: [
            FernPillButton(
              label: _parent == null
                  ? texts.tagRelationsAddParent
                  : texts.tagRelationsChangeParent,
              icon: Symbols.arrow_upward,
              backgroundColor: context.colors.secondary,
              foregroundColor: context.colors.black,
              onPressed: () => setState(() => _adding = _Adding.parent),
            ),
            FernPillButton(
              label: texts.tagRelationsAddSibling,
              icon: Symbols.swap_horiz,
              backgroundColor: context.colors.secondary,
              foregroundColor: context.colors.black,
              onPressed: () => setState(() => _adding = _Adding.sibling),
            ),
          ],
        ),
        if (_adding case final adding?) ...[
          const SizedBox(height: AppSpacing.l),
          FernEntitySearchField<TagEntity>(
            key: _searchKey,
            label: adding == _Adding.parent
                ? texts.parentTagLabel
                : texts.addSiblingTag,
            hintText: texts.searchEllipsisHint,
            search: adding == _Adding.parent
                ? widget.searchParents
                : widget.searchSiblings,
            labelOf: (tag) => tag.name,
            trailingOf: (tag) =>
                tag.isUnderNsfw ? const NsfwTagMark() : null,
            onSelected: _choose,
            debounce: searchDebounceDuration,
          ),
          if (widget.createTag != null) ...[
            const SizedBox(height: AppSpacing.s),
            FernPillButton(
              label: texts.tagRelationsCreate,
              icon: Symbols.add,
              backgroundColor: context.colors.secondary,
              foregroundColor: context.colors.black,
              onPressed: _create,
            ),
          ],
        ],
      ],
    );
  }
}

/// Qué se está añadiendo con el buscador.
enum _Adding { parent, sibling }

/// Una etiqueta dentro del árbol.
class _TagNode extends StatelessWidget {
  final TagEntity tag;
  final bool isSelf;
  final VoidCallback? onRemove;

  const _TagNode({required this.tag, required this.isSelf, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: AppSizes.treeNodeWidth,
      height: AppSizes.treeNodeHeight,
      child: FernSurface(
        // La que se está editando va en el color de la aplicación: en un árbol
        // de cinco tarjetas iguales hay que poder ver de un vistazo cuál es la
        // suya.
        color: isSelf ? context.colors.primary : null,
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          children: [
            FernAvatar(
              imagePath: tag.picturePath,
              fallbackIcon: Symbols.label,
              radius: AppSizes.avatarSmall,
              iconSize: AppSizes.iconCompact,
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelf ? FontWeight.w700 : null,
                    ),
                  ),
                  if (tag.isUnderNsfw) ...[
                    const SizedBox(height: AppSpacing.xs),
                    const NsfwTagMark(),
                  ],
                ],
              ),
            ),
            if (onRemove != null)
              IconButton(
                tooltip: AppLocalizations.of(context).actionRemove,
                iconSize: AppSizes.iconSmall,
                onPressed: onRemove,
                icon: const Icon(Symbols.close),
              ),
          ],
        ),
      ),
    );
  }
}

/// Las líneas que unen la etiqueta con su madre y con sus hermanas.
///
/// Dos trazos distintos a propósito: **de arriba abajo** para la madre, que es
/// una jerarquía, y **de lado a lado** para las hermanas, que no lo es. Con la
/// misma línea para las dos cosas, el árbol contaría que una hermana cuelga de
/// algo.
class _RelationsPainter extends CustomPainter {
  final List<TagRelationSlot> slots;
  final int tagId;
  final int? parentId;
  final int firstColumn;
  final int topRow;
  final Color color;

  const _RelationsPainter({
    required this.slots,
    required this.tagId,
    required this.parentId,
    required this.firstColumn,
    required this.topRow,
    required this.color,
  });

  Offset _centerOf(TagRelationSlot slot) => Offset(
        (slot.column - firstColumn) *
                (AppSizes.treeNodeWidth + AppSizes.treeColumnGap) +
            AppSizes.treeNodeWidth / 2,
        (slot.row - topRow) *
                (AppSizes.treeNodeHeight + AppSizes.treeRowGap) +
            AppSizes.treeNodeHeight / 2,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = treeEdgeWidth
      ..style = PaintingStyle.stroke;

    final self = slots.firstWhere((slot) => slot.tagId == tagId);
    final center = _centerOf(self);

    for (final slot in slots) {
      if (slot.tagId == tagId) continue;

      final other = _centerOf(slot);

      if (slot.tagId == parentId) {
        // De la madre baja hasta el borde de arriba de la etiqueta.
        canvas.drawLine(
          Offset(other.dx, other.dy + AppSizes.treeNodeHeight / 2),
          Offset(center.dx, center.dy - AppSizes.treeNodeHeight / 2),
          paint,
        );

        continue;
      }

      // A la hermana, de borde a borde y a la misma altura.
      final isLeft = other.dx < center.dx;

      canvas.drawLine(
        Offset(
          center.dx + (isLeft ? -1 : 1) * AppSizes.treeNodeWidth / 2,
          center.dy,
        ),
        Offset(
          other.dx + (isLeft ? 1 : -1) * AppSizes.treeNodeWidth / 2,
          other.dy,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RelationsPainter oldDelegate) =>
      oldDelegate.slots != slots ||
      oldDelegate.parentId != parentId ||
      oldDelegate.firstColumn != firstColumn ||
      oldDelegate.color != color;
}
