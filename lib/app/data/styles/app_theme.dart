import 'package:calcu/app/data/styles/colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData defalultTheme = ThemeData(
    fontFamily: 'Urbanist',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.calcuBackgroundLight,
      background: AppColors.calcuBackgroundLight,
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
      background: AppColors.calcuBackground,
      secondary: AppColors.black,
      inversePrimary: Colors.white,
      surface: Colors.white.withOpacity(.1),
      onSurface: const Color(0xFF242933), //Number button color
      tertiary: const Color(0xFF363E4C), //Sp button color
      onTertiary: const Color(0xFF0060E5), //Op button color
    ),
  );
}
