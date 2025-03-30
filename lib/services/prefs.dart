import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService extends GetxService {
  static SharedPrefsService get instance => Get.find<SharedPrefsService>();

  late SharedPreferences _prefs;

  // Async initialization of SharedPreferences
  Future<SharedPrefsService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Save data
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  // Get data
  String? getString(String key) => _prefs.getString(key) ;

  bool getBool(String key) => _prefs.getBool(key) ?? false;

  int? getInt(String key) => _prefs.getInt(key);

  // Remove data
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // Clear all data
  Future<void> clear() async {
    await _prefs.clear();
  }
}
