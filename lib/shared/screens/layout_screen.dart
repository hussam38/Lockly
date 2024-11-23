import 'package:flutter/material.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/constants.dart';
import 'package:graduation_project/view/admin/admin_scene.dart';
import 'package:graduation_project/view/user/user_scene.dart';
import 'package:graduation_project/view/user/user_settings.dart';
import '../../view/admin/admin_home.dart';
import '../../view/admin/admin_settings.dart';
import '../../view/user/user_home.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  int currentIndex = 0;
  List<Widget> user_screens = [
    const UserHomeScreen(),
    const UserSceneScreen(),
    const UserSettings(),
  ];
  List<Widget> admin_screens = [
    const AdminHomeScreen(),
    const AdminSceneScreen(),
    const AdminSettingsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Constants.loginAs == 'admin'
            ? admin_screens[currentIndex]
            : user_screens[currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.edit_calendar), label: 'Scene'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ColorManager.primarycolor,
        unselectedItemColor: ColorManager.grey1,
        elevation: 0.0,
        enableFeedback: false,
        onTap: (i) {
          setState(() {
            currentIndex = i;
          });
        },
      ),
    );
  }
}
