import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/utils/colors.dart';

void showProgressIndicator(BuildContext context) {
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
    barrierColor: Colors.white.withOpacity(0),
    barrierDismissible: false,
    context: context,
    builder: (context) => dialog,
  );
}

Widget textFormComponent(
    {required TextEditingController controller,
    required TextInputType keyboardType,
    required IconData prefixIcon,
    required void Function(String)? onChanged,
    required String? Function(String?)? validate,
    IconData? suffixIcon,
    required BuildContext context,
    required String hintText,
    bool isPassword = false}) {
  Size size = MediaQuery.of(context).size;
  return Container(
    height: size.width / 7,
    width: size.width / 1.22,
    alignment: Alignment.center,
    padding: EdgeInsets.only(right: size.width / 30),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextFormField(
      controller: controller,
      style: Theme.of(context).textTheme.bodySmall,
      obscureText: isPassword,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validate,
      decoration: InputDecoration(
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.black.withOpacity(.7),
        ),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: () {},
                highlightColor: ColorManager.transparent,
                icon: Icon(suffixIcon),
              )
            : null,
        hintText: hintText,
      ),
    ),
  );
}

Widget buttonComponent(String string, BuildContext context, double width,
    VoidCallback voidCallback) {
  Size size = MediaQuery.of(context).size;
  return GestureDetector(
    onTap: voidCallback,
    child: Container(
      height: size.width / 8.h,
      width: size.width / width.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorManager.primarycolor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        string,
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: ColorManager.white),
      ),
    ),
  );
}
