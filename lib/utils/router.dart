import 'package:get/get.dart';
import 'package:graduation_project/shared/screens/role_selection_screen.dart';
import 'package:graduation_project/shared/screens/splash_screen.dart';
import 'package:graduation_project/view/admin/admin_home.dart';
import 'package:graduation_project/view/admin/admin_login.dart';
import 'package:graduation_project/view/admin/admin_register.dart';
import 'package:graduation_project/view/user/user_home.dart';
import 'package:graduation_project/view/user/user_login.dart';

import '../shared/screens/otp_verification_screen.dart';
import '../shared/screens/phone_enter_screen.dart';

class AppRouter {
  // shared routes
  static const String initRoute = '/splash';
  static const String roleSelectionRoute = '/role-selection';
  static const String phoneEnterRoute = '/phone-entry';
  static const String otpVerificationRoute = '/otp-verification';
  // admin routes
  static const String adminLoginRoute = '/admin-login';
  static const String adminRegisterRoute = '/admin-register';
  static const String adminHomeRoute = '/admin-home';
  // user routes
  static const String userLoginRoute = '/user-login';
  static const String userHomeRoute = '/user-home';

  static final List<GetPage> routes = [
    GetPage(
      name: initRoute,
      page: () => const SplashScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: roleSelectionRoute,
      page: () => const RoleSelectionScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: adminLoginRoute,
      page: () => const AdminLoginScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: adminRegisterRoute,
      page: () => const AdminRegisterScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: userLoginRoute,
      page: () => const UserLoginScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: phoneEnterRoute,
      page: () => const PhoneEntryScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: otpVerificationRoute,
      page: () => OTPVerificationScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: adminHomeRoute,
      page: () => const AdminHomeScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: userHomeRoute,
      page: () => const UserHomeScreen(),
      transition: Transition.cupertino,
    ),
  ];
}
