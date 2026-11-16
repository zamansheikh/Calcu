import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'button_grid.dart';
import 'expression_display.dart';
import 'keypad_toolbar.dart';
import 'result_display.dart';

/// The calculator itself: display, result, toolbar and keypad, sharing out
/// the height they are given.
///
/// Reads its state from the nearest `CalculatorProvider` and its colours from
/// the ambient theme, so the same widget is both the home screen and, scaled
/// down under another theme, the preview in the theme picker.
class CalculatorBody extends StatelessWidget {
  const CalculatorBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.r),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.r),
              child: const ExpressionDisplay(),
            ),
          ),
          const Expanded(flex: 3, child: ResultDisplay()),
          SizedBox(height: 6.r),
          const KeypadToolbar(),
          SizedBox(height: 8.r),
          Expanded(
            flex: 15,
            child: Padding(
              padding: EdgeInsets.only(top: 4.r),
              child: const ButtonGrid(),
            ),
          ),
        ],
      ),
    );
  }
}
