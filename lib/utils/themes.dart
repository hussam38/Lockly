import 'package:flutter/material.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/font_manager.dart';
import 'package:graduation_project/utils/style_manager.dart';
import 'package:graduation_project/utils/values_manager.dart';

ThemeData whiteTheme() {
  return ThemeData(
      useMaterial3: true,
      primaryColor: ColorManager.primarycolor,
      scaffoldBackgroundColor: ColorManager.white,
      //appbar theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        color: ColorManager.white,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: ColorManager.black,
        ),
      ),

      //text theme
      textTheme: TextTheme(
        displayLarge:
            getBoldStyle(color: ColorManager.grey, fontSize: FontSize.s30),
        displayMedium:
            getSemiBoldStyle(color: ColorManager.grey, fontSize: FontSize.s25),
        headlineLarge:
            getBoldStyle(color: ColorManager.grey, fontSize: FontSize.s32),
        headlineMedium:
            getSemiBoldStyle(color: ColorManager.grey, fontSize: FontSize.s16),
        titleMedium:
            getMediumStyle(color: ColorManager.grey, fontSize: FontSize.s12),
        labelMedium:
            getBoldStyle(color: ColorManager.grey, fontSize: FontSize.s18),
        labelSmall:
            getLightStyle(color: ColorManager.grey, fontSize: FontSize.s12),
        titleSmall:
            getRegularStyle(color: ColorManager.grey, fontSize: FontSize.s16),
        bodyMedium:
            getRegularStyle(color: ColorManager.grey, fontSize: FontSize.s15),
        bodyLarge:
            getRegularStyle(color: ColorManager.grey, fontSize: FontSize.s18),
        bodySmall:
            getRegularStyle(color: ColorManager.grey, fontSize: FontSize.s14),
      ),

      //input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        /// content padding
        contentPadding: const EdgeInsets.all(AppPadding.p8),

        /// hint style
        hintStyle:
            getRegularStyle(color: ColorManager.black, fontSize: AppSize.s14),

        ///label style
        labelStyle:
            getMediumStyle(color: ColorManager.black, fontSize: AppSize.s14),

        /// error style
        errorStyle: getRegularStyle(color: ColorManager.error),

        /// enabled border style
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorManager.grey1, width: AppSize.s2),
          borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
        ),

        /// focused border style
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorManager.black, width: AppSize.s2),
          borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
        ),

        /// error border style
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorManager.black, width: AppSize.s2),
          borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
        ),

        /// focused error border style
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorManager.error, width: AppSize.s2),
          borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
        ),
      ));
}

ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    primaryColor: ColorManager.primarycolor,
  );
}
