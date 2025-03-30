import 'package:get/get.dart';

import '../../controller/admin_controller.dart';

class AdminBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminController(), fenix: true);
  }
}
