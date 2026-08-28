import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';

/// Coloca el árbol solo: en qué fila y en qué columna va cada nodo.
///
/// El usuario **conecta, no coloca**. Ordenar tarjetas a mano es el trabajo
/// aburrido de un editor de nodos, y con veinte modelos se convierte en el
/// motivo por el que nadie vuelve a tocar la pantalla.
///
/// Es puro y determinista: el mismo árbol da siempre la misma colocación. Si no,
/// las tarjetas bailarían de sitio en cada relectura y no habría forma de
/// seguirlas con la vista.
ModelTreeEntity layoutModelTree(ModelTreeEntity tree) {
  if (tree.nodes.isEmpty) return tree;

  final rows = _rowsOf(tree);
  final columns = _columnsOf(tree, rows);

  return ModelTreeEntity(
    nodes: [
      for (final node in tree.nodes)
        node.copyWith(
          row: rows[node.id] ?? 0,
          column: columns[node.id] ?? 0,
        ),
    ],
    edges: tree.edges,
  );
}

/// A qué profundidad va cada nodo.
///
/// La del **camino más largo** hasta él y no la del más corto: con un nodo que
/// cuelga de otro de la fila 1 y de otro de la fila 3, ponerlo en la 2 haría que
/// una de sus aristas subiera en vez de bajar, y un árbol donde algunas flechas
/// van hacia arriba deja de leerse como un árbol.
Map<int, int> _rowsOf(ModelTreeEntity tree) {
  final rows = <int, int>{for (final node in tree.nodes) node.id: 0};

  // Se repite hasta que nadie se mueve. Como mucho hacen falta tantas pasadas
  // como nodos hay —esa es la cadena más larga posible sin ciclos—, así que el
  // tope está ahí para que un grafo con un ciclo que se hubiera colado no deje
  // la pantalla dando vueltas.
  for (var pass = 0; pass <= tree.nodes.length; pass++) {
    var moved = false;

    for (final edge in tree.edges) {
      final parent = rows[edge.parentNodeId];
      final child = rows[edge.childNodeId];
      if (parent == null || child == null) continue;

      if (child <= parent) {
        rows[edge.childNodeId] = parent + 1;
        moved = true;
      }
    }

    if (!moved) break;
  }

  return rows;
}

/// Dónde va cada nodo a lo ancho de su fila.
///
/// Va en dos direcciones y varias veces porque **las dos reglas se
/// contradicen**: un hijo quiere estar debajo de sus padres y un padre quiere
/// estar centrado sobre sus hijos, y con un padre de dos hijos las dos no se
/// pueden cumplir a la vez. Alternar bajando y subiendo las acerca a un punto
/// donde ninguna se rompe mucho, que es lo mejor que se puede hacer sin
/// complicar esto diez veces más.
Map<int, double> _columnsOf(ModelTreeEntity tree, Map<int, int> rows) {
  final byRow = <int, List<ModelTreeNodeEntity>>{};

  for (final node in tree.nodes) {
    byRow.putIfAbsent(rows[node.id] ?? 0, () => []).add(node);
  }

  final depth =
      byRow.keys.isEmpty ? 0 : byRow.keys.reduce((a, b) => a > b ? a : b);

  final columns = <int, double>{};

  // De partida, cada fila en orden de identificador: es el orden en que se
  // metieron, que es el que el usuario recuerda. Y es lo que hace la colocación
  // repetible: sin un desempate fijo, dos nodos empatados se intercambiarían de
  // sitio entre lecturas.
  for (final entry in byRow.entries) {
    entry.value.sort((a, b) => a.id.compareTo(b.id));

    for (var index = 0; index < entry.value.length; index++) {
      columns[entry.value[index].id] = index.toDouble();
    }
  }

  // Primero el **orden** de cada fila, mirando a los padres. El orden es lo que
  // evita que las aristas se crucen; el sitio exacto viene después.
  for (var pass = 0; pass < layoutPasses; pass++) {
    for (var row = 1; row <= depth; row++) {
      _reorder(tree, byRow[row], columns);
    }
  }

  // Y ahora los sitios, alternando: bajando, cada hijo se pone debajo de sus
  // padres; subiendo, cada padre se centra sobre sus hijos.
  for (var pass = 0; pass < layoutPasses; pass++) {
    for (var row = 1; row <= depth; row++) {
      _align(tree, byRow[row], columns, downwards: true);
    }

    for (var row = depth - 1; row >= 0; row--) {
      _align(tree, byRow[row], columns, downwards: false);
    }

  }

  _normalise(columns);

  return columns;
}

/// Reordena una fila por dónde le llegan las flechas de arriba.
void _reorder(
  ModelTreeEntity tree,
  List<ModelTreeNodeEntity>? nodes,
  Map<int, double> columns,
) {
  if (nodes == null) return;

  nodes.sort((a, b) {
    final byParents = _barycenter(tree, a, columns, downwards: true)
        .compareTo(_barycenter(tree, b, columns, downwards: true));

    return byParents != 0 ? byParents : a.id.compareTo(b.id);
  });

  for (var index = 0; index < nodes.length; index++) {
    columns[nodes[index].id] = index.toDouble();
  }
}

/// Pone cada nodo de la fila donde le pide su gente, sin que se pisen.
void _align(
  ModelTreeEntity tree,
  List<ModelTreeNodeEntity>? nodes,
  Map<int, double> columns, {
  required bool downwards,
}) {
  if (nodes == null || nodes.isEmpty) return;

  // Donde le pide su gente a cada uno, antes de tocar nada.
  final desired = [
    for (final node in nodes)
      _barycenter(tree, node, columns, downwards: downwards),
  ];

  // Que no se solapen: cada uno al menos una columna a la derecha del anterior.
  // El orden ya está decidido, así que aquí sólo se separan.
  final wanted = [...desired];
  for (var index = 1; index < wanted.length; index++) {
    if (wanted[index] < wanted[index - 1] + 1) {
      wanted[index] = wanted[index - 1] + 1;
    }
  }

  // Separar empuja siempre hacia la derecha, así que la fila entera se corre. Se
  // devuelve al centro **que pedía**, no al que tenía: compensar contra el sitio
  // anterior cancelaría exactamente el movimiento que se acababa de calcular, y
  // los nodos no se moverían nunca.
  final shift = _mean(desired) - _mean(wanted);

  for (var index = 0; index < nodes.length; index++) {
    columns[nodes[index].id] = wanted[index] + shift;
  }
}

/// Dónde está la gente de un nodo, de media.
///
/// Bajando son sus padres y subiendo sus hijos. Sin nadie a quien mirar se queda
/// donde estaba: moverlo por un promedio de nada lo llevaría al principio de la
/// fila sin razón.
double _barycenter(
  ModelTreeEntity tree,
  ModelTreeNodeEntity node,
  Map<int, double> columns, {
  required bool downwards,
}) {
  final edges = downwards ? tree.edgesInto(node.id) : tree.edgesFrom(node.id);
  final positions = <double>[];

  for (final edge in edges) {
    final other =
        downwards ? columns[edge.parentNodeId] : columns[edge.childNodeId];

    if (other != null) positions.add(other);
  }

  return positions.isEmpty ? (columns[node.id] ?? 0) : _mean(positions);
}

double _mean(List<double> values) {
  if (values.isEmpty) return 0;

  var total = 0.0;
  for (final value in values) {
    total += value;
  }

  return total / values.length;
}

/// Deja la columna más a la izquierda en cero.
///
/// Los sitios salen de promedios y pueden acabar en negativo; el lienzo se
/// dibuja desde el origen, así que sin esto los de la izquierda se saldrían por
/// fuera del papel.
void _normalise(Map<int, double> columns) {
  if (columns.isEmpty) return;

  var min = double.infinity;
  for (final value in columns.values) {
    if (value < min) min = value;
  }

  for (final id in columns.keys.toList()) {
    columns[id] = columns[id]! - min;
  }
}

/// Cuántas veces se repasa la colocación.
///
/// Las dos reglas se contradicen, así que esto no converge a nada exacto:
/// repetir un par de veces acerca lo suficiente, y más pasadas no mejoran nada
/// apreciable a cambio de correr en cada relectura del árbol.
const layoutPasses = 2;
