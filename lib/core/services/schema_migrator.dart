import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/app_exceptions.dart';
// Una migración trabaja sobre las filas, así que conoce los modelos: es la
// excepción a que el núcleo no sepa de las features.
import 'package:Fern/features/media/data/models/tag_model.dart';
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
/// Hasta la 6 estaba vacío a propósito: todo lo que trajo FeRN 2.0 era aditivo
/// (colecciones nuevas y campos con valor por defecto), así que no había nada
/// que convertir. La 7 es la primera que hace algo.
const Map<int, Migration> schemaMigrations = {
  7: repairTagSiblingSymmetry,
};

/// Devuelve la simetría a las relaciones de hermandad que quedaron a medias.
///
/// `TagModel.siblings` no tiene backlink: la simetría la fuerza el repositorio
/// al guardar, escribiendo las dos direcciones. Pero el árbol de etiquetas se
/// leía **sin** las hermanas, así que la ficha de la pantalla de gestión partía
/// siempre de una lista vacía, y guardar desde ahí desenlazaba por un lado lo
/// que seguía enlazado por el otro. El resultado es una etiqueta que sabe que es
/// hermana de otra sin que la otra lo sepa: se ve desde un lado y desde el otro
/// no.
///
/// **Sólo añade.** Ante una relación coja hay dos lecturas —«se creó y se perdió
/// la mitad» o «se quitó y se quedó la mitad»— y no hay forma de distinguirlas
/// en los datos. Se elige recuperarla: recuperar de más se deshace quitándola a
/// mano, y borrar de más no se deshace de ninguna manera.
///
/// Es idempotente: pasarla dos veces sobre la misma base no cambia nada.
Future<void> repairTagSiblingSymmetry(Isar database) async {
  final tags = await database.tagModels.where().findAll();
  if (tags.isEmpty) return;

  final byId = {for (final tag in tags) tag.id: tag};

  // Se mira todo antes de escribir nada: leer dentro de la escritura mientras se
  // van modificando los enlaces es pedirle a Isar que conteste sobre algo que
  // está cambiando debajo.
  for (final tag in tags) {
    await tag.siblings.load();
  }

  // Qué le falta a cada etiqueta, por identificador.
  final missing = <int, Set<TagModel>>{};
  for (final tag in tags) {
    for (final sibling in tag.siblings) {
      final other = byId[sibling.id];

      // Enlazada con algo que ya no está: la relación no lleva a ninguna parte
      // y no hay nada que reparar en el otro lado.
      if (other == null || other.id == tag.id) continue;

      if (other.siblings.any((each) => each.id == tag.id)) continue;

      missing.putIfAbsent(other.id, () => <TagModel>{}).add(tag);
    }
  }

  if (missing.isEmpty) return;

  await database.writeTxn(() async {
    for (final entry in missing.entries) {
      final tag = byId[entry.key];
      if (tag == null) continue;

      await tag.siblings.update(link: entry.value);
    }
  });
}
