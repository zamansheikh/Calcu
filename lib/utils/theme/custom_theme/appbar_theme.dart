import 'package:flutter/material.dart';

class MAppBarTheme {
  MAppBarTheme._();
  static AppBarTheme appBarThemeLight = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: const IconThemeData(
      color: Colors.black,
      size: 24,
    ),
    actionsIconTheme: const IconThemeData(
      color: Colors.black,
      size: 24,
    ),
    titleTextStyle: const TextStyle().copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  );

  static AppBarTheme appBarThemeDark = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: const IconThemeData(
      color: Colors.black,
      size: 24,
    ),
    actionsIconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),
    titleTextStyle: const TextStyle().copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );
}
