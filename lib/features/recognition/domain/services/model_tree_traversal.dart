import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:equatable/equatable.dart';

/// Lo que un modelo dice haber visto en un contenido.
///
/// El fernie y la confianza, que es lo que hace falta para decidir si una rama
/// se abre. Dónde estaba la caja es cosa de la fase 5: aquí sólo se decide qué
/// se ejecuta.
class TreeDetection extends Equatable {
  final int fernieId;
  final double confidence;

  const TreeDetection({required this.fernieId, required this.confidence});

  @override
  List<Object?> get props => [fernieId, confidence];
}

/// Qué contesta un nodo cuando le toca.
///
/// Va por parámetro porque predecir es cosa del motor, y el recorrido tiene que
/// poder probarse sin levantar Python ni abrir un fichero.
typedef NodePredictor = Future<List<TreeDetection>> Function(
  ModelTreeNodeEntity node,
);

/// Cómo fue el recorrido de un contenido por el árbol.
class TreeRun extends Equatable {
  /// Todo lo detectado, en el orden en que se fue detectando.
  final List<TreeDetection> detections;

  /// Los nodos que llegaron a ejecutarse, por orden.
  final List<int> executed;

  /// Los que se saltaron por no estar entrenados.
  ///
  /// No es un fallo del reconocimiento: se sigue con lo demás y se cuenta. Un
  /// modelo a medias no puede dejar sin reconocer todo lo que cuelga de otras
  /// ramas.
  final List<int> skipped;

  const TreeRun({
    this.detections = const [],
    this.executed = const [],
    this.skipped = const [],
  });

  @override
  List<Object?> get props => [detections, executed, skipped];
}

/// Recorre el árbol reconociendo, podando lo que no toca.
///
/// Reconocer con todos los modelos siempre es caro y ruidoso. El árbol encadena:
/// un modelo general filtra y, sólo si detecta algo concreto, se ejecutan los
/// especializados que cuelgan de esa detección. **La poda es el sentido del
/// árbol**: una rama cuyo padre no disparó no se ejecuta.
///
/// Va por niveles y no en profundidad para poder lotear las predicciones de un
/// mismo nivel, que es lo que hará la fase 5 cuando esto se use de verdad.
///
/// Es puro: no sabe de Isar, ni de pantallas, ni del motor. Se le dice qué
/// contesta cada nodo y él decide a quién le toca después.
Future<TreeRun> runModelTree({
  required ModelTreeEntity tree,
  required NodePredictor predict,
}) async {
  final detections = <TreeDetection>[];
  final executed = <int>[];
  final skipped = <int>[];

  // Lo ya visto, para que un nodo con dos padres se ejecute una sola vez. Se
  // apunta al encolarlo y no al ejecutarlo: si no, el segundo padre lo mete otra
  // vez en la cola antes de que el primero haya terminado.
  final seen = <int>{for (final root in tree.roots) root.id};
  var level = tree.roots.toList();

  while (level.isNotEmpty) {
    final next = <ModelTreeNodeEntity>[];

    for (final node in level) {
      if (!node.isRunnable) {
        // Se salta y se cuenta. Lo que cuelga de él tampoco se ejecuta: no hay
        // detección que pueda abrir esas ramas, y abrirlas «por si acaso» sería
        // ejecutar los especializados sin el filtro que los justifica.
        skipped.add(node.id);
        continue;
      }

      final found = await predict(node);

      executed.add(node.id);
      detections.addAll(found);

      for (final edge in tree.edgesFrom(node.id)) {
        if (!_opens(edge, found, node)) continue;

        final child = tree.nodeById(edge.childNodeId);
        if (child == null || !seen.add(child.id)) continue;

        next.add(child);
      }
    }

    level = next;
  }

  return TreeRun(
    detections: detections,
    executed: executed,
    skipped: skipped,
  );
}

/// Si lo que ha visto el padre abre esta rama.
///
/// Sin condición basta con que haya detectado **algo**; con condición hace falta
/// esa clase concreta y por encima del listón del padre. El listón es el del
/// padre y no el del hijo: la decisión es «¿el padre está seguro de lo que ha
/// visto?», y el hijo todavía no ha opinado.
bool _opens(
  ModelTreeEdgeEntity edge,
  List<TreeDetection> found,
  ModelTreeNodeEntity parent,
) {
  final threshold = parent.model.confidenceThreshold;
  final condition = edge.conditionFernieId;

  if (condition == null) {
    return found.any((detection) => detection.confidence >= threshold);
  }

  return found.any((detection) =>
      detection.fernieId == condition && detection.confidence >= threshold);
}
