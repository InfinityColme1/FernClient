import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/repositories/model_tree_repository.dart';

/// Si se puede reconocer algo ahora mismo, y si no, por qué.
///
/// Las tres respuestas se parecen desde fuera —no sale ninguna sugerencia— y
/// hacen falta cosas distintas para arreglarlas: meter un modelo en el árbol,
/// entrenarlo, o nada porque todo está bien y el modelo simplemente no ha visto
/// nada. Sin separarlas, reconocer un contenido y que no pase nada es
/// indistinguible de que la función esté rota.
enum RecognitionReadiness {
  /// Hay al menos un modelo entrenado en el árbol.
  ready,

  /// El árbol está vacío: no hay ningún modelo puesto.
  noModelsInTree,

  /// Hay modelos en el árbol, pero ninguno tiene pesos con los que reconocer.
  noTrainedModels,

  /// No se ha podido leer el árbol.
  unknown,
}

/// Mira si el árbol de modelos da para reconocer algo.
///
/// Es una lectura y ya: no reconoce nada. Se pregunta **antes** de encolar
/// porque un trabajo que no tiene con qué trabajar termina en milisegundos y sin
/// dejar rastro —ni aparece en la lista de tareas, porque ya ha acabado—, y el
/// usuario se queda mirando una pantalla que no ha cambiado.
class CanRecognizeUseCase extends UseCase<RecognitionReadiness, void> {
  final ModelTreeRepository _tree;

  CanRecognizeUseCase(this._tree);

  @override
  Future<RecognitionReadiness> call({void params}) async {
    final tree = await _tree.getTree();

    if (tree is! DataSuccess || tree.data == null) {
      return RecognitionReadiness.unknown;
    }

    final nodes = tree.data!.nodes;

    if (nodes.isEmpty) return RecognitionReadiness.noModelsInTree;

    // Basta uno: los que no estén entrenados se saltan sin parar a los demás.
    return nodes.any((node) => node.isRunnable)
        ? RecognitionReadiness.ready
        : RecognitionReadiness.noTrainedModels;
  }
}
