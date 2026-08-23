import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/entities/media_suggestion_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Convierte lo que un modelo vio en una región marcada de verdad.
///
/// Es lo que cierra el círculo del reconocimiento: un modelo detecta un fernie,
/// el usuario ve que ha acertado, y con un clic esa detección pasa a ser
/// material con el que entrenar la próxima vez. Sin esto, cada acierto del
/// modelo se pierde y hay que volver a marcar a mano lo que ya estaba bien
/// marcado.
///
/// La región se crea **sobre el fernie que detectó**, no sobre lo que la
/// sugerencia propone: lo que se está guardando es «aquí hay uno de éstos», y
/// eso es del fernie. La etiqueta que se ponga al contenido es otra decisión.
class TurnDetectionIntoRegionUseCase
    extends UseCase<DataState<FernieRegionEntity>, MediaSuggestionEntity> {
  final FernieRepository _repository;

  TurnDetectionIntoRegionUseCase(this._repository);

  @override
  Future<DataState<FernieRegionEntity>> call({
    MediaSuggestionEntity? params,
  }) async {
    final suggestion = params!;
    final box = suggestion.box;

    // Sin caja no hay región que crear. Pasa con las detecciones de un fichero
    // que el sidecar no supo medir: la sugerencia vale igual, pero no dice
    // dónde, y una región sin sitio no es una región.
    if (box == null) {
      return DataException(Exception('La sugerencia no dice dónde lo vio'));
    }

    final region = FernieRegionEntity(
      id: unsavedId,
      mediaId: suggestion.mediaId,
      fernieId: suggestion.fernie.id,
      x: box.x,
      y: box.y,
      w: box.w,
      h: box.h,
      // El fotograma viaja con ella: en un vídeo, una región sin momento está
      // marcada sobre el fotograma equivocado.
      frameMs: suggestion.frameMs,
    );

    final result = await _repository.addRegions([region]);

    if (result is! DataSuccess || (result.data?.isEmpty ?? true)) {
      return DataException(
        result is DataException
            ? result.exception ?? Exception('No se pudo guardar la región')
            : Exception('No se pudo guardar la región'),
      );
    }

    return DataSuccess(result.data!.first);
  }
}
