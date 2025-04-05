import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/services/prefs.dart';

import '../view/user/user_home.dart';
import '../view/user/user_settings.dart';

class UserController extends GetxController {
  final SharedPrefsService _prefs = SharedPrefsService.instance;
  SharedPrefsService get prefs => _prefs;
  RxInt currentIndex = 0.obs;
  RxList pages = const <Widget>[UserHomeScreen(), UserSettingsScreen()].obs;

  void changePage(int i) {
    currentIndex.value = i;
  }
}
