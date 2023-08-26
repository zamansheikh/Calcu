import 'package:calcu/controllers/theme_controller.dart';
import 'package:calcu/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/app_routes.dart';
import 'config/app_strings.dart';

void main() {
  Get.put(ThemeController());
  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends GetView<ThemeController> {
  MyApp({super.key});

  ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      
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
      getPages: AppRoutes.getPages,
    );
  }
}
