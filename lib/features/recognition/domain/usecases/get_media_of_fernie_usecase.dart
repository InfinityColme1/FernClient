import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_media_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Las regiones de un fernie con el contenido de cada una, para la rejilla de la
/// pantalla de fernies.
///
/// Sin el contenido escondido, y esto es lo que cierra el agujero de verdad: la
/// celda de esta rejilla **es** un recorte del fichero, así que un fernie sin
/// marcar sobre contenido marcado enseñaba justo lo que el filtro escondía. Los
/// recuentos de la ficha siguen contándolas todas, que es lo que hace falta
/// saber para entrenar.
class GetMediaOfFernieUseCase
    extends UseCase<DataState<List<FernieRegionMediaEntity>>, int> {
  final FernieRepository _repository;
  final ContentVisibility _visibility;

  GetMediaOfFernieUseCase(
    this._repository, {
    ContentVisibility visibility = const ContentVisibility(),
  }) : _visibility = visibility;

  @override
  Future<DataState<List<FernieRegionMediaEntity>>> call({int? params}) async {
    final result = await _repository.getMediaOfFernie(params!);
    if (result is! DataSuccess) return result;

    return DataSuccess([
      for (final entry in result.data ?? const <FernieRegionMediaEntity>[])
        if (!_visibility.hidesMedia(entry.media.id)) entry,
    ]);
  }
}
