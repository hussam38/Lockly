import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/utils/colors.dart';

import 'values_manager.dart';

Widget showProgressIndicator(BuildContext context) {
  AlertDialog dialog = const AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      ),
    ),
  );

  showDialog(
    barrierColor: Colors.white,
    barrierDismissible: false,
    context: context,
    builder: (context) => dialog,
  );
  return dialog;
}

Widget textFormComponent(
    {required TextEditingController controller,
    required TextInputType keyboardType,
    required IconData prefixIcon,
    void Function(String)? onChanged,
    required String? Function(String?)? validate,
    IconData? suffixIcon,
    required BuildContext context,
    required String hintText,
    Function(String?)? onSaved,
    void Function()? onSuffixPressed,
    TextStyle? style,
    double? width,
    double? height,
    String labelText = "",
    EdgeInsetsGeometry? padding,
    bool isPassword = false}) {
  Size size = MediaQuery.of(context).size;
  return Container(
    height: height ?? size.width / 7,
    alignment: Alignment.center,
    padding: padding ?? EdgeInsets.only(right: size.width / 30),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextFormField(
      controller: controller,
      style: Theme.of(context).textTheme.headlineSmall,
      obscureText: isPassword,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validate,
      decoration: InputDecoration(
        prefixIcon: Icon(
          prefixIcon,
          size: 24.0,
          color: Colors.black,
        ),
        suffixIcon: suffixIcon != null
            ? IconButton(
                onPressed: onSuffixPressed,
                highlightColor: ColorManager.transparent,
                icon: Icon(suffixIcon, color: Colors.black,),
              )
            : null,
        hintText: hintText,
        hintStyle: style,
        labelText: labelText,
      ),
    ),
  );
}

Widget buttonComponent(
    BuildContext context, double width, VoidCallback voidCallback,
    {required Widget? child}) {
  Size size = MediaQuery.of(context).size;
  return GestureDetector(
    onTap: voidCallback,
    child: Container(
      height: size.width / 8.h,
      width: size.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorManager.primarycolor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: child,
    ),
  );
}

Widget buttonComponent2({
  required Widget child,
  required void Function()? onPressed,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: AppPadding.p30.w),
    width: double.infinity,
    height: AppSize.s50.h,
    child: MaterialButton(
      onPressed: onPressed,
      color: ColorManager.primarycolor,
      highlightColor: ColorManager.primarycolor,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.s10.w),       
      ),
      child: child,
    ),
  );
}
