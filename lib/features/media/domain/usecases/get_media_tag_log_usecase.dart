import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/tag_log_entry_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Por qué este contenido tiene puesto lo que tiene.
///
/// Junta las dos partes que viven en sitios distintos: el registro lo lleva la
/// biblioteca, y los fernies marcados —que explican una etiqueta que nadie
/// escribió— son del reconocimiento. La deducción del contenido anterior al
/// registro necesita las dos, así que se reúnen aquí y no dentro de ninguno de
/// los dos repositorios.
class GetMediaTagLogUseCase extends UseCase<DataState<MediaTagLogView>, int> {
  final LocalMediaRepository _library;
  final FernieRepository _fernies;

  GetMediaTagLogUseCase({
    required LocalMediaRepository library,
    required FernieRepository fernies,
  })  : _library = library,
        _fernies = fernies;

  @override
  Future<DataState<MediaTagLogView>> call({int? params}) async {
    final mediaId = params;
    if (mediaId == null) {
      return const DataSuccess((entries: [], isGuess: false));
    }

    return _library.getMediaTagLog(mediaId, byFernie: await _byFernie(mediaId));
  }

  /// Qué etiqueta enlaza cada fernie marcado en el contenido, y cómo se llama.
  ///
  /// Es lo que convierte «esta etiqueta no la puso nadie» en «la marcaste tú al
  /// señalar a Marinette». Un fernie que no enlaza nada no explica ninguna
  /// etiqueta y se queda fuera.
  Future<Map<int, String>> _byFernie(int mediaId) async {
    final result = await _fernies.getFerniesOfMedia(mediaId);
    if (result is! DataSuccess) return const {};

    return {
      for (final fernie in result.data ?? const <FernieEntity>[])
        if (fernie.linkedTagId case final tagId?) tagId: fernie.name,
    };
  }
}
