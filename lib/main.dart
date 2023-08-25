import 'package:calcu/controllers/theme_controller.dart';
import 'package:calcu/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/app_routes.dart';
import 'config/app_strings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final themeController = Get.put(ThemeController());
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // ignore: void_checks
      initialBinding: BindingsBuilder(() => Get.put(ThemeController())),
      theme: ThemeData(
        fontFamily: AppStrings.fontFamily,
        scaffoldBackgroundColor: themeController.isNightMode.value
            ? AppColors.calcuBackground
            : AppColors.calcuBackgroundLight,
        brightness: themeController.isNightMode.value
            ? Brightness.dark
            : Brightness.light,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.pages,
    );
  }
}
