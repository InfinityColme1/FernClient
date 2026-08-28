import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/app_exceptions.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lo que hay que hacer para pasar la base de datos de una versión a la
/// siguiente.
///
/// Recibe la base de datos ya abierta: una migración escribe y lee filas, no
/// toca el esquema (de eso se encarga Isar al abrir con las colecciones nuevas).
typedef Migration = Future<void> Function(Isar database);

/// Lleva la cuenta de por qué versión de esquema va la base de datos y ejecuta
/// lo que falte para ponerla al día.
///
/// Hasta la versión 2 la aplicación no tenía ninguna noción de esto: se abría
/// Isar y se confiaba en que todos los cambios fueran de los que Isar resuelve
/// sola (añadir un campo con valor por defecto, añadir una colección). Eso vale
/// mientras sólo se añade, y deja de valer en cuanto se renombra un campo, se le
/// cambia el tipo o hay que rellenar hacia atrás algo que antes no existía.
///
/// La regla, para no tener que recordarla cada vez:
///
/// - Campo nuevo con valor por defecto: aditivo, no hace falta migración.
/// - Colección nueva: basta con registrar su esquema en `AppDatabase`.
/// - Renombrar, cambiar de tipo, borrar o rellenar retroactivamente: migración.
///
/// Si una migración falla se aborta y no se guarda la versión nueva: es
/// preferible que la aplicación no arranque a que arranque sobre datos a medio
/// convertir, que es un estropicio silencioso y difícil de deshacer.
class SchemaMigrator {
  final SharedPreferences _preferences;

  /// Qué hacer para llegar a cada versión, indexado por la versión de destino.
  ///
  /// Se inyecta para poder probarlo; en la aplicación es [schemaMigrations].
  final Map<int, Migration> _migrations;

  /// Hasta dónde hay que llegar. Inyectable por lo mismo.
  final int _targetVersion;

  SchemaMigrator({
    required SharedPreferences preferences,
    Map<int, Migration>? migrations,
    int? targetVersion,
  })  : _preferences = preferences,
        _migrations = migrations ?? schemaMigrations,
        _targetVersion = targetVersion ?? currentSchemaVersion;

  /// La versión con la que se guardó la base de datos por última vez.
  ///
  /// Sin preferencia guardada se asume la 1, que es todo lo anterior a que
  /// existiera este servicio.
  int get currentVersion =>
      _preferences.getInt(schemaVersionPreferenceKey) ?? firstSchemaVersion;

  /// Pone [database] al día, ejecutando en orden las migraciones que falten.
  ///
  /// No hace nada si ya está en la versión de destino, que es el caso de todos
  /// los arranques menos el primero después de actualizar.
  Future<void> run(Isar database) async {
    var version = currentVersion;
    if (version >= _targetVersion) return;

    while (version < _targetVersion) {
      final next = version + 1;
      final migration = _migrations[next];

      if (migration != null) {
        try {
          await migration(database);
        } on Exception catch (error) {
          throw SchemaMigrationException(
            fromVersion: version,
            toVersion: next,
            cause: error,
          );
        }
      }

      version = next;

      // Se sella cada escalón por separado: si la que falla es la tercera de
      // cuatro, las dos primeras no se repiten en el arranque siguiente.
      await _preferences.setInt(schemaVersionPreferenceKey, version);
    }
  }
}

/// Las migraciones de la aplicación, por versión de destino.
///
/// Está vacío a propósito: todo lo que trae FeRN 2.0 es aditivo (colecciones
/// nuevas y campos con valor por defecto), así que llegar a la versión 2 no
/// exige convertir nada. Lo que se monta aquí es el sitio donde poner la
/// primera migración de verdad el día que haga falta, en lugar de improvisarla.
const Map<int, Migration> schemaMigrations = {};
