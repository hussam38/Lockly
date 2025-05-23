import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/user_controller.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/router.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  _UserSettingsScreenState createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  bool isDarkTheme = false;
  bool isNotificationsEnabled = true;
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        backgroundColor: ColorManager.white,
        elevation: 20.0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SizedBox(height: 20.h),
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0.w),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.pink,
                    radius: 30.0.w,
                  ),
                  SizedBox(width: 16.0.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userController.currentUser.value!.name,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        SizedBox(height: 4.0.h),
                        Text(
                          userController.currentUser.value!.email,
                          style: Theme.of(context).textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.0.h),
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0.w),
            ),
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.lock, color: ColorManager.primarycolor),
                  title: Text(
                    'Edit Information',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Get.toNamed(AppRouter.editUserRoute);
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: Text(
                    'Dark Theme',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  value: isDarkTheme,
                  onChanged: (bool value) {
                    setState(() {
                      isDarkTheme = value;
                    });
                  },
                  secondary: const Icon(Icons.brightness_6,
                      color: ColorManager.primarycolor),
                ),
                const Divider(),
                SwitchListTile(
                  title: Text(
                    'Enable Notifications',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  value: isNotificationsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      isNotificationsEnabled = value;
                    });
                  },
                  secondary: const Icon(Icons.notifications,
                      color: ColorManager.primarycolor),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: Text(
                    'Logout',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await userController.logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
