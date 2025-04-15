import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/auth_controller.dart';
import 'package:graduation_project/services/helpers.dart';
import 'package:graduation_project/utils/components.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      authController.changePassword(_passwordController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 16.0.h),
                SizedBox(
                  height: size.width * .25.h,
                  child: textFormComponent(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock,
                      onChanged: (value) {
                        _passwordController.text = value;
                      },
                      validate: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        } else if (value.length < 8) {
                          return 'Password must be at least 6 characters long';
                        } else if (!isStrongPassword(value)) {
                          return 'password must be Strong';
                        }
                        return null;
                      },
                      context: context,
                      hintText: 'e.g Gg@12345',
                      labelText: 'Password',
                      isPassword: true,
                      suffixIcon: Icons.visibility,
                      width: double.infinity),
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
