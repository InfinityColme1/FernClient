import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Contenido definitivo de un creador, por su identificador.
class GetMediaByCreatorUseCase
    extends UseCase<DataState<List<MediaSummaryEntity>>, int> {
  final LocalMediaRepository _repository;

  GetMediaByCreatorUseCase(this._repository);

  @override
  Future<DataState<List<MediaSummaryEntity>>> call({int? params}) {
    return _repository.getMediaByCreator(params!);
  }
}
