
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/auth_controller.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/values_manager.dart';

import '../../services/helpers.dart';
import '../../utils/components.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  _AdminRegisterScreenState createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(AppPadding.p20.w),
          color: ColorManager.white,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: AppPadding.p20.w),
                    child: Text(
                      'Sign Up',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  SizedBox(
                    height: size.width * .25.h,
                    child: textFormComponent(
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      prefixIcon: Icons.person,
                      onChanged: (value) {
                        nameController.text = value;
                      },
                      context: context,
                      labelText: 'Name',
                      hintText: 'e.g. hussam959',
                      validate: (value) {
                        if (value!.isEmpty) {
                          return "name can't be empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.width * .25.h,
                    child: textFormComponent(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_rounded,
                      onChanged: (value) {
                        emailController.text = value;
                      },
                      context: context,
                      hintText: 'e.g. name@mail.com',
                      labelText: 'Email',
                      validate: (value) {
                        if (value!.isEmpty) {
                          return "email can't be empty";
                        } else if (!isValidEmail(value)) {
                          return "please enter a valid email";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.width * .25.h,
                    child: textFormComponent(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.call,
                      onChanged: (value) {},
                      context: context,
                      hintText: 'e.g. 01555155115',
                      labelText: 'phone',
                      validate: (value) {
                        if (value!.isEmpty) {
                          return "phone can't be empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.width * .25.h,
                    child: textFormComponent(
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (value) {
                        passwordController.text = value;
                      },
                      prefixIcon: Icons.lock,
                      suffixIcon: Icons.visibility,
                      context: context,
                      hintText: 'e.g. Gg@123456',
                      labelText: 'Password',
                      isPassword: true,
                      validate: (value) {
                        if (value!.isEmpty) {
                          return "password can't be empty";
                        } else if (value.length < 8) {
                          return "password must be at least 8 characters";
                        } else if (!isStrongPassword(value)) {
                          return "please enter a strong password";
                        }
                        return null;
                      },
                    ),
                  ),
                  Obx(
                    () => Center(
                      child: buttonComponent2(
                        child: !authController.isLoading.value
                            ? Text(
                                'Sign Up',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: ColorManager.white,
                                        fontSize: 20.0.w),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  color: ColorManager.white,
                                ),
                              ),
                        onPressed: () async{                          
                          if (formKey.currentState!.validate()) {
                            await authController.registerUser(
                              email: emailController.text.trim(),
                              name: nameController.text.trim(),
                              password: passwordController.text.trim(),
                              phone: phoneController.text.trim(),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
