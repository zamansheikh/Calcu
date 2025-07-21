import 'package:calcu/core/widgets/app_info_dialog.dart';
import 'package:calcu/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            builder: (context) => const AppInfoDialog(),
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
