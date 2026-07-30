import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

class DeleteMediaUseCase extends UseCase<DataState, int> {
  final LocalMediaRepository _repository;

  DeleteMediaUseCase(this._repository);

  @override
  Future<DataState> call({int? params}) {
    return _repository.deleteMedia(params!);
  }
}
