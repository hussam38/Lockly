import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/admin_controller.dart';

import '../../utils/colors.dart';

class AdminLayoutScreen extends StatelessWidget {
  AdminLayoutScreen({super.key});
  final AdminController adminController = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (adminController.pages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return Scaffold(
        body: SafeArea(
            child: adminController.pages[adminController.currentIndex.value]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: adminController.currentIndex.value,
          onTap: (i) {
            adminController.changePage(i);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: ColorManager.primarycolor,
          unselectedItemColor: ColorManager.grey1,
          elevation: 0.0,
          enableFeedback: false,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Logs'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      );
    });
  }
}
