import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:graduation_project/utils/router.dart';
import '../../utils/asset_manager.dart';
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

  String selectedCountry = 'EG';
  String? errorText;
  final Map<String, Map<String, String>> countries = {
    'EG': {
      'code': '+20',
      'flag': AssetsManager.egIcon,
    },
    'SA': {
      'code': '+966',
      'flag': AssetsManager.saIcon,
    }
  };

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
    return Row(
      children: [
        // Dropdown for country selection with flags
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(AppSize.s5),
          ),
          child: DropdownButton<String>(
            value: selectedCountry,
            icon: const Icon(Icons.arrow_drop_down),
            underline: const SizedBox(),
            items: countries.keys.map((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      countries[country]!['flag']!,
                      width: AppSize.s24.w,
                      height: AppSize.s24.h,
                    ),
                    SizedBox(width: AppSize.s8.w),
                    Text(country),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newCountry) {
              setState(() {
                selectedCountry = newCountry!;
                phoneController
                    .clear(); // Clear the phone number when changing the country
                errorText = null; // Clear the error message
              });
            },
          ),
        ),
        SizedBox(width: 10.w),
        // TextFormField for phone number
        Expanded(
          child: TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.phone),
              hintText: AppStrings.phoneHint,
              border: const OutlineInputBorder(),
              errorText: errorText, // Display error message
            ),
            onChanged: (value) {
              setState(() {
                errorText =
                    validatePhoneNumber(value); // Update validation error
              });
            },
          ),
        ),
      ],
    );
  }

  void onTap() {
    if (formPhoneKey.currentState!.validate()) {
      Get.toNamed(AppRouter.otpVerificationRoute, arguments: {
        "phoneNumber": phoneController.text,
        "country": selectedCountry
      });
    }
  }

  String? validatePhoneNumber(String value) {
    if (value.isEmpty) {
      return AppStrings.phoneEmpty;
    }
    // Validation based on the selected country
    if (selectedCountry == 'EG') {
      if (!value.startsWith('01') || value.length != 11) {
        return AppStrings.notValidEGNumber;
      }
    } else if (selectedCountry == 'SA') {
      if (!value.startsWith('966') || value.length != 9) {
        return AppStrings.notValidSANumber;
      }
    }
    return null; // Return null if valid
  }

  @override
  void dispose() {
    phoneController.dispose();
    log("Phone Controller disposed");
    super.dispose();
  }
}
