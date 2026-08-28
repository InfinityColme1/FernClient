import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Un fernie concreto, con sus recuentos ya resueltos.
class GetFernieUseCase extends UseCase<DataState<FernieEntity>, int> {
  final FernieRepository _repository;

  GetFernieUseCase(this._repository);

  @override
  Future<DataState<FernieEntity>> call({int? params}) {
    return _repository.getFernie(params!);
  }
}
