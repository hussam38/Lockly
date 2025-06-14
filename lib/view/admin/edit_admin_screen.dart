import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/admin_controller.dart';
import 'package:graduation_project/services/helpers.dart';

class EditAdminScreen extends StatefulWidget {
  const EditAdminScreen({super.key});

  @override
  _EditAdminScreenState createState() => _EditAdminScreenState();
}

class _EditAdminScreenState extends State<EditAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AdminController adminController = Get.find<AdminController>();
  @override
  void initState() {
    super.initState();
    final admin = adminController.currentUser.value;
    if (admin != null) {
      _usernameController.text = admin.name;
      _emailController.text = admin.email;
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      await adminController.updateInfo(
        username: username.isEmpty
            ? adminController.currentUser.value?.name ?? ''
            : username,
        email: email.isEmpty
            ? adminController.currentUser.value?.email ?? ''
            : email,
        password: password, // Only update if not empty in controller
      );
      Get.snackbar(
        "Success",
        'Changes saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 16.0.h),
                TextFormField(
                  controller: _usernameController,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: const OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0.h),
                TextFormField(
                  controller: _emailController,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!isValidEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0.h),
                TextFormField(
                  controller: _passwordController,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                      labelText: 'Password (leave blank to keep current)',
                      border: const OutlineInputBorder(),
                      labelStyle: Theme.of(context).textTheme.bodyMedium),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null;
                    } else if (value.length < 8) {
                      return 'Password must be at least 6 characters long';
                    } else if (!isStrongPassword(value)) {
                      return 'password must be Strong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0.h),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
