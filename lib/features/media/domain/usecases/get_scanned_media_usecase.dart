import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/media_sort_order.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// De qué fuente se lee lo pendiente de revisar, y en qué orden.
typedef ScannedMediaParams = ({ImportSource source, MediaSortOrder order});

/// Contenido pendiente de revisar de la fuente elegida en la pantalla de
/// importación. Sin fuente, el de todas.
class GetScannedMediaUseCase
    extends UseCase<DataState<List<MediaSummaryEntity>>, ScannedMediaParams> {
  final LocalMediaRepository _localMediaRepository;

  GetScannedMediaUseCase({required this._localMediaRepository});

  @override
  Future<DataState<List<MediaSummaryEntity>>> call({
    ScannedMediaParams? params,
  }) {
    return _localMediaRepository.getScannedMedia(
      source: params?.source ?? ImportSource.all,
      order: params?.order ?? MediaSortOrder.newestFirst,
    );
  }
}
