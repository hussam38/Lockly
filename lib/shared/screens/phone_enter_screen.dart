import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/utils/components.dart';
import 'package:graduation_project/utils/router.dart';
import '../../utils/colors.dart';
import '../../utils/font_manager.dart';
import '../../utils/strings_manager.dart';
import '../../utils/values_manager.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  TextEditingController phoneController = TextEditingController();

  GlobalKey<FormState> formPhoneKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p12,
          vertical: AppPadding.p12,
        ),
        child: Form(
          key: formPhoneKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildFirstTextSection(context),
              SizedBox(height: AppSize.s50.h),
              buildSecondTextSection(context),
              SizedBox(height: AppSize.s50.h),
              buildTextField(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onTap,
        extendedPadding: EdgeInsets.all(AppPadding.p30.w),
        label: Text(
          AppStrings.next,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget buildFirstTextSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppPadding.p12.w),
      child: Text(
        AppStrings.ask,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: ColorManager.black, fontSize: FontSize.s20),
      ),
    );
  }

  Widget buildSecondTextSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p14.w),
      child: RichText(
        text: TextSpan(
            text: AppStrings.askDes,
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }

  Widget buildTextField(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
              labelText: '${generateCountryFlag()}  +20',
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            height: 200,
            padding: EdgeInsets.symmetric(
                horizontal: AppPadding.p12.w, vertical: AppPadding.p16.w),
            child: textFormComponent(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (value) {},
              hintText: "Phone Number",
              context: context,
              prefixIcon: Icons.phone,
              validate: (value) {
                if (value!.isEmpty || value.length < 11) {
                  return AppStrings.phoneError;
                } else if (!value.startsWith("01")) {
                  return "Not a Valid Number";
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  String generateCountryFlag() {
    String countryCode = "eg";
    String flag = countryCode.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
    return flag;
  }

  void onTap() {
    if (formPhoneKey.currentState!.validate()) {
      Get.toNamed(AppRouter.otpVerificationRoute,
          arguments: {"phoneNumber": phoneController.text});
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    log("Phone Controller disposed");
    super.dispose();
  }
}
