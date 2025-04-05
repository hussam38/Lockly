import 'dart:developer';

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
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      log('Error saving string: $e');
    }
  }

  Future<void> saveBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } catch (e) {
      log('Error saving bool: $e');
    }
  }

  Future<void> saveInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
    } catch (e) {
      log('Error saving int: $e');
    }
  }

  // Get data
  String? getString(String key) => _prefs.getString(key);

  bool getBool(String key) => _prefs.getBool(key) ?? false;

  int? getInt(String key) => _prefs.getInt(key);

  // Remove data
  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      log('Error removing key: $e');
    }
  }

  // Clear all data
  Future<void> clear() async {
    try {
      await _prefs.clear();
    } catch (e) {
      log('Error clearing preferences: $e');
    }
  }
}
