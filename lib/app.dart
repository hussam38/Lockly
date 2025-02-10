import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// import 'package:graduation_project/shared/screens/layout_screen.dart';
import 'package:graduation_project/utils/router.dart';
import 'package:graduation_project/utils/themes.dart';
// import 'package:graduation_project/view/admin/admin_home.dart';
// import 'package:graduation_project/view/admin/admin_settings.dart';
// import 'package:graduation_project/view/admin/admin_home.dart';
// import 'package:graduation_project/view/admin/admin_settings.dart';

class LocklyApp extends StatefulWidget {
  const LocklyApp({super.key});

  @override
  State<LocklyApp> createState() => _LocklyAppState();
}

class _LocklyAppState extends State<LocklyApp> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ScreenUtilInit(
      designSize: Size(size.width, size.height),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          theme: whiteTheme(),
          locale: const Locale('en', 'US'),
          debugShowCheckedModeBanner: false,
          initialRoute: AppRouter.initRoute,
          getPages: AppRouter.routes,
        );
      },
    );
  }
}
