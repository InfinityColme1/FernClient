import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Las últimas etiquetas y creadores asignados a un contenido.
///
/// Se ofrecen nada más pulsar el campo, antes de escribir nada: etiquetar una
/// tanda es poner las mismas tres una y otra vez, y escribirlas enteras cada vez
/// es el trabajo que esto ahorra.
///
/// Lo que se guarda son **identificadores**, no nombres: renombrar una etiqueta
/// no puede dejar un reciente que ya no lleva a ninguna parte. Y se resuelven al
/// leerlos, que es lo que hace que una etiqueta borrada —o escondida por el
/// filtro— desaparezca sola de la lista sin tener que ir a limpiarla.
class RecentPicks {
  final PreferencesService _preferences;
  final LocalMediaRepository _repository;

  const RecentPicks({
    required PreferencesService preferences,
    required LocalMediaRepository repository,
  })  : _preferences = preferences,
        _repository = repository;

  Future<List<TagEntity>> tags() async {
    final found = <TagEntity>[];

    for (final id in _preferences.recentTagIds()) {
      if (found.length == recentPicksShown) break;

      final result = await _repository.getTag(id);
      final tag = result is DataSuccess ? result.data : null;
      if (tag != null) found.add(tag);
    }

    return found;
  }

  Future<List<CreatorEntity>> creators() async {
    final found = <CreatorEntity>[];

    for (final id in _preferences.recentCreatorIds()) {
      if (found.length == recentPicksShown) break;

      final result = await _repository.getCreator(id);
      final creator = result is DataSuccess ? result.data : null;
      if (creator != null) found.add(creator);
    }

    return found;
  }

  /// Apunta que se acaba de usar. Se llama al **asignar**, no al buscar: lo que
  /// interesa es lo que se ha puesto, no lo que se ha mirado.
  Future<void> pushTag(int id) => _preferences.pushRecentTag(id);

  Future<void> pushCreator(int id) => _preferences.pushRecentCreator(id);
}
