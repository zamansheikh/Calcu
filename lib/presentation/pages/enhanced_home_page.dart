import 'package:calcu/core/widgets/appbar.dart';
import 'package:calcu/core/widgets/enhanced_button_rows.dart';
import 'package:calcu/core/widgets/working_cursor_input_view.dart';
import 'package:calcu/core/widgets/enhanced_result_view.dart';
import 'package:calcu/core/widgets/enhanced_saved_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EnhancedHomePage extends StatefulWidget {
  const EnhancedHomePage({super.key});

  @override
  State<EnhancedHomePage> createState() => _EnhancedHomePageState();
}

class _EnhancedHomePageState extends State<EnhancedHomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: const AppBarCustom(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(
            children: [
              // Input display with cursor functionality
              Expanded(
                flex: 2,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: const WorkingCursorInputView(),
                ),
              ),

              SizedBox(height: 10.sp),

              // Result display
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: const EnhancedResultView(),
                ),
              ),

              SizedBox(height: 10.sp),

              // Saved values display
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: const EnhancedSavedView(),
                ),
              ),

              SizedBox(height: 10.sp),

              // Calculator buttons
              Expanded(
                flex: 6,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: const Column(
                    children: [
                      Expanded(child: EnhancedButtonRow1()),
                      Expanded(child: EnhancedButtonRow2()),
                      Expanded(child: EnhancedButtonRow3()),
                      Expanded(child: EnhancedButtonRow4()),
                      Expanded(child: EnhancedButtonRow5()),
                      Expanded(child: EnhancedButtonRow6()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
