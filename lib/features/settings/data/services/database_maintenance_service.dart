import 'package:Fern/core/services/preferences_service.dart';
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

  DatabaseMaintenanceService({
    required Isar database,
    required PreferencesService preferences,
  })  : _database = database,
        _preferences = preferences;

  /// Vacía la base de datos y olvida por dónde iban las importaciones.
  ///
  /// Lo segundo no es un extra: las marcas de importación dicen «de aquí para
  /// atrás ya está traído», y con la base de datos vacía eso es mentira.
  /// Dejarlas puestas haría que la siguiente importación «desde la última vez»
  /// no trajera nada y pareciera que la fuente está rota.
  Future<void> wipe() async {
    await _database.writeTxn(() => _database.clear());
    await _preferences.forgetImportProgress();
  }
}
