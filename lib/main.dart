import 'package:calcu/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/app_routes.dart';
import 'config/app_strings.dart';
import 'config/app_variable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        fontFamily: AppStrings.fontFamily,
        scaffoldBackgroundColor:
            isDark ? AppColors.calcuBackground : AppColors.calcuBackgroundLight,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.pages,
    );
  }
}


// MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   theme: ThemeData(
    //     fontFamily: AppStrings.fontFamily,
    //     scaffoldBackgroundColor:
    //         isDark ? AppColors.calcuBackground : AppColors.calcuBackgroundLight,
    //     brightness: isDark ? Brightness.dark : Brightness.light,
    //   ),
    //   home:
    // );