import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Da por definitivos varios contenidos escaneados a la vez, con los datos que
/// tengan en ese momento.
class ConfirmMediaListUseCase extends UseCase<DataState, List<int>> {
  final LocalMediaRepository _repository;

  ConfirmMediaListUseCase(this._repository);

  @override
  Future<DataState> call({List<int>? params}) {
    return _repository.confirmMediaList(params ?? const []);
  }
}
