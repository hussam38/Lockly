import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/auth_controller.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/font_manager.dart';
import 'package:graduation_project/utils/router.dart';
import 'package:graduation_project/utils/values_manager.dart';

class RoleSelectionScreen extends StatelessWidget {
  RoleSelectionScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppPadding.p20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Choose Your Role',
                style: Theme.of(context).textTheme.displayLarge),
            SizedBox(height: 8.h),
            Text(
              'Please select whether you want to login as an Admin or a User.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 30.h),
            _buildRoleButton(
              context,
              title: 'Admin',
              color: ColorManager.primarycolor,
              icon: Icons.admin_panel_settings,
              onTap: () {
                authController.loginRole('admin');
                Get.offNamed(AppRouter.adminLoginRoute);
              },
            ),
            SizedBox(height: 20.h),
            _buildRoleButton(
              context,
              title: 'User',
              color: ColorManager.green,
              icon: Icons.person,
              onTap: () {
                authController.loginRole('user');
                Get.offNamed(AppRouter.userLoginRoute);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context, {
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24, color: Colors.white),
        label: Text(title, style: const TextStyle(fontSize: FontSize.s18)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: FontSize.s16),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.s10),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
