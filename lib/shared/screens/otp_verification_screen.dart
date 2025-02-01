import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../utils/colors.dart';
import '../../utils/font_manager.dart';
import '../../utils/router.dart';
import '../../utils/strings_manager.dart';
import '../../utils/values_manager.dart';

class OTPVerificationScreen extends StatelessWidget {
  OTPVerificationScreen({super.key});

  String phoneNumber = Get.arguments["phoneNumber"];
  String country = Get.arguments["country"];
  final codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p12, vertical: AppPadding.p12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildFirstTextSection(context),
            SizedBox(height: AppSize.s50.h),
            buildSecondTextSection(context),
            SizedBox(height: AppSize.s50.h),
            buildPinField(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onTap,
        extendedPadding: EdgeInsets.all(AppPadding.p30.w),
        label: Text(
          AppStrings.verify,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }

  Widget buildFirstTextSection(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p12, vertical: AppPadding.p12),
      child: Text(
        AppStrings.verifyMessage,
        style: Theme.of(ctx)
            .textTheme
            .titleMedium!
            .copyWith(color: ColorManager.black, fontSize: FontSize.s20),
      ),
    );
  }

  Widget buildSecondTextSection(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p14),
      child: RichText(
        text: TextSpan(
            text: AppStrings.verifyCond,
            style: Theme.of(ctx).textTheme.bodyMedium!.copyWith(height: 1.4),
            children: [
              TextSpan(
                text: country == 'EG' ? "+2$phoneNumber" : "+$phoneNumber",
                style: Theme.of(ctx).textTheme.bodyMedium!.copyWith(
                      color: ColorManager.primarycolor,
                    ),
              ),
            ]),
      ),
    );
  }

  Widget buildPinField(BuildContext ctx) {
    return PinCodeTextField(
      appContext: ctx,
      enablePinAutofill: true,
      keyboardType: TextInputType.phone,
      useExternalAutoFillGroup: true,
      length: 6,
      obscureText: false,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(AppSize.s12),
        fieldHeight: 50,
        fieldWidth: 40,
        activeFillColor: Colors.white,
        selectedFillColor: Colors.blue.withOpacity(.1),
        inactiveFillColor: Colors.blueAccent.withOpacity(.1),
        activeColor: Colors.blue,
        inactiveColor: Colors.black,
      ),
      animationDuration: const Duration(milliseconds: 300),
      backgroundColor: Colors.white,
      cursorColor: ColorManager.black,
      enableActiveFill: true,
      controller: codeController,
      onCompleted: (v) {},
      onChanged: (value) {
        log(value);
      },
    );
  }

  void onTap() {
    Get.offAllNamed(AppRouter.layout);
  }
}
