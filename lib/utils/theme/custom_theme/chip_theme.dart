import 'package:flutter/material.dart';

class MChipTheme {
  MChipTheme._();
  static ChipThemeData chipThemelight = ChipThemeData(
    disabledColor: Colors.grey.withOpacity(.4),
    labelStyle: const TextStyle(color: Colors.black),
    selectedColor: Colors.blue,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: Colors.white,
  );
  static ChipThemeData chipThemeDark = ChipThemeData(
    disabledColor: Colors.grey.withOpacity(.4),
    labelStyle: const TextStyle(color: Colors.white),
    selectedColor: Colors.blue,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: Colors.white,
  );
}
