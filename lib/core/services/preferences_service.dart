import 'package:shared_preferences/shared_preferences.dart';


class PreferencesService {
  static const String _keyRootPath = 'user_media_root_path';
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);


  Future<bool> setRootPath(String path) async {
    return await _prefs.setString(_keyRootPath, path);
  }


  String? getRootPath() {
    return _prefs.getString(_keyRootPath);
  }


  Future<bool> clearRootPath() async {
    return await _prefs.remove(_keyRootPath);
  }
}