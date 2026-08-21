import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';

/// El árbol que decide en qué orden y bajo qué condición se ejecutan los
/// modelos al reconocer.
///
/// Hay **uno solo** por instalación: no hay varios árboles ni perfiles, que
/// nadie los ha pedido y multiplicarían el estado sin dar nada.
abstract class ModelTreeRepository {
  /// El árbol entero, con sus modelos ya resueltos.
  ///
  /// Entero y de una vez porque es pequeño —son los modelos que uno tiene— y
  /// porque tanto pintarlo como recorrerlo lo necesitan completo: pedirlo por
  /// trozos sólo daría estados a medias.
  Future<DataState<ModelTreeEntity>> getTree();

  /// Mete un modelo en el árbol, en su sitio.
  ///
  /// Uno que ya esté dentro no se mete otra vez: repetirlo no aporta nada y
  /// complica la ejecución. En ese caso devuelve el nodo que ya había.
  Future<DataState<ModelTreeNodeEntity>> addModel({
    required int modelId,
    int row = 0,
    int column = 0,
  });

  /// Saca un nodo del árbol.
  ///
  /// Con él se van sus aristas, y los hijos que se queden sin padres pasan a ser
  /// raíces: se ejecutan siempre, que es lo que le pasa a cualquiera que no
  /// cuelgue de nadie. **El modelo no se borra**: sigue existiendo, sólo que
  /// fuera del árbol y por tanto sin ejecutarse nunca.
  Future<DataState<bool>> removeNode(int nodeId);

  /// Cambia dónde se pinta un nodo. No toca a quién ejecuta.
  Future<DataState<bool>> moveNode({
    required int nodeId,
    required int row,
    required int column,
  });

  /// Cuelga un nodo de otro.
  ///
  /// Falla si con eso el árbol se mordería la cola: un ciclo no da un error, da
  /// un recorrido que no termina, y desde fuera eso parece que la aplicación se
  /// ha colgado.
  Future<DataState<ModelTreeEdgeEntity>> connect({
    required int parentNodeId,
    required int childNodeId,
    int? conditionFernieId,
  });

  Future<DataState<bool>> disconnect(int edgeId);

  /// Cambia de quién cuelga un nodo: le quita los padres que tuviera y lo cuelga
  /// de [parentNodeId].
  ///
  /// Es una sola operación y no «quitar y luego poner» porque **se comprueba
  /// antes de tocar nada**: si el nuevo padre no vale, el nodo tiene que quedarse
  /// como estaba. Hecho en dos pasos, un fallo a mitad lo dejaría suelto —y un
  /// nodo suelto se ejecuta siempre, que es justo lo contrario de lo que se
  /// pedía.
  Future<DataState<ModelTreeEdgeEntity>> reparent({
    required int parentNodeId,
    required int childNodeId,
  });

  /// Suelta un nodo de todos sus padres.
  ///
  /// Pasa a ser raíz, que es ejecutarse siempre. No lo saca del árbol.
  Future<DataState<bool>> promoteToRoot(int nodeId);

  /// Cambia con qué clase del padre se dispara el hijo.
  ///
  /// Con `null` vuelve a «cualquier cosa que detecte el padre».
  Future<DataState<ModelTreeEdgeEntity>> setEdgeCondition({
    required int edgeId,
    required int? conditionFernieId,
  });
}
