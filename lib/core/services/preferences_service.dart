import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media_deletion_kind.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);


  Future<bool> setRootPath(String path) async {
    return await _prefs.setString(rootPathPreferenceKey, path);
  }


  String? getRootPath() {
    return _prefs.getString(rootPathPreferenceKey);
  }


  Future<bool> clearRootPath() async {
    return await _prefs.remove(rootPathPreferenceKey);
  }


  String _lastImportKey(ImportSource source) =>
      '$lastImportPreferenceKeyPrefix${source.id}';


  /// Anota que se acaba de terminar un escaneo de [source].
  ///
  /// Se sella al terminar, haya traído contenido o no: lo que dice es cuándo se
  /// miró por última vez, que es lo que hace falta para saber si lo que se está
  /// viendo está al día.
  Future<bool> setLastImport(ImportSource source, DateTime at) async {
    return await _prefs.setString(_lastImportKey(source), at.toIso8601String());
  }


  /// Cuándo se importó por última vez de [source], o `null` si nunca.
  DateTime? getLastImport(ImportSource source) {
    final value = _prefs.getString(_lastImportKey(source));
    if (value == null) return null;

    return DateTime.tryParse(value);
  }


  String _deleteFilesKey(MediaDeletionKind kind) => switch (kind) {
        MediaDeletionKind.trash => deleteTrashFilesPreferenceKey,
        MediaDeletionKind.discard => deleteDiscardedFilesPreferenceKey,
      };


  /// Si el próximo borrado de [kind] se lleva también los ficheros del disco.
  ///
  /// Es cómo quedó la casilla del aviso la última vez; mientras no se haya
  /// borrado nada de esa manera, lo que dice [MediaDeletionKind.deletesFiles].
  bool getDeleteFiles(MediaDeletionKind kind) {
    return _prefs.getBool(_deleteFilesKey(kind)) ?? kind.deletesFiles;
  }


  /// Recuerda cómo ha quedado la casilla del aviso, que es con lo que sale la
  /// próxima vez.
  Future<bool> setDeleteFiles(MediaDeletionKind kind, bool deleteFiles) async {
    return await _prefs.setBool(_deleteFilesKey(kind), deleteFiles);
  }


  String _lastImportMarkerKey(ImportSource source, String? collection) =>
      '$lastImportMarkerPreferenceKeyPrefix${source.id}'
      '${collection == null ? '' : '_$collection'}';


  /// Guarda por dónde se quedó la última importación de [source]: el
  /// identificador de lo más nuevo que tenía la fuente en ese momento.
  ///
  /// Es lo que hace posible traerse "lo guardado desde la última vez" sin que la
  /// fuente diga cuándo se guardó cada cosa: al recorrerla de lo más nuevo a lo
  /// más antiguo, llegar a esta marca es llegar a donde se dejó.
  ///
  /// [collection] es para las fuentes que no tienen un solo listado sino
  /// varios (Pixiv tiene dos, el de marcadores públicos y el de privados): cada
  /// uno se recorre por su cuenta y por tanto se queda por su sitio, así que
  /// cada uno lleva su marca. Se omite en las fuentes de un solo listado.
  Future<bool> setLastImportMarker(
    ImportSource source,
    String marker, {
    String? collection,
  }) async {
    return await _prefs.setString(
      _lastImportMarkerKey(source, collection),
      marker,
    );
  }


  /// Por dónde se quedó la última importación de [source], o `null` si de esa
  /// fuente no se ha llegado a importar nada todavía.
  String? getLastImportMarker(ImportSource source, {String? collection}) {
    return _prefs.getString(_lastImportMarkerKey(source, collection));
  }


  /// Todas las marcas guardadas de [source], por listado.
  ///
  /// Hace falta cuando los listados no se saben de antemano: los creadores que
  /// alguien sigue son los que son, y cambian.
  Map<String, String> importMarkers(ImportSource source) {
    final prefix = _lastImportMarkerKey(source, null);

    return {
      for (final key in _prefs.getKeys())
        if (key.startsWith('${prefix}_'))
          if (_prefs.getString(key) case final marker?)
            key.substring(prefix.length + 1): marker,
    };
  }


  /// Guarda en qué página se ha quedado el navegador de la aplicación.
  ///
  /// No es un ajuste sino dónde se estaba: salir a otra pantalla y volver tiene
  /// que dejar el navegador como se dejó, igual que cualquier otra pantalla
  /// vuelve como estaba.
  Future<bool> setLastBrowserUrl(String url) {
    return _prefs.setString(browserLastUrlPreferenceKey, url);
  }


  /// La página en la que se dejó el navegador, o `null` si todavía no se ha
  /// abierto ninguna.
  String? getLastBrowserUrl() => _prefs.getString(browserLastUrlPreferenceKey);
}
