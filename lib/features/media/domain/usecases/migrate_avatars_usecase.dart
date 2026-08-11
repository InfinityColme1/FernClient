import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

class MigrateAvatarsParams {
  final String targetDirectory;

  /// Carpeta en la que estaban los avatares hasta ahora, si la había: lo que
  /// venga de ahí se mueve y lo demás se copia.
  final String? previousDirectory;

  const MigrateAvatarsParams({
    required this.targetDirectory,
    this.previousDirectory,
  });
}

/// Lleva las imágenes de los avatares a la carpeta elegida y deja la base de
/// datos apuntando a las nuevas rutas. Devuelve cuántas se han reubicado.
class MigrateAvatarsUseCase
    extends UseCase<DataState<int>, MigrateAvatarsParams> {
  final LocalMediaRepository _repository;

  MigrateAvatarsUseCase(this._repository);

  @override
  Future<DataState<int>> call({MigrateAvatarsParams? params}) {
    return _repository.migrateAvatars(
      targetDirectory: params!.targetDirectory,
      previousDirectory: params.previousDirectory,
    );
  }
}
