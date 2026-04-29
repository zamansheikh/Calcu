import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/calcu_palette.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/button_grid.dart';
import '../widgets/expression_display.dart';
import '../widgets/result_display.dart';
import '../widgets/saved_values_strip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: palette.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                const AppTopBar(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.r),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.r),
                            child: const ExpressionDisplay(),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: const ResultDisplay(),
                        ),
                        SizedBox(height: 6.r),
                        const SavedValuesStrip(),
                        SizedBox(height: 8.r),
                        Expanded(
                          flex: 14,
                          child: Padding(
                            padding: EdgeInsets.only(top: 4.r),
                            child: const ButtonGrid(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
