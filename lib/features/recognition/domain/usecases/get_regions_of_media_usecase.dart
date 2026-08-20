import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Las regiones marcadas sobre un contenido. Es lo que el modo fernie pinta al
/// entrar, y lo que el visor resalta al llegar desde la pantalla de fernies.
class GetRegionsOfMediaUseCase
    extends UseCase<DataState<List<FernieRegionEntity>>, int> {
  final FernieRepository _repository;

  GetRegionsOfMediaUseCase(this._repository);

  @override
  Future<DataState<List<FernieRegionEntity>>> call({int? params}) {
    return _repository.getRegionsOfMedia(params!);
  }
}
