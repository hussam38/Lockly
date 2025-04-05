import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/user_controller.dart';

import '../../utils/colors.dart';

class UserLayoutScreen extends StatelessWidget {
  UserLayoutScreen({super.key});
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (userController.pages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return Scaffold(
        body: SafeArea(
            child: userController.pages[userController.currentIndex.value]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: userController.currentIndex.value,
          onTap: (i) {
            userController.changePage(i);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: ColorManager.primarycolor,
          unselectedItemColor: ColorManager.grey1,
          elevation: 0.0,
          enableFeedback: false,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      );
    });
  }
}
