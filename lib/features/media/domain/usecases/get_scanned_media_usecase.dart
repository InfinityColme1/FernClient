import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Contenido pendiente de revisar de la fuente elegida en la pantalla de
/// importación. Sin fuente, el de todas.
class GetScannedMediaUseCase
    extends UseCase<DataState<List<MediaSummaryEntity>>, ImportSource> {
  final LocalMediaRepository _localMediaRepository;

  GetScannedMediaUseCase({required this._localMediaRepository});

  @override
  Future<DataState<List<MediaSummaryEntity>>> call({ImportSource? params}) {
    return _localMediaRepository.getScannedMedia(
      source: params ?? ImportSource.all,
    );
  }
}
