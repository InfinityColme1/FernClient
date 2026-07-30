import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

import '../entities/media/media_entity.dart';


class SaveScannedMediaUsecase extends UseCase<DataState, List<MediaEntity>>{

  final LocalMediaRepository _localMediaRepository;

  SaveScannedMediaUsecase({required this._localMediaRepository});

  @override
  Future<DataState<dynamic>> call({List<MediaEntity>? params}) {
    return _localMediaRepository.saveScannedMedia(params ?? []);
  }



}