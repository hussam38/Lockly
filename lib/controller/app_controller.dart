import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/shared/bindings/admin_bindings.dart';

import '../view/admin/admin_home.dart';
import '../view/admin/admin_logs.dart';
import '../view/admin/admin_settings.dart';
import '../view/user/user_home.dart';
import '../view/user/user_settings.dart';

class AppController extends GetxController {
  var currentIndex = 0.obs;
  var role = "".obs;

  var pages = <Widget>[].obs;
  var bottomNavItems = <BottomNavigationBarItem>[].obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  Future<void> getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      log("userDoc: ${userDoc.data()}");
      if (userDoc.exists) {
        role.value = userDoc.get('role');

        if (role.value == "admin") {
          AdminBindings().dependencies();
          pages.assignAll(const [
            AdminHomeScreen(),
            AdminLogsScreen(),
            AdminSettingsScreen()
          ]);
          bottomNavItems.assignAll(const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Logs'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ]);
        } else {
          pages.assignAll(const [UserHomeScreen(), UserSettingsScreen()]);
          bottomNavItems.assignAll(const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ]);
        }
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    getUserRole();
  }
}
