import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Contenido marcado como favorito: el de la pantalla de favoritos.
class GetFavoriteMediaUseCase extends UseCase<DataState<List<MediaSummaryEntity>>, void> {
  final LocalMediaRepository _localMediaRepository;

  GetFavoriteMediaUseCase({required LocalMediaRepository localMediaRepository})
      : _localMediaRepository = localMediaRepository;

  @override
  Future<DataState<List<MediaSummaryEntity>>> call({void params}) {
    return _localMediaRepository.getFavoriteMedia();
  }
}
