import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/calcu_palette.dart';
import 'animated_tap.dart';
import 'math/math_label.dart';

enum CalculatorButtonStyle { number, special, operator, equals, clear }

/// Stateless, theme-aware calculator key. Visual properties are derived from
/// the active `CalcuPalette` so swapping themes never requires touching this
/// widget.
///
/// A key shows one of [label] (plain text), [icon], or [math] — expression
/// source typeset the way the display would draw it, so a structure key
/// looks like the structure it inserts.
class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    super.key,
    required this.onTap,
    this.label,
    this.icon,
    this.math,
    this.hint,
    this.semanticLabel,
    this.onLongPress,
    this.repeat = false,
    this.dense = false,
    this.style = CalculatorButtonStyle.number,
    this.flex = 1,
  });

  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? label;
  final IconData? icon;
  final String? math;

  /// What a long press does, shown small in the key's corner.
  final String? hint;

  /// Spoken name for keys whose face is a glyph rather than readable text.
  final String? semanticLabel;

  /// Holding the key repeats [onTap] instead of calling [onLongPress].
  final bool repeat;

  /// Smaller face, for the slim control row above the grid.
  final bool dense;
  final CalculatorButtonStyle style;
  final int flex;

  ({Color background, Color foreground}) _colors(CalcuPalette p) {
    switch (style) {
      case CalculatorButtonStyle.number:
        return (background: p.numberButton, foreground: p.numberButtonText);
      case CalculatorButtonStyle.special:
        return (background: p.specialButton, foreground: p.specialButtonText);
      case CalculatorButtonStyle.operator:
        return (background: p.operatorButton, foreground: p.operatorButtonText);
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
      child: Semantics(
        button: true,
        label: semanticLabel,
        excludeSemantics: semanticLabel != null,
        // The gap between keys is inside the tap target, so a press that
        // lands between two keys still goes to the nearer one.
        child: AnimatedTap(
          onTap: onTap,
          onLongPress: onLongPress,
          repeat: repeat,
          child: Padding(
            padding: EdgeInsets.all(dense ? 4.r : 4.5.r),
            child: Container(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(dense ? 16.r : 20.r),
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: Padding(
                      padding: _facePadding(),
                      child: _face(colors.foreground),
                    ),
                  ),
                  if (hint != null)
                    Positioned(
                      top: dense ? 4.r : 7.r,
                      right: dense ? 8.r : 10.r,
                      child: Text(
                        hint!,
                        style: TextStyle(
                          color: colors.foreground.withValues(alpha: 0.75),
                          fontFamily: 'Urbanist',
                          fontSize: dense ? 10.5.sp : 11.5.sp,
                          fontWeight: FontWeight.w700,
                          height: 1,
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

  EdgeInsets _facePadding() {
    if (math == null) {
      return EdgeInsets.symmetric(horizontal: 4.r, vertical: 5.r);
    }
    // A typeset face can be as wide as the key, so keep it clear of the
    // edges. If the key also has a hint, the face sits a little lower and
    // leaves the top-right corner to it.
    if (hint == null) {
      return EdgeInsets.symmetric(horizontal: 9.r, vertical: 5.r);
    }
    return EdgeInsets.fromLTRB(12.r, 12.r, 12.r, 4.r);
  }

  Widget _face(Color foreground) {
    if (icon != null) {
      return Icon(icon, size: dense ? 24.sp : 26.sp, color: foreground);
    }
    final math = this.math;
    if (math != null) {
      // Scale down rather than overflow: a stacked fraction is taller than a
      // digit, and a logarithm wider.
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: MathLabel(
          math,
          fontSize: dense ? 23.sp : 27.sp,
          color: foreground,
        ),
      );
    }
    return Text(
      label ?? '',
      style: TextStyle(
        color: foreground,
        fontFamily: 'Urbanist',
        fontSize: _fontSize(),
        fontWeight: _fontWeight(),
        height: 1,
      ),
    );
  }

  double _fontSize() {
    if (dense) return 19.sp;
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
      default:
        return FontWeight.w600;
    }
  }
}
