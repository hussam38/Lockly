import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:graduation_project/model/user_model.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/router.dart';

import '../services/prefs.dart';

class AuthController extends GetxController {
  final SharedPrefsService _prefs = SharedPrefsService.instance;
  SharedPrefsService get prefs => _prefs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      if (user != null) {
        if (role.value == 'admin') {
          await _prefs.saveString('role', role.value);
          await _prefs.saveString('uid', user.uid);
          Get.offNamed(AppRouter.adminLayoutRoute);
        } else {
          await _prefs.saveString('role', role.value);
          await _prefs.saveString('uid', user.uid);
          Get.offNamed(AppRouter.userLayoutRoute);
        }
      }
      Get.snackbar(
        "Success",
        "User logged in successfully",
        backgroundColor: ColorManager.grey,
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
      await _firestore.collection("users").doc(uid).set(user.toMap());

      Get.offNamed(AppRouter.adminLoginRoute);
      Get.snackbar(
        "Success",
        "Admin Registered Successfully",
        backgroundColor: ColorManager.grey,
        colorText: ColorManager.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Registration Failed", e.toString());
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
