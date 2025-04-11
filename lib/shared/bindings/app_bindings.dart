import 'dart:developer';

import 'package:get/get.dart';
import 'package:graduation_project/controller/auth_controller.dart';

import '../../controller/logs_controller.dart';
import '../../services/prefs.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() async {
    await Get.putAsync(() => SharedPrefsService().init());
    Get.lazyPut(() => AuthController(), fenix: true);
    // Get.lazyPut(() => LogsController(), fenix: true);

    log("App Bindings initialized");
  }
}
