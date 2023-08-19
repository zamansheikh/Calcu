import 'package:calcu/config/app_strings.dart';
import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: AppColors.calcuBackground,
        elevation: 0,
        centerTitle: true,
        leading:
            TextButton(onPressed: _showDialog, child: const Icon(Icons.info)),
        //leadingWidth: 70,

        title: Text(
          widget.appBarName,
        ),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.light_mode_rounded))
        ]);
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: AppColors.calcuBackground,
          title: Text("About App"),
          content: Text(AppStrings.infoText),
        );
      },
    );
  }
}
