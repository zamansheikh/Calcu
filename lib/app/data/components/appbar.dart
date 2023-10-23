import 'package:calcu/app/data/constants/app_string.dart';
import 'package:calcu/app/data/styles/theme_service.dart';
import 'package:calcu/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppBarCustom extends StatefulWidget implements PreferredSizeWidget {
  const AppBarCustom({Key? key}) : super(key: key);

  @override
  State<AppBarCustom> createState() => _AppBarCustomState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarCustomState extends State<AppBarCustom> {
  final controller = Get.find<HomeController>();
  final ThemeService themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (HomeController controller) {
        return AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0,
          title: Text(
            'Calcu',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Get.defaultDialog(
                  title: 'About',
                  content: const Text(
                    AppString.aboutInfo,
                  ),
                  textConfirm: 'OK',
                  confirmTextColor:
                      Theme.of(context).colorScheme.inversePrimary,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  onConfirm: () {
                    Get.back();
                    HapticFeedback.heavyImpact();
                  });
            },
            icon: Icon(
              Icons.info,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                themeService.toggleTheme();
                HapticFeedback.lightImpact();
              },
              icon: Get.isDarkMode
                  ? Icon(
                      Icons.brightness_4,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    )
                  : Icon(
                      Icons.dark_mode,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
            ),
          ],
          centerTitle: true,
        );
      },
    );
  }
}
