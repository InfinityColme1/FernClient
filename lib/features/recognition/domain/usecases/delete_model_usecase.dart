import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/data/services/model_files.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';
import 'package:flutter/foundation.dart';

/// Borra un modelo: su fila, sus pesos y lo que dejó escrito en disco.
///
/// **Sus fernies no.** Son suyos, no del modelo, y siguen valiendo para otros;
/// lo mismo con los contenidos y las regiones que hay detrás. Lo único que
/// desaparece es lo que este modelo escribió.
///
/// El orden importa: primero se lee el modelo —después de borrarlo ya no hay
/// forma de saber dónde estaban sus ficheros—, luego se borra de la base de
/// datos, y sólo entonces se limpia el disco. Al revés, un borrado que fallara a
/// medias dejaría un modelo en la lista apuntando a unos pesos que ya no están.
class DeleteModelUseCase extends UseCase<DataState<bool>, int> {
  final ModelRepository _repository;
  final ModelFiles _files;

  DeleteModelUseCase(this._repository, this._files);

  @override
  Future<DataState<bool>> call({int? params}) async {
    final id = params!;

    // Se lee antes de borrar: la ruta de los pesos y la de la run viven en la
    // fila que está a punto de desaparecer.
    final current = await _repository.getModel(id);
    final model = current is DataSuccess ? current.data : null;

    final deleted = await _repository.deleteModel(id);
    if (deleted is! DataSuccess) return deleted;

    // Que no se pueda borrar un fichero no deshace el borrado del modelo: eso ya
    // está hecho, y lo que quede en disco es basura, no un fallo del usuario.
    // La limpieza ya aguanta lo suyo por dentro; esto es para lo que no previó.
    if (model != null) {
      try {
        await _files.discard(model);
      } on Object catch (error) {
        debugPrint('No se pudo limpiar el disco del modelo $id: $error');
      }
    }

    return deleted;
  }
}
