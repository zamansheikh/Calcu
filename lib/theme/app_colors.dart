import 'package:calcu/theme/colors.dart';
import 'package:flutter/material.dart';

class CalcuAppColors {
  CalcuAppColors._(); // Private constructor to prevent instantiation

  // Light theme colors
  static const primaryLight =
      Color.fromARGB(255, 210, 209, 209); // Background for most screens
  static const secondaryLight = Color(0xFFE6E6E6); // Used for buttons, etc.
  static const accentLight = Color(0xFF0060E5); // Blue for buttons, etc.
  static const textLight = Color(0xFF333333); // Text color
  static const disabledLight = Color(0xFFD9D9D9); // Disabled elements

  // Dark theme colors
  static const primaryDark = Color(0xFF161A20); // Background for most screens
  static const secondaryDark = Color(0xFF242933); // Used for buttons, etc.
  static const accentDark = Color(0xFF0060E5); // Blue for buttons, etc.
  static const textDark = Color(0xFFCBE1FF); // Text color
  static const disabledDark = Color(0xFF363E4C); // Disabled elements

  // Get the appropriate color based on the current theme
  static Color get primary => Brightness.light ==
          WidgetsBinding.instance.platformDispatcher.platformBrightness
      ? primaryLight
      : primaryDark;

  static Color get secondary => Brightness.light ==
          WidgetsBinding.instance.platformDispatcher.platformBrightness
      ? secondaryLight
      : secondaryDark;

  static Color get accent => Brightness.light ==
          WidgetsBinding.instance.platformDispatcher.platformBrightness
      ? accentLight
      : accentDark;

  static Color get text => Brightness.light ==
          WidgetsBinding.instance.platformDispatcher.platformBrightness
      ? textLight
      : textDark;

  static Color get disabled => Brightness.light ==
          WidgetsBinding.instance.platformDispatcher.platformBrightness
      ? disabledLight
      : disabledDark;

  // Additional colors based on your design needs
  static const errorLight = Color(0xFFF08080); // Light-themed error color
  static const errorDark = Color(0xFFC0392B); // Dark-themed error color

  // ... Add more as needed

  static ThemeData defalultTheme = ThemeData(
    fontFamily: 'Urbanist',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.calcuBackgroundLight,
      secondary: AppColors.white,
      inversePrimary: Colors.black,
      surface: Colors.black.withOpacity(.1),
      onSurface: const Color.fromARGB(255, 217, 220, 226), //Number button color
      tertiary: const Color.fromARGB(255, 159, 167, 180), //Sp button color
      onTertiary: const Color(0xFF0060E5), //Op button color
    ),
  );
  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Urbanist',
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.calcuBackground,
      secondary: AppColors.black,
      inversePrimary: Colors.white,
      surface: Colors.white.withOpacity(.1),
      onSurface: const Color(0xFF242933), //Number button color
      tertiary: const Color(0xFF363E4C), //Sp button color
      onTertiary: const Color(0xFF0060E5), //Op button color
    ),
  );
}
