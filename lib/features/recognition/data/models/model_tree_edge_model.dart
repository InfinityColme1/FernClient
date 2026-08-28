import 'package:isar/isar.dart';

part 'model_tree_edge_model.g.dart';

/// Qué dispara a qué, y con qué condición.
///
/// Los dos extremos van por identificador y no por enlace: el recorrido pregunta
/// «¿qué cuelga de este nodo?» una vez por nodo y por contenido reconocido, y con
/// enlaces habría que cargar la arista entera para leer un número.
@collection
@Name("ModelTreeEdges")
class ModelTreeEdgeModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int parentNodeId;

  @Index()
  late int childNodeId;

  /// El fernie del padre que dispara al hijo.
  ///
  /// `null` es «cualquier cosa que detecte el padre», que es el respaldo de una
  /// arista recién creada: sirve para algo, pero es lo que hay que afinar. Sin
  /// condición, todos los modelos especializados se ejecutarían ante cualquier
  /// detección, que es el triple de trabajo para nada.
  int? conditionFernieId;

  ModelTreeEdgeModel();
}
