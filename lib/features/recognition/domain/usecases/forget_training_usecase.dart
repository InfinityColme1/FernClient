import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/data/services/model_files.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';

/// Deja un modelo como si no se hubiera entrenado nunca.
///
/// Para qué: un modelo entrenado con lo que no era —las regiones equivocadas,
/// un reparto mal hecho— se queda con unos pesos que reconocen mal y una ficha
/// que dice que está listo. Borrarlo entero y volver a crearlo era la única
/// salida, y con eso se perdían también los hiperparámetros, los fernies y el
/// reparto, que no tenían nada de malo.
///
/// Se lleva **la base de datos y los ficheros**: unos pesos de cien megas que ya
/// no apunta nadie no se distinguen de la basura, y la limpieza de Ajustes se
/// los llevaría igual más tarde sin que nadie lo hubiera pedido.
///
/// El modelo queda `untrained`, que es un estado ya contemplado: si estaba en el
/// árbol de reconocimiento, sigue estando y simplemente no se ejecuta.
class ForgetTrainingUseCase
    extends UseCase<DataState<RecognitionModelEntity>, RecognitionModelEntity> {
  final ModelRepository _models;
  final ModelFiles _files;

  ForgetTrainingUseCase({
    required ModelRepository models,
    required ModelFiles files,
  })  : _models = models,
        _files = files;

  @override
  Future<DataState<RecognitionModelEntity>> call({
    RecognitionModelEntity? params,
  }) async {
    final model = params;
    if (model == null) {
      return DataException(Exception('No hay modelo que olvidar'));
    }

    // Los ficheros **antes** de vaciar la fila: la ruta de los pesos sale de
    // ella, y después de vaciarla ya no habría por dónde encontrarlos.
    await _files.discard(model);

    return _models.forgetTraining(model.id);
  }
}
