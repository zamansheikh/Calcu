import 'package:calcu/utils/theme/custom_theme/appbar_theme.dart';
import 'package:calcu/utils/theme/custom_theme/bottomsheet_theme.dart';
import 'package:calcu/utils/theme/custom_theme/checkbox_theme.dart';
import 'package:calcu/utils/theme/custom_theme/chip_theme.dart';
import 'package:calcu/utils/theme/custom_theme/elevated_button_theme.dart';
import 'package:calcu/utils/theme/custom_theme/outline_button_theme.dart';
import 'package:calcu/utils/theme/custom_theme/text_field_theme.dart';
import 'package:calcu/utils/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';


class MAppTheme {
  MAppTheme._();
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    textTheme: MTextTheme.lightTextTheme,
    elevatedButtonTheme: MElevatedButtonTheme.getElevatedButtonThemeLight,
    chipTheme: MChipTheme.chipThemelight,
    appBarTheme: MAppBarTheme.appBarThemeLight,
    checkboxTheme: MCheckBoxTheme.checkboxThemeLight,
    bottomSheetTheme: MBottomSheetTheme.bottomSheetThemeLight,
    outlinedButtonTheme: MOutlineButtonTheme.outlinedButtonThemeLight,
    inputDecorationTheme: MTextFormFieldTheme.inputDecorationThemeLight,
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    textTheme: MTextTheme.darkTextTheme,
    elevatedButtonTheme: MElevatedButtonTheme.getElevatedButtonThemeDark,
    chipTheme: MChipTheme.chipThemeDark,
    appBarTheme: MAppBarTheme.appBarThemeDark,
    checkboxTheme: MCheckBoxTheme.checkboxThemeDark,
    bottomSheetTheme: MBottomSheetTheme.bottomSheetThemeDark,
    outlinedButtonTheme: MOutlineButtonTheme.outlinedButtonThemeDark,
    inputDecorationTheme: MTextFormFieldTheme.inputDecorationThemeDark,
  );
}
