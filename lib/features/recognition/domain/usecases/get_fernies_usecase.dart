import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Todos los fernies de la aplicación, cada uno con el recuento de regiones y de
/// contenidos distintos en los que están marcadas.
class GetFerniesUseCase extends UseCase<DataState<List<FernieEntity>>, void> {
  final FernieRepository _repository;

  GetFerniesUseCase(this._repository);

  @override
  Future<DataState<List<FernieEntity>>> call({void params}) {
    return _repository.getFernies();
  }
}
