import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/utils/number_formatter.dart';
import '../../theme/calcu_palette.dart';
import '../providers/calculator_provider.dart';
import 'math/math_label.dart';

/// Live preview of the result. Long-press saves it as a chip.
///
/// A decimal is drawn as text. The fraction form (¾, √2, π/2) is expression
/// source, and is typeset by the same engine as the expression above it.
class ResultDisplay extends StatelessWidget {
  const ResultDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Consumer<CalculatorProvider>(
      builder: (context, calc, _) {
        final raw = calc.output;
        final showPlaceholder = raw.isEmpty;
        final isMath = !showPlaceholder &&
            !calc.hasError &&
            calc.resultFormat == ResultFormat.fraction;
        final formatted = showPlaceholder
            ? '0'
            : NumberFormatter.addThousandsSeparators(raw);
        final color = calc.hasError
            ? palette.error
            : showPlaceholder
                ? palette.placeholderText
                : palette.resultText;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: () => calc.saveCurrentResult(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(18.r, 4.r, 18.r, 4.r),
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: SingleChildScrollView(
                  key: ValueKey(raw),
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!showPlaceholder && !calc.hasError)
                        Padding(
                          padding: EdgeInsets.only(right: 8.r),
                          child: Text(
                            '=',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w600,
                              color: palette.placeholderText,
                            ),
                          ),
                        ),
                      if (isMath)
                        // A stacked fraction is taller than a line of
                        // digits; shrink it to the section's height if the
                        // screen is short rather than let it be clipped.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: MathLabel(
                            raw,
                            fontSize: 36.sp,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        )
                      else
                        Text(
                          formatted,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: formatted.length > 12 ? 28.sp : 34.sp,
                            fontWeight: FontWeight.w700,
                            color: color,
                            letterSpacing: -0.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
