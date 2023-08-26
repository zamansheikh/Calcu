import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  RxBool isNightMode = true.obs;
  var buttonSpaceHeight = 10.0.obs;
  themeLoadData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? isDarkMode = pref.getBool('isDark');
    print(isDarkMode);
    isNightMode.value = isDarkMode ?? true;
    update();
  }

  themeDataSave() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool('isDark', isNightMode.value);
    update();
  }
}
