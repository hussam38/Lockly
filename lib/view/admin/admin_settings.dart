import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/utils/colors.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  _AdminSettingsScreenState createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool isDarkTheme = false; 
  bool isNotificationsEnabled =
      true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: ColorManager.primarycolor,
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
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.pink,
                    radius: 30.0,
                  ),
                  SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hussam Nasser',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Hussam@mail.com', 
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock, color: ColorManager.primarycolor),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Handle change password
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.people, color: ColorManager.primarycolor),
                  title: const Text('Manage Users'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Handle manage users
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.devices, color: ColorManager.primarycolor),
                  title: const Text('Manage Devices'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Handle manage devices
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Dark Theme'),
                  value: isDarkTheme,
                  onChanged: (bool value) {
                    setState(() {
                      isDarkTheme = value;
                      // Handle theme change
                    });
                  },
                  secondary: const Icon(Icons.brightness_6, color: ColorManager.primarycolor),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  value: isNotificationsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      isNotificationsEnabled = value;
                      // Handle notification setting change
                    });
                  },
                  secondary: const Icon(Icons.notifications, color: ColorManager.primarycolor),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Logout'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Handle logout
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
