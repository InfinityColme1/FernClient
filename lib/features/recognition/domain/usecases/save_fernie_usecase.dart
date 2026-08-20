import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Da de alta un fernie y devuelve el que ha quedado en la base de datos, ya con
/// su identificador definitivo.
class SaveFernieUseCase extends UseCase<DataState<FernieEntity>, FernieEntity> {
  final FernieRepository _repository;

  SaveFernieUseCase(this._repository);

  @override
  Future<DataState<FernieEntity>> call({FernieEntity? params}) {
    return _repository.saveFernie(params!);
  }
}
