import 'package:calcu/core/constants/app_string.dart';
import 'package:calcu/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AppBarCustom extends StatefulWidget implements PreferredSizeWidget {
  const AppBarCustom({super.key});

  @override
  State<AppBarCustom> createState() => _AppBarCustomState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarCustomState extends State<AppBarCustom> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
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
                  "About Calcu App",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                content: Text(
                  AppString.aboutInfo,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 18.sp,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      HapticFeedback.heavyImpact();
                    },
                    style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary),
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
        Consumer<ThemeProvider>(builder: (context, themeService, _) {
          return IconButton(
            onPressed: () {
              themeService.toggleTheme();
              HapticFeedback.lightImpact();
            },
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          );
        }),
      ],
      centerTitle: true,
    );
  }
}
