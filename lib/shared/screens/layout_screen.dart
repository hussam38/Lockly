import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/app_controller.dart';
import 'package:graduation_project/utils/colors.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  final AppController appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
        if (appController.pages.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: appController.pages[appController.currentIndex.value],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: appController.bottomNavItems,
            currentIndex: appController.currentIndex.value,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: ColorManager.primarycolor,
            unselectedItemColor: ColorManager.grey1,
            elevation: 0.0,
            enableFeedback: false,
            onTap: (i) {
              appController.changePage(i);
            },
          ),
        );
      },
    );
  }
}
