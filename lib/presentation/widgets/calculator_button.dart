import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/calcu_palette.dart';
import 'animated_tap.dart';

enum CalculatorButtonStyle { number, special, operator, equals, clear }

/// Stateless, theme-aware calculator button. Visual properties are derived
/// from the active `CalcuPalette` so swapping themes never requires touching
/// this widget.
class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    super.key,
    required this.onTap,
    this.label,
    this.icon,
    this.onLongPress,
    this.style = CalculatorButtonStyle.number,
    this.flex = 1,
    this.subLabel,
  });

  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? label;
  final String? subLabel;
  final IconData? icon;
  final CalculatorButtonStyle style;
  final int flex;

  ({Color background, Color foreground}) _colors(CalcuPalette p) {
    switch (style) {
      case CalculatorButtonStyle.number:
        return (background: p.numberButton, foreground: p.numberButtonText);
      case CalculatorButtonStyle.special:
        return (background: p.specialButton, foreground: p.specialButtonText);
      case CalculatorButtonStyle.operator:
        return (
          background: p.operatorButton,
          foreground: p.operatorButtonText,
        );
      case CalculatorButtonStyle.equals:
        return (background: p.equalsButton, foreground: p.equalsButtonText);
      case CalculatorButtonStyle.clear:
        return (background: p.clearButton, foreground: p.clearButtonText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = _colors(palette);
    final isEmphasis = style == CalculatorButtonStyle.equals;

    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.all(5.r),
        child: AnimatedTap(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(22.r),
              boxShadow: [
                BoxShadow(
                  color: isEmphasis
                      ? colors.background.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: isEmphasis ? 16 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 26.sp, color: colors.foreground)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label ?? '',
                          style: TextStyle(
                            color: colors.foreground,
                            fontFamily: 'Urbanist',
                            fontSize: _fontSize(),
                            fontWeight: _fontWeight(),
                            height: 1,
                          ),
                        ),
                        if (subLabel != null)
                          Padding(
                            padding: EdgeInsets.only(top: 2.r),
                            child: Text(
                              subLabel!,
                              style: TextStyle(
                                color: colors.foreground.withValues(alpha: 0.6),
                                fontFamily: 'Urbanist',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  double _fontSize() {
    switch (style) {
      case CalculatorButtonStyle.equals:
        return 30.sp;
      case CalculatorButtonStyle.operator:
        return 28.sp;
      default:
        return 26.sp;
    }
  }

  FontWeight _fontWeight() {
    switch (style) {
      case CalculatorButtonStyle.equals:
      case CalculatorButtonStyle.operator:
        return FontWeight.w700;
      case CalculatorButtonStyle.number:
        return FontWeight.w600;
      default:
        return FontWeight.w600;
    }
  }
}
