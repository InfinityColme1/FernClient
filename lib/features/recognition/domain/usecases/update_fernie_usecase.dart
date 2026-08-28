import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Cambia nombre, avatar y enlace de un fernie. Sus regiones no se tocan: el
/// identificador es el mismo y siguen colgando de él.
class UpdateFernieUseCase
    extends UseCase<DataState<FernieEntity>, FernieEntity> {
  final FernieRepository _repository;

  UpdateFernieUseCase(this._repository);

  @override
  Future<DataState<FernieEntity>> call({FernieEntity? params}) {
    return _repository.updateFernie(params!);
  }
}
