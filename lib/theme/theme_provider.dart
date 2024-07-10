import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const themeModeKey = 'themeMode';
  late SharedPreferences _prefs;
  ThemeMode? _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode ?? ThemeMode.system;

  bool get isDarkMode {
    const currentMode = ThemeMode.system;
    switch (currentMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode
            .system: // Check system settings when using ThemeMode.system
        final brightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark;
      default:
        return false;
    }
  }

  Future<void> _loadThemeMode() async {
    _prefs = await SharedPreferences.getInstance();
    final storedTheme = _prefs.getString(themeModeKey);
    _themeMode = storedTheme != null
        ? _themeModeFromString(storedTheme)
        : ThemeMode.system;
    notifyListeners();
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

    _themeMode = newMode;
    _saveThemeMode(newMode);
    notifyListeners();
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(themeModeKey, _themeModeToString(mode));
  }

  // Helper function to convert ThemeMode to a string
  String _themeModeToString(ThemeMode mode) {
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
  ThemeMode _themeModeFromString(String mode) {
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
