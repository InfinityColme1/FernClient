import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/media_suggestion_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:Fern/features/recognition/domain/repositories/recognition_result_repository.dart';

/// Lo que hay propuesto sobre un contenido y todavía nadie ha mirado.
///
/// Junta tres sitios: de la tabla de resultados salen los números, del
/// repositorio de fernies sale qué significan, y de la biblioteca sale **lo que
/// se pondría al aceptarlos**. Es aquí y no en la pantalla porque los cuatro
/// puntos de entrada del D16 acaban enseñando lo mismo, y resolverlo en cada uno
/// es garantizar que acaben resolviéndolo distinto.
///
/// Resolver la etiqueta o el creador aquí y no al aceptar tiene una razón
/// concreta: aceptar deja de ser una operación que puede fallar. Si la etiqueta
/// ya no existe, la sugerencia llega sin nada que proponer y el botón de aceptar
/// no aparece, en vez de aparecer y dar un error al pulsarlo.
class GetMediaSuggestionsUseCase
    extends UseCase<DataState<List<MediaSuggestionEntity>>, int> {
  final RecognitionResultRepository _results;
  final FernieRepository _fernies;
  final LocalMediaRepository _library;

  GetMediaSuggestionsUseCase({
    required RecognitionResultRepository results,
    required FernieRepository fernies,
    required LocalMediaRepository library,
  })  : _results = results,
        _fernies = fernies,
        _library = library;

  @override
  Future<DataState<List<MediaSuggestionEntity>>> call({int? params}) async {
    final found = await _results.getForMedia(params!);

    if (found is! DataSuccess || found.data == null) {
      return DataException(
        found.exception ?? Exception('No se pudieron leer las sugerencias'),
      );
    }

    // Sólo lo que nadie ha contestado. Lo aceptado ya está puesto en el
    // contenido y lo rechazado se queda guardado para contar el acierto del
    // modelo, pero volver a enseñarlo sería volver a preguntar lo mismo.
    final pending = [
      for (final one in found.data!)
        if (one.status == SuggestionStatus.suggested) one,
    ];

    if (pending.isEmpty) return const DataSuccess([]);

    // Un fernie se lee una vez aunque lo propongan tres modelos: son tres
    // opiniones sobre el mismo, y son las tres las que se enseñan.
    final fernies = await _ferniesById(pending);

    // Lo enlazado se resuelve **por fernie** y no por sugerencia: tres modelos
    // que proponen el mismo fernie proponen la misma etiqueta, y leerla tres
    // veces es pedirle a la base lo mismo tres veces.
    final tags = <int, TagEntity?>{};
    final creators = <int, CreatorEntity?>{};

    for (final fernie in fernies.values) {
      tags[fernie.id] = await _tagOf(fernie);
      creators[fernie.id] = await _creatorOf(fernie);
    }

    final suggestions = <MediaSuggestionEntity>[];

    for (final one in pending) {
      final fernie = fernies[one.fernieId];
      if (fernie == null) continue;

      suggestions.add(MediaSuggestionEntity(
        result: one,
        fernie: fernie,
        tag: tags[fernie.id],
        creator: creators[fernie.id],
      ));
    }

    return DataSuccess(suggestions);
  }

  /// Los fernies de estas sugerencias, por identificador.
  ///
  /// El que ya no exista se queda fuera y su sugerencia no llega a enseñarse:
  /// borrar un fernie no borra lo que se propuso con él, y una sugerencia sin
  /// nombre ni cara no se puede ni entender ni aceptar.
  Future<Map<int, FernieEntity>> _ferniesById(
    List<RecognitionResultEntity> results,
  ) async {
    final ids = {for (final one in results) one.fernieId};
    final fernies = <int, FernieEntity>{};

    for (final id in ids) {
      final found = await _fernies.getFernie(id);

      if (found is DataSuccess && found.data != null) {
        fernies[id] = found.data!;
      }
    }

    return fernies;
  }

  /// La etiqueta que este fernie propone, si propone alguna y sigue existiendo.
  Future<TagEntity?> _tagOf(FernieEntity fernie) async {
    final id = fernie.linkedTagId;
    if (id == null) return null;

    final found = await _library.getTag(id);

    return found is DataSuccess ? found.data : null;
  }

  Future<CreatorEntity?> _creatorOf(FernieEntity fernie) async {
    final id = fernie.linkedCreatorId;
    if (id == null) return null;

    final found = await _library.getCreator(id);

    return found is DataSuccess ? found.data : null;
  }
}
