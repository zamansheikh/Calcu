import 'package:get/get.dart';

class ThemeController extends GetxController {
  var isNightMode = true.obs;

  void nightModeToggle() {
    isNightMode = isNightMode.value ? false.obs : true.obs;
    update();
  }
}
