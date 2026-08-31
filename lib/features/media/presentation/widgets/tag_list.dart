import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/services/collapsed_tags.dart';
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
  /// El árbol **entero**, con etiquetas y personas mezcladas. Aquí se reparte.
  final List<TagEntity> tags;

  /// Si esta lista es la de personas. La otra enseña todo lo demás.
  ///
  /// El árbol es uno solo y compartido: una persona puede colgar de una etiqueta
  /// normal y ser hermana suya. Lo único que cambia es quién se pinta dónde.
  final bool showsPeople;

  /// Qué hacer al pulsar el botón de la cabecera, que lleva a la otra lista. Sin
  /// esto, el botón no sale.
  final VoidCallback? onSwitchList;

  /// Si al filtrar por nombre, lo que encaja llega con su descendencia.
  ///
  /// Sin decir nada se lee del ajuste, como la lista de fernies lee el filtro
  /// NSFW al pintarse: así cambiarlo en los ajustes se ve al volver, sin que la
  /// pantalla de encima tenga que enterarse ni pasarlo hacia abajo. Se puede
  /// forzar para poder probar las dos formas sin localizador de servicios.
  final bool? showsBranchOnFilter;

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
    this.showsPeople = false,
    this.onSwitchList,
    this.showsBranchOnFilter,
  });

  /// El árbol con sólo las etiquetas de una clase, **sin podar ramas enteras**.
  ///
  /// Una etiqueta que no entra no se lleva por delante lo que cuelga de ella: sus
  /// hijas suben al sitio que deja. Es lo que hace que una persona colgada de una
  /// etiqueta normal aparezca en la raíz de la lista de personas, y al revés, sin
  /// que ninguna se pierda por estar en la rama equivocada.
  static List<TagEntity> ofKind(List<TagEntity> tags, {required bool people}) {
    final kept = <TagEntity>[];

    for (final tag in tags) {
      final children = ofKind(tag.children, people: people);

      if (tag.isPerson == people) {
        kept.add(tag.copyWith(children: children));
      } else {
        kept.addAll(children);
      }
    }

    return kept;
  }

  /// Las etiquetas aplanadas en el orden en el que se pintan, cada una con su
  /// nivel.
  ///
  /// [collapsed] son las ramas plegadas: la madre se emite y su descendencia se
  /// corta ahí. **Se escribe una sola vez y la usan las dos listas** —ésta y el
  /// menú lateral—: aplanan el mismo árbol, y hacerlo por separado acabaría en
  /// dos comportamientos distintos en cuanto se arreglara algo en uno.
  ///
  /// Vacío es el árbol entero, que es lo que se pintaba antes de poder plegarlo.
  static List<TagRow> flatten(
    List<TagEntity> tags, {
    int depth = 0,
    Set<int> collapsed = const {},
  }) {
    return [
      for (final tag in tags) ...[
        (tag: tag, depth: depth),
        if (!collapsed.contains(tag.id))
          ...flatten(tag.children, depth: depth + 1, collapsed: collapsed),
      ],
    ];
  }

  /// Las etiquetas por encima de [id], de la raíz hacia abajo.
  ///
  /// Es lo que hay que desplegar para que una etiqueta se vea: una elegida
  /// dentro de una rama cerrada no está en pantalla, y la lista estaría diciendo
  /// que hay algo marcado que no se ve por ninguna parte.
  static List<TagEntity> ancestorsOf(List<TagEntity> tags, int id) {
    for (final tag in tags) {
      if (tag.id == id) return const [];

      if (contains(tag, id)) return [tag, ...ancestorsOf(tag.children, id)];
    }

    return const [];
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

  /// Las ramas plegadas. Se escucha en vez de leerse al montar: plegar desde el
  /// menú lateral tiene que verse aquí sin salir de la pantalla y volver.
  late final CollapsedTags? _collapsed = getIt.isRegistered<CollapsedTags>()
      ? getIt<CollapsedTags>()
      : null;

  @override
  void initState() {
    super.initState();
    _collapsed?.addListener(_onCollapsedChanged);
    _revealSelected();
  }

  @override
  void didUpdateWidget(TagList old) {
    super.didUpdateWidget(old);

    if (old.selectedTagId != widget.selectedTagId ||
        old.tags != widget.tags) {
      _revealSelected();
    }
  }

  /// Abre las ramas que hagan falta para que la etiqueta elegida se vea.
  ///
  /// Pasa al crear una hija bajo una madre plegada, y al mover una etiqueta a
  /// una rama cerrada: sin esto la fila marcada no está en pantalla y parece que
  /// no se ha hecho nada.
  void _revealSelected() {
    final collapsed = _collapsed;
    final id = widget.selectedTagId;
    if (collapsed == null || id == null) return;

    final hidden = [
      for (final ancestor in TagList.ancestorsOf(_tree, id))
        if (collapsed.isCollapsed(ancestor.id)) ancestor.id,
    ];
    if (hidden.isEmpty) return;

    // Después del fotograma: esto se llama desde `initState` y desde
    // `didUpdateWidget`, y avisar a quien escucha en mitad de una construcción
    // la deja a medias.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (final tagId in hidden) {
        await collapsed.expand(tagId);
      }
    });
  }

  @override
  void dispose() {
    _collapsed?.removeListener(_onCollapsedChanged);
    super.dispose();
  }

  void _onCollapsedChanged() {
    if (mounted) setState(() {});
  }

  Set<int> get _collapsedIds => _collapsed?.ids ?? const {};

  /// El menú de soltar, mientras está abierto.
  _Drop? _drop;

  /// Para pasar el punto donde se ha soltado a coordenadas de la pila.
  final _stackKey = GlobalKey();

  /// El árbol de esta lista: sólo las de su clase, con las demás apartadas.
  List<TagEntity> get _tree =>
      TagList.ofKind(widget.tags, people: widget.showsPeople);

  /// Si la rama acompaña a lo que encaja. De fábrica sí.
  bool get _showsBranch =>
      widget.showsBranchOnFilter ??
      (getIt.isRegistered<SettingsRepository>()
          ? getIt<SettingsRepository>().getSettings().showsTagBranchOnFilter
          : true);

  /// Lo que se pinta: el árbol con su sangría, o lo que encaje con el filtro.
  ///
  /// Filtrando hay dos formas, y el motivo de que haya dos es la sangría. Sin la
  /// rama, **se pierde a propósito**: lo que encaja puede estar a tres niveles de
  /// distancia de lo siguiente que encaja, y sangrar filas sueltas cuyas madres
  /// no se ven dibuja un árbol que no existe. Con la rama ese motivo desaparece,
  /// porque la madre de cada fila sangrada sí está: es la coincidencia de la que
  /// cuelga.
  List<TagRow> get _rows {
    final needle = _query.trim().toLowerCase();
    final tree = _tree;

    if (needle.isEmpty) {
      return TagList.flatten(tree, collapsed: _collapsedIds);
    }

    // Buscando **manda el filtro sobre lo plegado**: encontrar una etiqueta y no
    // verla porque su madre está cerrada sería un buscador que miente. Con el
    // campo vacío vuelve a mandar lo plegado.
    final all = TagList.flatten(tree);

    if (!_showsBranch) {
      return [
        for (final row in all)
          if (row.tag.name.toLowerCase().contains(needle))
            (tag: row.tag, depth: 0),
      ];
    }

    // Cada coincidencia arranca en la raíz y su rama cuelga de ella, con la
    // sangría contada **desde ella** y no desde el árbol entero.
    //
    // Sin llevar la cuenta de lo ya emitido, una hija que también encaja saldría
    // dos veces: una colgando de su madre y otra por su cuenta. Como las madres
    // van antes en el recorrido, la primera vez sale en su sitio.
    final emitted = <int>{};
    final rows = <TagRow>[];

    for (final row in all) {
      if (!row.tag.name.toLowerCase().contains(needle)) continue;
      if (emitted.contains(row.tag.id)) continue;

      for (final each in TagList.flatten([row.tag])) {
        if (!emitted.add(each.tag.id)) continue;
        rows.add(each);
      }
    }

    return rows;
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
              padding: const EdgeInsets.only(
                bottom: AppSpacing.s,
                right: AppSizes.scrollbarLane,
              ),
              child: FernSectionHeader(
                icon: widget.showsPeople ? Symbols.face : Symbols.label,
                title:
                    widget.showsPeople ? texts.peopleTitle : texts.tagsTitle,
                // A la altura del rótulo y encima del buscador: es el mismo sitio
                // en las dos listas, así que ir y volver es pulsar donde ya estaba
                // el dedo.
                trailing: widget.onSwitchList == null
                    ? null
                    : IconButton(
                        icon: Icon(
                          widget.showsPeople ? Symbols.label : Symbols.face,
                          size: AppSizes.iconMedium,
                        ),
                        tooltip: widget.showsPeople
                            ? texts.openTagsTooltip
                            : texts.openPeopleTooltip,
                        visualDensity: VisualDensity.compact,
                        onPressed: widget.onSwitchList,
                      ),
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
                  hasChildren: rows[index].tag.children.isNotEmpty,
                  isCollapsed: _collapsedIds.contains(rows[index].tag.id),
                  // Buscando no se pliega: lo que se está viendo es el
                  // resultado de una búsqueda, no el árbol, y plegar ahí
                  // escondería coincidencias.
                  onToggleCollapse: _collapsed == null || _query.isNotEmpty
                      ? null
                      : () => _collapsed.toggle(rows[index].tag.id),
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

  /// Si la etiqueta tiene hijas, y si están plegadas.
  ///
  /// Sin hijas no se pinta chevron: uno que no hace nada en la mitad de las
  /// filas es ruido, y además desalinearía los nombres. En su sitio va un hueco
  /// del mismo ancho, que es lo que mantiene la columna.
  final bool hasChildren;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const _TagTile({
    required this.row,
    required this.isSelected,
    required this.onTap,
    required this.isDraggable,
    required this.accepts,
    required this.onDropped,
    this.hasChildren = false,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  /// El chevron que pliega la rama, o el hueco que ocupa cuando no hay ninguna.
  Widget _chevron(BuildContext context) {
    if (!hasChildren || onToggleCollapse == null) {
      return const SizedBox(width: tagListChevronWidth);
    }

    final texts = AppLocalizations.of(context);

    return SizedBox(
      width: tagListChevronWidth,
      child: IconButton(
        tooltip: isCollapsed ? texts.tagExpandBranch : texts.tagCollapseBranch,
        iconSize: AppSizes.iconSmall,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: onToggleCollapse,
        icon: Icon(
          isCollapsed ? Symbols.chevron_right : Symbols.expand_more,
        ),
      ),
    );
  }

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
            // El chevron va delante del avatar: al final se pisaría con lo que
            // ya vive ahí en el menú —el distintivo NSFW y el contador— y las
            // dos listas tienen que plegarse con el mismo gesto en el mismo
            // sitio.
            _chevron(context),
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
