import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_media_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Las regiones de un fernie con el contenido de cada una, para la rejilla de la
/// pantalla de fernies.
class GetMediaOfFernieUseCase
    extends UseCase<DataState<List<FernieRegionMediaEntity>>, int> {
  final FernieRepository _repository;

  GetMediaOfFernieUseCase(this._repository);

  @override
  Future<DataState<List<FernieRegionMediaEntity>>> call({int? params}) {
    return _repository.getMediaOfFernie(params!);
  }
}
