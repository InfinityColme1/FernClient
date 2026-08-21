import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Una arista ya resuelta a píxeles: de dónde sale y a dónde llega.
class TreeEdgeLine {
  final int edgeId;

  /// El borde de abajo del padre y el de arriba del hijo.
  final Offset from;
  final Offset to;

  /// La clase que la dispara, ya en palabras. `null` es «cualquier detección».
  final String? label;

  /// Resaltada: es la que tiene el cursor encima o la que se acaba de tocar.
  final bool isHighlighted;

  const TreeEdgeLine({
    required this.edgeId,
    required this.from,
    required this.to,
    this.label,
    this.isHighlighted = false,
  });
}

/// Dibuja las aristas del árbol y sus etiquetas.
///
/// Se pintan en vez de dejar que se entiendan por cercanía porque un nodo puede
/// tener **varios padres**: sin la línea no hay forma de saber de cuál cuelga, y
/// con dos padres en filas distintas la simple adyacencia no dice nada.
///
/// La curva es una Bézier con los tiradores en vertical: sale del padre hacia
/// abajo y entra al hijo desde arriba, así que aunque el hijo esté muy a un lado
/// la línea nunca parece que llegue de costado.
class TreeEdgePainter extends CustomPainter {
  final List<TreeEdgeLine> edges;
  final Color color;
  final Color highlightColor;
  final Color labelColor;
  final Color labelBackground;
  final TextStyle labelStyle;

  const TreeEdgePainter({
    required this.edges,
    required this.color,
    required this.highlightColor,
    required this.labelColor,
    required this.labelBackground,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final edge in edges) {
      _paintLine(canvas, edge);
      _paintLabel(canvas, edge);
    }
  }

  void _paintLine(Canvas canvas, TreeEdgeLine edge) {
    final paint = Paint()
      ..color = edge.isHighlighted ? highlightColor : color
      ..strokeWidth = edge.isHighlighted ? treeEdgeWidth * 2 : treeEdgeWidth
      ..style = PaintingStyle.stroke;

    // Los tiradores a media altura entre los dos: es lo que da la curva en «S»
    // que se lee de un vistazo como «de aquí sale y aquí llega».
    final middle = (edge.to.dy - edge.from.dy) / 2;

    final path = Path()
      ..moveTo(edge.from.dx, edge.from.dy)
      ..cubicTo(
        edge.from.dx,
        edge.from.dy + middle,
        edge.to.dx,
        edge.to.dy - middle,
        edge.to.dx,
        edge.to.dy,
      );

    canvas.drawPath(path, paint);

    // La punta de flecha, para que se sepa quién dispara a quién. Sin ella, dos
    // nodos unidos por una línea no dicen en qué orden se ejecutan.
    final head = Path()
      ..moveTo(edge.to.dx, edge.to.dy)
      ..lineTo(edge.to.dx - treeArrowSize / 2, edge.to.dy - treeArrowSize)
      ..lineTo(edge.to.dx + treeArrowSize / 2, edge.to.dy - treeArrowSize)
      ..close();

    canvas.drawPath(head, Paint()..color = paint.color);
  }

  void _paintLabel(Canvas canvas, TreeEdgeLine edge) {
    final label = edge.label;
    if (label == null || label.isEmpty) return;

    final painter = TextPainter(
      text: TextSpan(text: label, style: labelStyle.copyWith(color: labelColor)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: treeEdgeLabelMaxWidth);

    // En medio de la curva, que es donde no tapa a ninguna de las dos tarjetas.
    final center = Offset(
      (edge.from.dx + edge.to.dx) / 2,
      (edge.from.dy + edge.to.dy) / 2,
    );

    final box = Rect.fromCenter(
      center: center,
      width: painter.width + AppSizes.treeLabelPadding * 2,
      height: painter.height + AppSizes.treeLabelPadding,
    );

    // Con su fondo: la etiqueta cae justo encima de la línea, y sin nada detrás
    // el trazo la cruza por la mitad y no se lee.
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(AppSizes.radiusFull)),
      Paint()..color = labelBackground,
    );

    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(TreeEdgePainter old) =>
      old.edges != edges || old.color != color;
}
