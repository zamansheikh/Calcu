import 'package:calcu/app/data/styles/app_theme.dart';
import 'package:calcu/app/data/styles/theme_service.dart';
import 'package:calcu/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(HomeController());
  final ThemeService themeService = ThemeService();
  await GetStorage.init();
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
