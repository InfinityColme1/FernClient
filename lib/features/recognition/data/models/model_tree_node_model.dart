import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:isar/isar.dart';

part 'model_tree_node_model.g.dart';

/// Un modelo colocado en el árbol.
///
/// El nodo y el modelo son cosas distintas: el modelo existe aunque no esté en
/// el árbol —y entonces no se ejecuta nunca al reconocer—, y el nodo es el sitio
/// que ocupa.
///
/// **No se guarda si es raíz.** El documento lo proponía como columna, pero una
/// marca así se desincroniza en cuanto alguien borra una arista sin acordarse de
/// tocarla, y entonces un nodo deja de ejecutarse sin que nada lo explique. Ser
/// raíz es no tener aristas entrantes, y eso ya está escrito en las aristas.
@collection
@Name("ModelTreeNodes")
class ModelTreeNodeModel {
  Id id = Isar.autoIncrement;

  /// El modelo al que representa.
  ///
  /// Indexado por su identificador aparte del enlace: buscar «¿está este modelo
  /// en el árbol?» pasa cada vez que se pinta la lista de modelos, y con el
  /// enlace a secas habría que cargarlos todos para mirarlo.
  @Index(unique: true, replace: true)
  late int modelId;

  final model = IsarLink<RecognitionModelModel>();

  /// Dónde se pinta: la fila es la profundidad y la columna el orden dentro de
  /// ella. Es sólo dibujo; quién ejecuta a quién lo dicen las aristas.
  late int row;
  late int column;

  ModelTreeNodeModel();
}
