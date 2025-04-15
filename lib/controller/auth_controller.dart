// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/model/user_model.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/router.dart';

import '../services/prefs.dart';

class AuthController extends GetxController {
  final SharedPrefsService _prefs = SharedPrefsService.instance;
  SharedPrefsService get prefs => _prefs;
  // final LogsController logsController = Get.find<LogsController>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  RxBool isLoading = false.obs;
  RxString role = "".obs;

  Future<void> checkUserStatus() async {
    isLoading.value = true;
    String userRole = _prefs.getString('role') ?? '';
    if (userRole == 'admin') {
      Get.offNamed(AppRouter.adminLayoutRoute);
    } else if (userRole == 'user') {
      Get.offNamed(AppRouter.userLayoutRoute);
    } else {
      Get.offNamed(AppRouter.roleSelectionRoute);
    }
    isLoading.value = false;
  }

  void loginRole(String userRole) {
    role.value = userRole;
  }

  // user login
  Future<void> loginUser(String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      User? user = userCredential.user;
      if (user == null) throw Exception("User not found after login.");

      await _prefs.saveString('role', role.value);
      await _prefs.saveString('uid', user.uid);
      await _database.ref('users/${user.uid}').get();
      bool isChanged = await handlePostLogin(user);

      final destination = role.value == 'admin'
          ? AppRouter.adminLayoutRoute
          : !isChanged
              ? AppRouter.userLayoutRoute
              : AppRouter.editUserRoute;

      Get.offNamed(destination);
      Get.snackbar(
        "Success",
        "User logged in successfully",
        backgroundColor: ColorManager.green,
        colorText: ColorManager.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    } finally {
      isLoading.value = false;
      debugPrint("User ID: ${_prefs.getString('uid') ?? 'UID not found'}");
      debugPrint("User Role: ${_prefs.getString('role') ?? 'Role not found'}");
    }
  }

  // admin register
  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      UserModel user = UserModel(
        name: name,
        email: email,
        phone: '+2$phone',
        uid: uid,
        accessibleObjects: [],
        role: "admin",
      );
      // await _firestore.collection("users").doc(uid).set(user.toMap());
      // save to realtime database
      await _database.ref("users/$uid").set(user.toMap());
      loginRole('admin');

      Get.offNamed(AppRouter.adminLoginRoute);
      Get.snackbar(
        "Success",
        "Admin Registered Successfully",
        backgroundColor: ColorManager.green,
        colorText: ColorManager.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Registration Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> handlePostLogin(User firebaseUser) async {
    final snapshot =
        await _database.ref('users/${firebaseUser.uid}/mustChangePasswd').get();
    final mustChange = snapshot.value as bool? ?? false;
    return mustChange;
  }

  Future<void> changePassword(String newPasswd) async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPasswd);
        await _database.ref('users/${user.uid}/mustChangePasswd').remove();

        Get.snackbar(
          "Success",
          "Password changed successfully.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offNamed(AppRouter.userLayoutRoute);
      } else {
        Get.snackbar(
          "Error",
          "User not logged in.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Error changing password: $e");
      Get.snackbar(
        "Error",
        "Failed to change password: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.authStateChanges());
  }
}
