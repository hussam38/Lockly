import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/auth_controller.dart';
import 'package:graduation_project/shared/extensions.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/components.dart';
import 'package:graduation_project/utils/values_manager.dart';

import '../../services/helpers.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  _UserLoginScreenState createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
                      'Sign In',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  SizedBox(
                    height: size.width * .25.h,
                    child: textFormComponent(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_rounded,
                      onSaved: (value) {
                        emailController.text = value.orEmpty();
                      },
                      context: context,
                      hintText: 'e.g. name@mail.com',
                      labelText: 'Email',
                      isPassword: false,
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
                  Obx(() => SizedBox(
                        height: size.width * .25.h,
                        child: textFormComponent(
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          onSaved: (value) {
                            passwordController.text = value.orEmpty();
                          },
                          prefixIcon: Icons.lock,
                          suffixIcon: authController.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          context: context,
                          hintText: 'e.g. Gg@123456',
                          labelText: 'Password',
                          isPassword: !authController.isPasswordVisible.value,
                          onSuffixPressed:
                              authController.togglePasswordVisibility,
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
                      )),
                  Obx(
                    () => Center(
                      child: buttonComponent2(
                        child: !authController.isLoading.value
                            ? Text(
                                'Sign In',
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
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            await authController.loginUser(
                                emailController.text, passwordController.text);
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
