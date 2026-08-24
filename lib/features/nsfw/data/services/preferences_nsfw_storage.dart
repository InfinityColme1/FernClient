import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lo del modo NSFW, guardado con el resto de las preferencias.
///
/// Ahí y no en la base de datos porque no es contenido: es cómo está puesta la
/// aplicación. Y lo que se guarda no es ningún secreto —hashes con su sal y una
/// pista escrita por el usuario—, así que un fichero de preferencias legible no
/// es aquí un problema: leerlo no abre nada.
class PreferencesNsfwStorage implements NsfwStorage {
  final SharedPreferences _preferences;

  const PreferencesNsfwStorage(this._preferences);

  @override
  String? read(String key) => _preferences.getString(key);

  @override
  Future<void> write(String key, String value) async {
    await _preferences.setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }
}
