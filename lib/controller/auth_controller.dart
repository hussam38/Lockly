// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/logs_controller.dart';
import 'package:graduation_project/model/logs_model.dart';
import 'package:graduation_project/model/user_model.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/router.dart';
import 'package:local_auth/local_auth.dart';

import '../services/prefs.dart';

class AuthController extends GetxController {
  final SharedPrefsService _prefs = SharedPrefsService.instance;
  SharedPrefsService get prefs => _prefs;
  final LogsController logsController = Get.find<LogsController>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  LocalAuthentication get localAuth => _localAuth;
  var isAuth = false.obs;
  bool _isAuthenticating = false;

  RxBool isLoading = false.obs;
  RxString role = "".obs;
  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  Future<void> authWithBiometrics() async {
    final canCheckBiometrics = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    if (!canCheckBiometrics || !isDeviceSupported) {
      Get.snackbar("Error", "Biometric authentication not supported");
      SystemNavigator.pop();
      return;
    }
    try {
      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      isAuth.value = didAuth;
      if (didAuth) {
        String? r = _prefs.getString('role');
        if (r == 'admin') {
          Get.offAllNamed(AppRouter.adminLayoutRoute);
        } else if (r == 'user') {
          Get.offAllNamed(AppRouter.userLayoutRoute);
        } else {
          Get.offAllNamed(AppRouter.roleSelectionRoute);
        }
      } else {
        SystemNavigator.pop();
      }
    } catch (e) {
      Get.snackbar("Error", "Authentication failed: $e");
    }
  }

  Future<void> canAuthWithBiometrics() async {
    if (_isAuthenticating) return;

    final isAvailable = await _localAuth.canCheckBiometrics ||
        await _localAuth.isDeviceSupported();

    if (!isAvailable) {
      _navigateByRole(); // fallback if not supported
      return;
    }

    try {
      _isAuthenticating = true;

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        _navigateByRole();
      } else {
        Get.snackbar("Error", "Authentication cancelled or failed");
      }
    } catch (e) {
      print("Auth error: $e");
      Get.snackbar("Error", "Authentication error: $e");
    } finally {
      _isAuthenticating = false;
    }
  }

  void _navigateByRole() {
    final role = _prefs.getString('role') ?? '';
    if (role == 'admin') {
      Get.offNamed(AppRouter.adminLayoutRoute);
    } else if (role == 'user') {
      Get.offNamed(AppRouter.userLayoutRoute);
    } else {
      Get.offNamed(AppRouter.roleSelectionRoute);
    }
  }

  void loginRole(String userRole) {
    role.value = userRole;
    print("Role: ${role.value}");
  }

  // user login
  Future<void> loginUser(String email, String password) async {
    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = userCredential.user;
      if (user == null) throw Exception("Login succeeded, but user is null.");

      final roleSnapshot = await _database.ref('users/${user.uid}/role').get();
      final dbRole = roleSnapshot.value?.toString();

      if (dbRole == null) {
        await _auth.signOut();
        throw Exception("User role not found in database.");
      }

      if (role.value == 'admin' && dbRole != 'admin') {
        await _auth.signOut();
        debugPrint("Blocked: user selected 'admin' but is not admin.");
        throw Exception("Access Denied: You are not authorized as admin.");
      }

      await _prefs.saveString('role', dbRole);
      await _prefs.saveString('uid', user.uid);

      bool isChanged = await handlePostLogin(user);

      final destination = dbRole == 'admin'
          ? AppRouter.adminLayoutRoute
          : !isChanged
              ? AppRouter.userLayoutRoute
              : AppRouter.editUserRoute;

      debugPrint("Navigating to: $destination");
      logsController.addLog(
        LogEntry(
          id: user.uid,
          timestamp: DateTime.now(),
          action: 'Login',
          status: 'SUCCESS',
          details: 'User ${user.email} logged in.',
          userName: user.email ?? 'Unknown',
        ),
      );

      Get.offNamed(destination);
      Get.snackbar(
        "Success",
        "User logged in successfully",
        backgroundColor: ColorManager.green,
        colorText: ColorManager.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint("Login error: $e");
      logsController.addLog(
        LogEntry(
          id: _auth.currentUser?.uid ?? '',
          timestamp: DateTime.now(),
          action: 'Login',
          status: 'FAILED',
          details: 'User ${_auth.currentUser!.email} log in failed.',
          userName: _auth.currentUser?.email ?? 'Unknown',
        ),
      );
      Get.snackbar(
        "Login Failed",
        e.toString().replaceFirst("Exception: ", ""),
        backgroundColor: Colors.red,
        colorText: ColorManager.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      debugPrint("Final UID: ${_prefs.getString('uid')}");
      debugPrint("Final ROLE: ${_prefs.getString('role')}");
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
      await _database.ref("users/$uid").set(user.toMap());
      loginRole('admin');
      logsController.addLog(
        LogEntry(
          id: user.uid,
          timestamp: DateTime.now(),
          action: 'Login',
          status: 'SUCCESS',
          details: 'User ${user.name} registered.',
          userName: user.email,
        ),
      );

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
      logsController.addLog(
        LogEntry(
          id: _auth.currentUser?.uid ?? '',
          timestamp: DateTime.now(),
          action: 'Login',
          status: 'FAILED',
          details:
              'User ${_auth.currentUser!.displayName} regestration failed.',
          userName: _auth.currentUser?.email ?? 'Unknown',
        ),
      );
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
