import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/data/services/blocked_imports.dart';
import 'package:Fern/features/media/domain/services/collapsed_tags.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/services/nsfw_index.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/settings/domain/services/database_wipe_options.dart';
import 'package:isar/isar.dart';

/// Deja la base de datos como recién instalada.
///
/// Se vacían **todas** las colecciones de una vez y en una sola transacción: a
/// medias quedaría una biblioteca con etiquetas que no señalan a nada y
/// contenidos sin la ficha que los describe, que es peor que las dos cosas.
///
/// Los ficheros del disco **sólo se tocan si se pide**. Es la diferencia entre
/// empezar de cero y perderlo todo: sin pedirlo, la carpeta de la biblioteca
/// sigue donde estaba y un escaneo la vuelve a dar de alta.
///
/// Y no se borran aquí: se **devuelven** para que quien lo pida los mande a la
/// cola de tareas. Miles de ficheros son minutos, y hacerlo aquí dejaría la
/// ventana bloqueada mientras dura sin poder decir por dónde va.
class DatabaseMaintenanceService {
  final Isar _database;
  final PreferencesService _preferences;
  final BlockedImports _blocked;
  final CollapsedTags _collapsedTags;

  /// Por dónde desaparece un contenido de verdad.
  ///
  /// El vaciado de sólo lo no apto no puede usar `Isar.clear()` —se llevaría lo
  /// demás—, y borrar sus filas a mano dejaría atrás lo que cuelga de ellas: las
  /// regiones marcadas, los grupos de repetidos, el registro de etiquetado. Eso
  /// ya lo sabe hacer el repositorio, y es el único sitio donde está escrito.
  final LocalMediaRepository _media;

  /// Qué contenido está marcado como no apto, contando lo heredado de sus
  /// etiquetas y creadores.
  final NsfwIndex _nsfw;

  DatabaseMaintenanceService({
    required Isar database,
    required PreferencesService preferences,
    required BlockedImports blocked,
    required CollapsedTags collapsedTags,
    required LocalMediaRepository media,
    required NsfwIndex nsfw,
  })  : _database = database,
        _preferences = preferences,
        _blocked = blocked,
        _collapsedTags = collapsedTags,
        _media = media,
        _nsfw = nsfw;

  /// Vacía la base de datos y olvida por dónde iban las importaciones.
  ///
  /// Lo segundo no es un extra: las marcas de importación dicen «de aquí para
  /// atrás ya está traído», y con la base de datos vacía eso es mentira.
  /// Dejarlas puestas haría que la siguiente importación «desde la última vez»
  /// no trajera nada y pareciera que la fuente está rota.
  ///
  /// Lo bloqueado se va con todo lo demás, y hay que **releerlo**: la respuesta
  /// durante una importación sale de memoria, así que sin esto se seguiría
  /// saltando contenido cuyo bloqueo ya no existe en ninguna parte —y la lista
  /// de esta misma pantalla, que sí lee de la base, saldría vacía—. Un bloqueo
  /// que no se ve y no se puede deshacer es exactamente la trampa que la lista
  /// venía a evitar.
  /// Devuelve **las rutas de los ficheros que hay que borrar**, o vacío si no se
  /// ha pedido borrarlos. Quien llama las manda a la cola.
  Future<List<String>> wipe([
    DatabaseWipeOptions options = const DatabaseWipeOptions(),
  ]) async {
    if (!options.isEverything) return _wipeNsfw(options);

    // Las rutas, **antes** de vaciar: después no hay de dónde sacarlas.
    final paths = options.deletesFiles ? await _pathsOfEverything() : const <String>[];

    await _database.writeTxn(() => _database.clear());
    await _preferences.forgetImportProgress();
    await _blocked.rebuild();
    // Y qué ramas estaban plegadas: sin esto quedarían identificadores de
    // etiquetas que ya no existen esperando a que alguien vuelva a usar sus
    // números.
    await _collapsedTags.clear();

    // Lo que el filtro escondía se ha ido con todo lo demás: sin releerlo, el
    // índice seguiría diciendo que hay contenido bloqueado en una base vacía.
    await _nsfw.rebuild();

    return paths;
  }

  /// Se lleva sólo el contenido marcado como no apto.
  ///
  /// **Marcado a mano y heredado**, que es lo que el índice ya sabe: lo que
  /// cuelga de una etiqueta o de un creador marcados está igual de escondido, y
  /// dejarlo fuera vaciaría a medias justo lo que se pidió vaciar.
  ///
  /// No se toca nada más: las etiquetas, los creadores, los fernies y los
  /// modelos se quedan. Lo que se borra es contenido, no la biblioteca.
  Future<List<String>> _wipeNsfw(DatabaseWipeOptions options) async {
    final ids = _nsfw.media.toList();
    if (ids.isEmpty) return const [];

    final paths = options.deletesFiles ? await _pathsOf(ids) : const <String>[];

    // Sin ficheros: los borra la cola después, con su progreso. Aquí sólo se van
    // las filas, que es lo que tiene que pasar de una vez.
    await _media.deleteMediaList(ids);
    await _nsfw.rebuild();

    return paths;
  }

  Future<List<String>> _pathsOfEverything() async {
    final summaries = await _database.mediaSummaryModels.where().findAll();

    return [for (final summary in summaries) summary.path];
  }

  Future<List<String>> _pathsOf(List<int> ids) async {
    final summaries = await _database.mediaSummaryModels.getAll(ids);

    return [for (final summary in summaries.nonNulls) summary.path];
  }
}
