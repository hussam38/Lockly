import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/font_manager.dart';
import 'package:graduation_project/utils/router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future startDelay() async {
    return await Future.delayed(const Duration(seconds: 1))
        .then((value) => Get.offNamed(AppRouter.roleSelectionRoute));
  }

  @override
  void initState() {
    startDelay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primarycolor,
      body: Center(
        child: Text(
          "Lockly",
          style: Theme.of(context)
              .textTheme
              .headlineLarge!
              .copyWith(color: ColorManager.black, fontSize: FontSize.s50),
        ),
      ),
    );
  }
}
