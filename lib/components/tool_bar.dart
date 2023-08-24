import 'package:calcu/config/app_strings.dart';
import 'package:calcu/config/app_variable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/app_colors.dart';

class ToolBar extends StatefulWidget implements PreferredSizeWidget {
  final String appBarName;
  final List<Widget>? actions;
  const ToolBar({super.key, required this.appBarName, this.actions});

  @override
  State<ToolBar> createState() => _ToolBarState();

  @override
  Size get preferredSize => const Size.fromHeight(40);
}

class _ToolBarState extends State<ToolBar> {
  @override
  void initState() {
    super.initState();
    readData();
  }

  readData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? isDarkMode = pref.getBool('isDark');
    isDark = isDarkMode ?? true;
  }

  writeData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool('isDark', isDark);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor:
            isDark ? AppColors.calcuBackground : Colors.white.withOpacity(.5),
        elevation: 0,
        centerTitle: true,
        leading:
            TextButton(onPressed: _showDialog, child: const Icon(Icons.info)),
        title: Text(
          widget.appBarName,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isDark = isDark ? false : true;
                });
              },
              icon: Icon(
                  (isDark) ? Icons.light_mode_rounded : Icons.dark_mode_sharp))
        ]);
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.calcuBackground : Colors.white.withOpacity(.5),
          title: const Text("About App"),
          content: Text(
            AppStrings.infoText,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        );
      },
    );
  }
}
