import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';

import '../../../../core/resources/data_state.dart';
import '../repositories/local_media_repository.dart';


class GetMediaDetailsUsecase extends UseCase<DataState<MediaEntity>, int>{
  final LocalMediaRepository _localMediaRepository;

  GetMediaDetailsUsecase({required this._localMediaRepository});

  @override
  Future<DataState<MediaEntity>> call({int? params}) {
    return _localMediaRepository.getMediaDetails(params!);
  }

}