
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/utils/router.dart';
import 'package:graduation_project/utils/themes.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          theme: whiteTheme(),
          locale: Get.deviceLocale,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRouter.initRoute,
          getPages: AppRouter.routes,
        );
      },
    );
  }
}
