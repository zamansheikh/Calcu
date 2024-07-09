import 'package:calcu/core/constants/app_string.dart';
import 'package:calcu/theme/app_colors.dart';
import 'package:calcu/theme/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppBarCustom extends StatefulWidget implements PreferredSizeWidget {
  const AppBarCustom({Key? key}) : super(key: key);

  @override
  State<AppBarCustom> createState() => _AppBarCustomState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarCustomState extends State<AppBarCustom> {
  final ThemeService themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: CalcuAppColors.primary,
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
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "About Calcu",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                content: Text(
                  AppString.aboutInfo,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppString.ok,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ],
                backgroundColor: Theme.of(context).colorScheme.primary,
              );
            },
          );
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
          icon:  Icon(
            themeService.isDarkMode()
                ? Icons.light_mode
                : Icons.dark_mode,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ],
      centerTitle: true,
    );
  }
}
