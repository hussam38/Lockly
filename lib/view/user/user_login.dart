import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/components.dart';
import 'package:graduation_project/utils/values_manager.dart';
import '../../utils/router.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  _UserLoginScreenState createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _transform;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    )..addListener(() {
        setState(() {});
      });

    _transform = Tween<double>(begin: 2, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastLinearToSlowEaseIn,
      ),
    );

    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    log("Disposed Admin Login Controller");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        height: size.height.h,
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ColorManager.primarycolor, ColorManager.green],
            ),
          ),
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _transform.value,
              child: SafeArea(
                child: Container(
                  width: size.width * .9.w,
                  height: size.width.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSize.s14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppPadding.p12),
                        child: Text(
                          'Sign In',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      SizedBox(
                        height: size.width * .1.h,
                      ),
                      textFormComponent(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_rounded,
                        onChanged: (value) {},
                        context: context,
                        hintText: 'Email',
                        isPassword: false,
                        validate: (value) {
                          return "";
                        },
                      ),
                      SizedBox(
                        height: size.width * .1,
                      ),
                      textFormComponent(
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        prefixIcon: Icons.lock,
                        suffixIcon: Icons.visibility,
                        onChanged: (value) {},
                        context: context,
                        hintText: 'password',
                        isPassword: true,
                        validate: (value) {
                          return "";
                        },
                      ),
                      SizedBox(
                        height: size.width * .1.h,
                      ),
                      buttonComponent(
                        'LOGIN',
                        context,
                        2,
                        () {
                          Get.toNamed(AppRouter.phoneEnterRoute);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
