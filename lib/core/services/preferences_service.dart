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


  String _lastImportMarkerKey(ImportSource source) =>
      '$lastImportMarkerPreferenceKeyPrefix${source.id}';


  /// Guarda por dónde se quedó la última importación de [source]: el
  /// identificador de lo más nuevo que tenía la fuente en ese momento.
  ///
  /// Es lo que hace posible traerse "lo guardado desde la última vez" sin que la
  /// fuente diga cuándo se guardó cada cosa: al recorrerla de lo más nuevo a lo
  /// más antiguo, llegar a esta marca es llegar a donde se dejó.
  Future<bool> setLastImportMarker(ImportSource source, String marker) async {
    return await _prefs.setString(_lastImportMarkerKey(source), marker);
  }


  /// Por dónde se quedó la última importación de [source], o `null` si de esa
  /// fuente no se ha llegado a importar nada todavía.
  String? getLastImportMarker(ImportSource source) {
    return _prefs.getString(_lastImportMarkerKey(source));
  }
}
