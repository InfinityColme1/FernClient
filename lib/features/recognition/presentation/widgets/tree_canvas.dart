import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/presentation/widgets/tree_drag_payload.dart';
import 'package:Fern/features/recognition/presentation/widgets/tree_edge_painter.dart';
import 'package:Fern/features/recognition/presentation/widgets/tree_node_card.dart';
import 'package:flutter/material.dart';

/// Dónde cae cada nodo, en píxeles.
///
/// Sale de su fila y su columna y de lo que mide una tarjeta, sin medir nada:
/// las tarjetas son de tamaño fijo justamente para poder hacer esta cuenta antes
/// de pintar. Con tarjetas de alto variable habría que medirlas todas para poder
/// trazar una sola arista.
Offset treeNodeOffset(ModelTreeNodeEntity node) {
  return Offset(
    node.column * (AppSizes.treeNodeWidth + AppSizes.treeColumnGap),
    node.row * (AppSizes.treeNodeHeight + AppSizes.treeRowGap),
  );
}

/// Lo que ocupa el árbol entero.
Size treeCanvasSize(ModelTreeEntity tree) {
  var columns = 1.0;
  var rows = 1;

  for (final node in tree.nodes) {
    if (node.column + 1 > columns) columns = node.column + 1;
    if (node.row + 1 > rows) rows = node.row + 1;
  }

  return Size(
    columns * AppSizes.treeNodeWidth + (columns - 1) * AppSizes.treeColumnGap,
    rows * AppSizes.treeNodeHeight + (rows - 1) * AppSizes.treeRowGap,
  );
}

/// El árbol pintado: las tarjetas en su rejilla y las aristas por debajo.
///
/// Las aristas van **debajo** de las tarjetas a propósito: la línea entra por el
/// borde de arriba del hijo, y si se pintara encima cruzaría la tarjeta.
class TreeCanvas extends StatelessWidget {
  final ModelTreeEntity tree;
  final int? selectedNodeId;

  /// Cómo se llama la clase que dispara cada arista, por identificador de
  /// arista. Lo resuelve la pantalla, que es quien tiene los fernies.
  final Map<int, String> edgeLabels;

  /// El lienzo está tan alejado que las tarjetas se simplifican.
  final bool isSimplified;

  final ValueChanged<int>? onNodeTap;
  final ValueChanged<int>? onNodeRemove;
  final ValueChanged<int>? onEdgeTap;

  /// Se ha soltado algo encima de un nodo, que pasa a ser su padre.
  final void Function(TreeDragPayload payload, int parentNodeId)? onDropOnNode;

  const TreeCanvas({
    super.key,
    required this.tree,
    this.selectedNodeId,
    this.edgeLabels = const {},
    this.isSimplified = false,
    this.onNodeTap,
    this.onNodeRemove,
    this.onEdgeTap,
    this.onDropOnNode,
  });

  /// Si [payload] se puede soltar sobre [parentNodeId].
  ///
  /// Un modelo del panel siempre vale: es un nodo nuevo, y algo que todavía no
  /// está no puede cerrar un ciclo. Un nodo que ya está lo dice el propio árbol,
  /// que es quien sabe quién cuelga de quién.
  bool acceptsOnNode(TreeDragPayload payload, int parentNodeId) {
    return switch (payload) {
      TreeModelPayload() => true,
      TreeNodePayload(:final nodeId) => tree.canConnect(
          parentNodeId: parentNodeId,
          childNodeId: nodeId,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final size = treeCanvasSize(tree);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: TreeEdgePainter(
                edges: _lines(),
                color: context.colors.lightgray,
                highlightColor: context.colors.terciary,
                labelColor: context.colors.black,
                labelBackground: context.colors.white,
                labelStyle: Theme.of(context).textTheme.labelSmall ??
                    const TextStyle(),
              ),
            ),
          ),
          for (final node in tree.nodes)
            Positioned(
              left: treeNodeOffset(node).dx,
              top: treeNodeOffset(node).dy,
              child: _node(context, node),
            ),
          // Los tiradores para tocar una arista van encima de todo: una curva de
          // dos píxeles no se acierta con el ratón, así que cada una lleva su
          // propia zona pulsable en el punto donde está su etiqueta.
          if (onEdgeTap != null)
            for (final line in _lines())
              Positioned(
                left: (line.from.dx + line.to.dx) / 2 -
                    treeEdgeLabelMaxWidth / 2,
                top: (line.from.dy + line.to.dy) / 2 - AppSizes.iconLarge / 2,
                width: treeEdgeLabelMaxWidth,
                height: AppSizes.iconLarge,
                child: _EdgeHandle(onTap: () => onEdgeTap!(line.edgeId)),
              ),
        ],
      ),
    );
  }

  /// Una tarjeta: se arrastra y recoge lo que le suelten encima.
  ///
  /// Las dos cosas a la vez porque las dos son la misma idea puesta del derecho
  /// y del revés: llevar este nodo debajo de aquél, o traer aquél debajo de éste.
  Widget _node(BuildContext context, ModelTreeNodeEntity node) {
    final card = TreeNodeCard(
      node: node,
      isSelected: node.id == selectedNodeId,
      isSimplified: isSimplified,
      onTap: onNodeTap == null ? null : () => onNodeTap!(node.id),
      onRemove: onNodeRemove == null ? null : () => onNodeRemove!(node.id),
    );

    final target = onDropOnNode == null
        ? card
        : FernDropSlot<TreeDragPayload>(
            canAccept: (payload) => acceptsOnNode(payload, node.id),
            onAccept: (payload) => onDropOnNode!(payload, node.id),
            builder: (context, state) => card,
          );

    return FernDraggableCard<TreeDragPayload>(
      data: TreeNodePayload(node.id),
      isEnabled: onDropOnNode != null,
      // Lo que va pegado al cursor es la tarjeta a secas, sin la zona de soltar:
      // una tarjeta que se está arrastrando no puede recogerse a sí misma.
      feedback: card,
      child: target,
    );
  }

  List<TreeEdgeLine> _lines() {
    final lines = <TreeEdgeLine>[];

    for (final edge in tree.edges) {
      final parent = tree.nodeById(edge.parentNodeId);
      final child = tree.nodeById(edge.childNodeId);
      if (parent == null || child == null) continue;

      final from = treeNodeOffset(parent);
      final to = treeNodeOffset(child);

      lines.add(TreeEdgeLine(
        edgeId: edge.id,
        // Del centro del borde de abajo del padre al centro del de arriba del
        // hijo: es lo que hace que la flecha se lea como «de aquí a aquí».
        from: Offset(
          from.dx + AppSizes.treeNodeWidth / 2,
          from.dy + AppSizes.treeNodeHeight,
        ),
        to: Offset(to.dx + AppSizes.treeNodeWidth / 2, to.dy),
        label: edgeLabels[edge.id],
        isHighlighted: edge.parentNodeId == selectedNodeId ||
            edge.childNodeId == selectedNodeId,
      ));
    }

    return lines;
  }
}

/// La zona pulsable de una arista.
class _EdgeHandle extends StatelessWidget {
  final VoidCallback onTap;

  const _EdgeHandle({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        // Transparente y no nada: sin color no recibe el toque.
        child: const ColoredBox(color: Colors.transparent),
      ),
    );
  }
}
