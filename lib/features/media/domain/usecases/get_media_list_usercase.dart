import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import '../../../../core/resources/data_state.dart';
import '../repositories/local_media_repository.dart';

class GetMediaParams {
  GetMediaParams();
}


class GetMediaListUsercase extends UseCase<DataState<List<MediaSummaryEntity>>, GetMediaParams> {

  // Repository
  final LocalMediaRepository _localMediaRepository;

  GetMediaListUsercase({
    required this._localMediaRepository,
  });


  @override
  Future<DataState<List<MediaSummaryEntity>>> call({GetMediaParams? params}) {
    // TODO: implement call
    throw UnimplementedError();
  }


}