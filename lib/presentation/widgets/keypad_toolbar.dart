import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../theme/calcu_palette.dart';
import '../providers/calculator_provider.dart';
import 'animated_tap.dart';
import 'saved_values_strip.dart';

/// The row between the display and the keypad: saved results on the left,
/// the control that moves the caret through the expression on the right.
///
/// Both sit flush with the outer edges of the keys below, and share one
/// height and corner radius so the row reads as a single strip.
class KeypadToolbar extends StatelessWidget {
  const KeypadToolbar({super.key});

  /// Height of the chips and of the caret control.
  static double get itemHeight => 36.r;
  static double get itemRadius => 12.r;

  /// How far the keys are inset from the edge of the keypad.
  static double get edgeInset => 4.5.r;

  @override
  Widget build(BuildContext context) {
    final calc = context.read<CalculatorProvider>();
    return SizedBox(
      height: itemHeight,
      child: Row(
        children: [
          const Expanded(child: SavedValuesStrip()),
          SizedBox(width: 10.r),
          _CaretControl(
            onLeft: calc.moveCursorLeft,
            onRight: calc.moveCursorRight,
          ),
          SizedBox(width: edgeInset),
        ],
      ),
    );
  }
}

/// Two arrows in one pill, split by a hairline. Each half repeats while held.
class _CaretControl extends StatelessWidget {
  const _CaretControl({required this.onLeft, required this.onRight});

  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Widget half(IconData icon, String label, VoidCallback onTap) {
      return Expanded(
        child: Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: AnimatedTap(
            onTap: onTap,
            repeat: true,
            scale: 0.9,
            child: Center(
              child: Icon(
                icon,
                size: 22.sp,
                color: palette.specialButtonText,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 96.r,
      height: KeypadToolbar.itemHeight,
      decoration: BoxDecoration(
        color: palette.specialButton,
        borderRadius: BorderRadius.circular(KeypadToolbar.itemRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          half(Icons.chevron_left_rounded, 'Move left', onLeft),
          Container(
            width: 1,
            margin: EdgeInsets.symmetric(vertical: 9.r),
            color: palette.specialButtonText.withValues(alpha: 0.18),
          ),
          half(Icons.chevron_right_rounded, 'Move right', onRight),
        ],
      ),
    );
  }
}
