import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/components.dart';
import 'package:graduation_project/utils/router.dart';
import 'package:graduation_project/utils/values_manager.dart';

import '../../services/helpers.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

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
                      onChanged: (value) {
                        emailController.text = value;
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
                      isPassword: false,
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
                  Center(
                    child: buttonComponent(
                      child: !isLoading
                          ? Text(
                              "Sign In",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(color: ColorManager.white),
                            )
                          : CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  ColorManager.white),
                            ),
                      context,
                      2,
                      () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          Future.delayed(const Duration(seconds: 1)).then(
                              (value) =>
                                  Get.toNamed(AppRouter.phoneEnterRoute));
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a Member?",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: ColorManager.black),
                      ),
                      MaterialButton(
                        onPressed: () {
                          Get.toNamed(AppRouter.adminRegisterRoute);
                        },
                        focusNode: FocusNode(),
                        highlightColor: ColorManager.transparent,
                        splashColor: ColorManager.transparent,
                        child: Text(
                          "Sign Up",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: ColorManager.primarycolor),
                        ),
                      ),
                    ],
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
