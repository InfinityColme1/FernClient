import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Borra un fernie y, con el, todas sus regiones. El contenido sobre el que
/// estaban marcadas no se toca.
class DeleteFernieUseCase extends UseCase<DataState<bool>, int> {
  final FernieRepository _repository;

  DeleteFernieUseCase(this._repository);

  @override
  Future<DataState<bool>> call({int? params}) {
    return _repository.deleteFernie(params!);
  }
}
