import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/utils/router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
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

  PhoneNumber phone = PhoneNumber(isoCode: 'EG');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              buildPhoneField(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onTap,
        extendedPadding: EdgeInsets.all(AppPadding.p30.w),
        label: Text(
          AppStrings.next,
          style: Theme.of(context).textTheme.headlineMedium,
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

  Widget buildPhoneField() {
    return InternationalPhoneNumberInput(
      onInputChanged: (phone) {
        setState(() {
          this.phone = phone;
        });
      },
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.DROPDOWN,
      ),
      ignoreBlank: false,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      initialValue: phone,
      textFieldController: phoneController,
      inputBorder: const OutlineInputBorder(),
      validator: (value) {
        if (value!.isEmpty || value.length < 11) {
          return AppStrings.phoneError;
        } else if (!value.startsWith("01") || value.length > 11) {
          return AppStrings.notValidNumber;
        }
        return null;
      },
      countries: const ['EG', 'SA'], // Optional: Limit countries
    );
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
