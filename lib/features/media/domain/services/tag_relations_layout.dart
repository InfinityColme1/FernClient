import 'package:flutter/foundation.dart';

/// Qué sitio ocupa una etiqueta en el árbol de relaciones.
///
/// La columna es relativa a la etiqueta que se está editando, que siempre está
/// en la cero: negativas a su izquierda, positivas a su derecha. La fila es cero
/// para ella y sus hermanas, y `-1` para su madre.
///
/// Se guarda en columnas y filas y no en píxeles porque quien lo pinta ya sabe
/// lo que mide una tarjeta, y porque así esto se puede comprobar sin montar una
/// sola.
@immutable
class TagRelationSlot {
  final int tagId;
  final int column;
  final int row;

  const TagRelationSlot({
    required this.tagId,
    required this.column,
    required this.row,
  });

  @override
  bool operator ==(Object other) =>
      other is TagRelationSlot &&
      other.tagId == tagId &&
      other.column == column &&
      other.row == row;

  @override
  int get hashCode => Object.hash(tagId, column, row);

  @override
  String toString() => 'TagRelationSlot($tagId, c=$column, r=$row)';
}

/// La fila de la madre. Encima de la etiqueta, como en cualquier jerarquía.
const parentRow = -1;

/// La fila de la etiqueta y de sus hermanas.
///
/// La **misma** para las dos, y eso es lo que cuenta lo que son: una hermana no
/// cuelga de nadie. Ponerlas más abajo las haría parecer hijas, que es
/// exactamente la confusión que este árbol tiene que evitar.
const selfRow = 0;

/// Dónde va cada etiqueta del árbol de relaciones.
///
/// Las hermanas se reparten a los dos lados alternando, empezando por la
/// derecha: con todas a un lado el árbol crece hacia allá y la etiqueta que se
/// está editando deja de estar donde se la busca, que es en el centro.
List<TagRelationSlot> tagRelationsLayout({
  required int tagId,
  int? parentId,
  List<int> siblingIds = const [],
}) {
  final slots = <TagRelationSlot>[
    TagRelationSlot(tagId: tagId, column: 0, row: selfRow),
  ];

  if (parentId != null) {
    slots.add(TagRelationSlot(tagId: parentId, column: 0, row: parentRow));
  }

  for (var index = 0; index < siblingIds.length; index++) {
    // 0 → +1, 1 → −1, 2 → +2, 3 → −2…
    final step = index ~/ 2 + 1;
    final column = index.isEven ? step : -step;

    slots.add(
      TagRelationSlot(tagId: siblingIds[index], column: column, row: selfRow),
    );
  }

  return slots;
}

/// Cuántas columnas ocupa el árbol y por cuál empieza.
///
/// Lo necesita quien pinta: las columnas de las hermanas son negativas, y para
/// colocarlas en un lienzo hay que saber cuánto hay que correrlo todo a la
/// derecha para que la de más a la izquierda caiga en cero.
({int first, int count}) tagRelationsColumns(List<TagRelationSlot> slots) {
  if (slots.isEmpty) return (first: 0, count: 0);

  var first = slots.first.column;
  var last = slots.first.column;

  for (final slot in slots) {
    if (slot.column < first) first = slot.column;
    if (slot.column > last) last = slot.column;
  }

  return (first: first, count: last - first + 1);
}
