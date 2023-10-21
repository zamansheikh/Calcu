import 'package:calcu/app/data/styles/app_theme.dart';
import 'package:calcu/app/data/styles/theme_service.dart';
import 'package:calcu/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(HomeController());
  final ThemeService themeService = ThemeService();
  runApp(
    GetMaterialApp(
      title: "Calcu App",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.defalultTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      debugShowCheckedModeBanner: false,
    ),
  );
}
