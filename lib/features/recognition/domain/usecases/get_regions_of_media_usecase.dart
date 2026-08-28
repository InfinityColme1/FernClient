import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Las regiones marcadas sobre un contenido, que es lo que el modo fernie pinta
/// al entrar.
///
/// Las de un fernie escondido no se pintan: el rectángulo lleva encima el nombre
/// de su fernie, así que dibujarlo sería decirlo.
class GetRegionsOfMediaUseCase
    extends UseCase<DataState<List<FernieRegionEntity>>, int> {
  final FernieRepository _repository;
  final ContentVisibility _visibility;

  GetRegionsOfMediaUseCase(
    this._repository, {
    ContentVisibility visibility = const ContentVisibility(),
  }) : _visibility = visibility;

  @override
  Future<DataState<List<FernieRegionEntity>>> call({int? params}) async {
    final result = await _repository.getRegionsOfMedia(params!);
    if (result is! DataSuccess) return result;

    return DataSuccess([
      for (final region in result.data ?? const <FernieRegionEntity>[])
        if (!_visibility.hidesFernie(region.fernieId)) region,
    ]);
  }
}
