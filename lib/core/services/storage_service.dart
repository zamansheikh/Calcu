import 'package:shared_preferences/shared_preferences.dart';

/// Thin async facade over SharedPreferences. Keeps repositories free of
/// platform calls and lets us swap the backing store without touching
/// callers.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  String? readString(String key) => _prefs.getString(key);
  Future<bool> writeString(String key, String value) =>
      _prefs.setString(key, value);

  List<String>? readStringList(String key) => _prefs.getStringList(key);
  Future<bool> writeStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
}
