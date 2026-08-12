import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Contenido definitivo que tiene una etiqueta, por su identificador.
class GetMediaByTagUseCase
    extends UseCase<DataState<List<MediaSummaryEntity>>, int> {
  final LocalMediaRepository _repository;

  GetMediaByTagUseCase(this._repository);

  @override
  Future<DataState<List<MediaSummaryEntity>>> call({int? params}) {
    return _repository.getMediaByTag(params!);
  }
}
