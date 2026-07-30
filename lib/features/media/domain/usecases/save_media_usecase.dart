import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

class SaveMediaUseCase extends UseCase<DataState, MediaEntity> {
  final LocalMediaRepository _repository;

  SaveMediaUseCase(this._repository);

  @override
  Future<DataState> call({MediaEntity? params}) {
    return _repository.saveMedia(params!);
  }
}
