import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/settings/data/services/recognition_storage_service.dart';

/// De dónde a dónde se lleva la carpeta de reconocimiento.
class MigrateRecognitionDataParams {
  final String targetDirectory;
  final String previousDirectory;

  const MigrateRecognitionDataParams({
    required this.targetDirectory,
    required this.previousDirectory,
  });
}

/// Cambia de sitio todo lo del reconocimiento y dice cuántos ficheros ha
/// movido.
///
/// A diferencia de la biblioteca, aquí no hay decisión que tomar: la aplicación
/// carga los modelos de esta carpeta, así que dejarlos atrás sería quedarse sin
/// ellos. Se mueve en el momento, como los avatares.
class MigrateRecognitionDataUseCase
    extends UseCase<DataState<int>, MigrateRecognitionDataParams> {
  final RecognitionStorageService _storage;

  MigrateRecognitionDataUseCase(this._storage);

  @override
  Future<DataState<int>> call({MigrateRecognitionDataParams? params}) async {
    if (params == null) return const DataSuccess(0);

    try {
      final moved = await _storage.relocate(
        targetDirectory: params.targetDirectory,
        previousDirectory: params.previousDirectory,
      );

      return DataSuccess(moved);
    } on Exception catch (error) {
      return DataException(error);
    }
  }
}
