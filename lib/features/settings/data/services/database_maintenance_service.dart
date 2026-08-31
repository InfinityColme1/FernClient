import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/data/services/blocked_imports.dart';
import 'package:Fern/features/media/domain/services/collapsed_tags.dart';
import 'package:isar/isar.dart';

/// Deja la base de datos como recién instalada.
///
/// Se vacían **todas** las colecciones de una vez y en una sola transacción: a
/// medias quedaría una biblioteca con etiquetas que no señalan a nada y
/// contenidos sin la ficha que los describe, que es peor que las dos cosas.
///
/// Los ficheros del disco no se tocan. Es la diferencia entre empezar de cero y
/// perderlo todo: la carpeta de la biblioteca sigue donde estaba y un escaneo la
/// vuelve a dar de alta.
class DatabaseMaintenanceService {
  final Isar _database;
  final PreferencesService _preferences;
  final BlockedImports _blocked;
  final CollapsedTags _collapsedTags;

  DatabaseMaintenanceService({
    required Isar database,
    required PreferencesService preferences,
    required BlockedImports blocked,
    required CollapsedTags collapsedTags,
  })  : _database = database,
        _preferences = preferences,
        _blocked = blocked,
        _collapsedTags = collapsedTags;

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
  Future<void> wipe() async {
    await _database.writeTxn(() => _database.clear());
    await _preferences.forgetImportProgress();
    await _blocked.rebuild();
    // Y qué ramas estaban plegadas: sin esto quedarían identificadores de
    // etiquetas que ya no existen esperando a que alguien vuelva a usar sus
    // números.
    await _collapsedTags.clear();
  }
}
