import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_strings.dart';
import '../styles/app_colors.dart';

class ThemeController extends GetxController {
  RxBool isNightMode = true.obs;
  var buttonSpaceHeight = 10.0.obs;
  themeLoadData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? isDarkMode = pref.getBool('isDark');
    isNightMode.value = isDarkMode ?? true;
    update();
  }

  void updateThemeData(bool isDarkMode) {
    isNightMode.value = isDarkMode;
    Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
    Get.changeTheme(
      ThemeData(
        fontFamily: AppStrings.fontFamily,
        scaffoldBackgroundColor: isNightMode.value
            ? AppColors.calcuBackground
            : AppColors.calcuBackgroundLight,
        brightness: isNightMode.value ? Brightness.dark : Brightness.light,
      ),
    );
    update();
  }

  themeDataSave() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool('isDark', isNightMode.value);
    update();
  }
}
