import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Contenido marcado para borrar: el de la pantalla de eliminados.
class GetDeletedMediaUseCase extends UseCase<DataState<List<MediaSummaryEntity>>, void> {
  final LocalMediaRepository _localMediaRepository;

  GetDeletedMediaUseCase({required LocalMediaRepository localMediaRepository})
      : _localMediaRepository = localMediaRepository;

  @override
  Future<DataState<List<MediaSummaryEntity>>> call({void params}) {
    return _localMediaRepository.getDeletedMedia();
  }
}
