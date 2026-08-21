/// Lo que viaja mientras se arrastra algo en la pantalla del árbol.
///
/// Dos cosas distintas se arrastran y acaban en los mismos sitios: un **modelo**
/// del panel, que todavía no está en el árbol, y un **nodo** que ya está. Lo que
/// pasa al soltarlos no es lo mismo —uno se mete, el otro se muda—, así que la
/// zona que los recoge tiene que poder distinguirlos.
sealed class TreeDragPayload {
  const TreeDragPayload();
}

/// Un modelo del panel lateral, todavía fuera del árbol.
class TreeModelPayload extends TreeDragPayload {
  final int modelId;
  final String name;

  const TreeModelPayload({required this.modelId, required this.name});
}

/// Un nodo que ya está en el árbol.
class TreeNodePayload extends TreeDragPayload {
  final int nodeId;

  const TreeNodePayload(this.nodeId);
}
