import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxController {
  final GetStorage _getStorage = GetStorage();
  static const themeModeKey = 'themeMode';

  ThemeMode get themeMode {
    final storedTheme = _getStorage.read(themeModeKey);
    if (storedTheme == null) {
      return ThemeMode.system;
    } else {
      return themeModeFromString(storedTheme);
    }
  }

  void setThemeMode(ThemeMode themeMode) {
    final themeString = themeModeToString(themeMode);
    _getStorage.write(themeModeKey, themeString);
    Get.changeThemeMode(themeMode);
  }

  void toggleTheme() {
    final currentMode = themeMode;
    ThemeMode newMode;

    if (currentMode == ThemeMode.system) {
      newMode = ThemeMode.light;
    } else if (currentMode == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else {
      newMode = ThemeMode.system;
    }

    // Delay the theme change to allow the UI to finish building
    Future.delayed(const Duration(milliseconds: 50), () {
      setThemeMode(newMode);
    });
  }

  // Helper function to convert ThemeMode to a string
  String themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      default:
        return 'system';
    }
  }

  // Helper function to convert a string back to ThemeMode
  ThemeMode themeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}
