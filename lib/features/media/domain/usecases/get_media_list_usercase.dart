import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import '../../../../core/resources/data_state.dart';
import '../repositories/local_media_repository.dart';

/// Todo el contenido **definitivo** de la base de datos: el que ya se ha
/// revisado y guardado desde el visor. Es lo que se pinta en la pantalla de
/// media, frente a `GetScannedMediaUseCase`, que devuelve lo pendiente de
/// revisar de la pantalla de importación.
class GetMediaListUsercase extends UseCase<DataState<List<MediaSummaryEntity>>, void> {

  // Repository
  final LocalMediaRepository _localMediaRepository;

  GetMediaListUsercase({
    required this._localMediaRepository,
  });


  @override
  Future<DataState<List<MediaSummaryEntity>>> call({void params}) {
    return _localMediaRepository.getMediaList();
  }

}
