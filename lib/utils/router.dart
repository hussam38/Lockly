import 'package:get/get.dart';
import 'package:graduation_project/shared/bindings/admin_bindings.dart';
import 'package:graduation_project/shared/bindings/user_bindings.dart';
import 'package:graduation_project/shared/screens/role_selection_screen.dart';
import 'package:graduation_project/shared/screens/splash_screen.dart';
import 'package:graduation_project/view/admin/add_object_screen.dart';
import 'package:graduation_project/view/admin/admin_home.dart';
import 'package:graduation_project/view/admin/admin_layout.dart';
import 'package:graduation_project/view/admin/admin_login.dart';
import 'package:graduation_project/view/admin/admin_register.dart';
import 'package:graduation_project/view/admin/admin_settings.dart';
import 'package:graduation_project/view/admin/edit_admin_screen.dart';
import 'package:graduation_project/view/admin/group_user_screen.dart';
import 'package:graduation_project/view/admin/manage_devices.dart';
import 'package:graduation_project/view/admin/manage_users_screen.dart';
import 'package:graduation_project/view/user/edit_user_screen.dart';
import 'package:graduation_project/view/user/user_home.dart';
import 'package:graduation_project/view/user/user_login.dart';
import 'package:graduation_project/view/user/user_settings.dart';

import '../shared/screens/otp_verification_screen.dart';
import '../shared/screens/phone_enter_screen.dart';
import '../view/admin/admin_logs.dart';
import '../view/user/user_layout.dart';

class AppRouter {
  // shared routes
  static const String initRoute = '/splash';
  static const String roleSelectionRoute = '/role-selection';
  static const String phoneEnterRoute = '/phone-entry';
  static const String otpVerificationRoute = '/otp-verification';
  static const String addObjectRoute = '/add-object';

  // admin routes
  static const String adminLayoutRoute = '/admin-layout';
  static const String adminLoginRoute = '/admin-login';
  static const String adminRegisterRoute = '/admin-register';
  static const String adminHomeRoute = '/admin-home';
  static const String adminLogsRoute = '/admin-logs';
  static const String adminSettingsRoute = '/admin-settings';
  static const String manageUsersRoute = '/manage-users';
  static const String manageDevicesRoute = '/manage-devices';
  static const String editAdminRoute = "/edit-admin";
  static const String groupUsersRoute = '/group-users';
  // user routes
  static const String userLayoutRoute = '/user-layout';
  static const String userLoginRoute = '/user-login';
  static const String userHomeRoute = '/user-home';
  static const String userSettingsRoute = '/user-settings';
  static const String editUserRoute = "/edit-user";

  static final List<GetPage> routes = [
    // splash
    GetPage(
      name: initRoute,
      page: () => const SplashScreen(),
      transition: Transition.cupertino,
    ),
    // common
    // role-selection
    GetPage(
      name: roleSelectionRoute,
      page: () => RoleSelectionScreen(),
      transition: Transition.cupertino,
    ),
    // phone-entry
    GetPage(
      name: phoneEnterRoute,
      page: () => const PhoneEntryScreen(),
      transition: Transition.cupertino,
    ),
    // otp-verification
    GetPage(
      name: otpVerificationRoute,
      page: () => OTPVerificationScreen(),
      transition: Transition.cupertino,
    ),

    // admin
    // add-object
    GetPage(
      name: addObjectRoute,
      page: () => AddObjectScreen(),
      transition: Transition.cupertino,
    ),
    // admin-layout
    GetPage(
      name: adminLayoutRoute,
      page: () => AdminLayoutScreen(),
      transition: Transition.cupertino,
      binding: AdminBindings(),
    ),
    // admin-login
    GetPage(
      name: adminLoginRoute,
      page: () => const AdminLoginScreen(),
      transition: Transition.cupertino,
    ),
    // admin-register
    GetPage(
      name: adminRegisterRoute,
      page: () => const AdminRegisterScreen(),
      transition: Transition.cupertino,
    ),
    // admin-home
    GetPage(
      name: adminHomeRoute,
      page: () => const AdminHomeScreen(),
      transition: Transition.cupertino,
    ),
    // admin-logs
    GetPage(
      name: adminLogsRoute,
      page: () => const AdminLogsScreen(),
      transition: Transition.cupertino,
    ),
    // admin-settings
    GetPage(
      name: adminSettingsRoute,
      page: () => const AdminSettingsScreen(),
      transition: Transition.cupertino,
    ),
    // manage-users
    GetPage(
      name: manageUsersRoute,
      page: () => const ManageUsersScreen(),
      transition: Transition.cupertino,
    ),
    // manage-devices
    GetPage(
      name: manageDevicesRoute,
      page: () => const ManageDevicesScreen(),
      transition: Transition.cupertino,
    ),
    // edit-admin
    GetPage(
      name: editAdminRoute,
      page: () => const EditAdminScreen(),
      transition: Transition.cupertino,
    ),
    // group-users
    GetPage(
        name: groupUsersRoute,
        page: () => const GroupUsersScreen(),
        transition: Transition.cupertino),
    // user
    // user-layout
    GetPage(
      name: userLayoutRoute,
      page: () => UserLayoutScreen(),
      transition: Transition.cupertino,
      binding: UserBindings(),
    ),
    // user-login
    GetPage(
      name: userLoginRoute,
      page: () => const UserLoginScreen(),
      transition: Transition.cupertino,
    ),
    // user-home
    GetPage(
      name: userHomeRoute,
      page: () => const UserHomeScreen(),
      transition: Transition.cupertino,
    ),
    // user-settings
    GetPage(
      name: userSettingsRoute,
      page: () => const UserSettingsScreen(),
      transition: Transition.cupertino,
    ),
    // edit-user
    GetPage(
      name: editUserRoute,
      page: () => const EditUserScreen(),
      transition: Transition.cupertino,
    ),
  ];
}
