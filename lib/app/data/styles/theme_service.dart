import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxController {
  final GetStorage _getStorage = GetStorage();

  ThemeMode get themeMode => _getStorage.read('themeMode') ?? ThemeMode.system;

  void setThemeMode(ThemeMode themeMode) {
    _getStorage.write('themeMode', themeMode);
    Get.changeThemeMode(themeMode);
  }
}