import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/utils/number_formatter.dart';
import '../../theme/calcu_palette.dart';
import '../providers/calculator_provider.dart';

/// Top half of the display: scrollable, tap-to-position expression with an
/// animated cursor. Long-press saves the evaluated result.
///
/// The text is rendered as a single `Text` widget inside a horizontal scroll
/// view; the cursor is overlaid via `Positioned`. Hit-testing maps the global
/// tap to the text widget's local coords (so it survives any scroll offset)
/// and we translate between the formatted display string and the raw input
/// by counting the commas inserted as thousands separators.
class ExpressionDisplay extends StatefulWidget {
  const ExpressionDisplay({super.key});

  @override
  State<ExpressionDisplay> createState() => _ExpressionDisplayState();
}

class _ExpressionDisplayState extends State<ExpressionDisplay>
    with SingleTickerProviderStateMixin {
  final GlobalKey _textKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _cursorController;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  TextStyle get _expressionStyle => TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 46.sp,
        fontWeight: FontWeight.w600,
        height: 1.1,
      );

  TextPainter _layoutPainter(String text) {
    return TextPainter(
      text: TextSpan(text: text, style: _expressionStyle),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  /// Map a position in the *formatted* string (with commas) back to the
  /// corresponding index in the *raw* input.
  int _formattedToRaw(String formatted, int formattedIndex) {
    final clamped = formattedIndex.clamp(0, formatted.length);
    var commas = 0;
    for (var i = 0; i < clamped; i++) {
      if (formatted[i] == ',') commas++;
    }
    return clamped - commas;
  }

  /// Map a raw cursor index to the corresponding index in the formatted
  /// string (used to draw the cursor at the right pixel position).
  int _rawToFormatted(String formatted, int rawIndex) {
    var rawCount = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (rawCount == rawIndex) return i;
      if (formatted[i] != ',') rawCount++;
    }
    return formatted.length;
  }

  void _handleTap(TapUpDetails details, String input) {
    final provider = context.read<CalculatorProvider>();

    if (input.isEmpty) {
      provider.moveCursor(0);
      setState(() => _focused = true);
      return;
    }

    final box = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = box.globalToLocal(details.globalPosition);
    final formatted = NumberFormatter.addThousandsSeparators(input);
    final painter = _layoutPainter(formatted);
    final pos = painter.getPositionForOffset(local);
    final rawIndex = _formattedToRaw(formatted, pos.offset);

    provider.moveCursor(rawIndex);
    setState(() => _focused = true);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Consumer<CalculatorProvider>(
      builder: (context, calc, _) {
        final input = calc.expression;
        final hasInput = input.isNotEmpty;
        final displayText = hasInput
            ? NumberFormatter.addThousandsSeparators(input)
            : '0';

        double cursorX = 0;
        double textHeight = 0;
        if (hasInput) {
          final painter = _layoutPainter(displayText);
          final formattedCursor =
              _rawToFormatted(displayText, calc.input.cursor);
          cursorX = painter
              .getOffsetForCaret(
                TextPosition(offset: formattedCursor),
                Rect.zero,
              )
              .dx;
          textHeight = painter.size.height;
        } else {
          final painter = _layoutPainter(displayText);
          cursorX = painter.size.width + 2.r;
          textHeight = painter.size.height;
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => _handleTap(details, input),
          onLongPress: () => calc.saveExpressionResult(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(18.r, 14.r, 18.r, 14.r),
            decoration: BoxDecoration(
              color: palette.displayBackground,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: palette.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                reverse: true,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  height: textHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text(
                        displayText,
                        key: _textKey,
                        style: _expressionStyle.copyWith(
                          color: hasInput
                              ? palette.expressionText
                              : palette.placeholderText,
                        ),
                      ),
                      if (_focused)
                        Positioned(
                          left: cursorX - 1.25.r,
                          top: 0,
                          bottom: 0,
                          child: _Cursor(
                            controller: _cursorController,
                            color: palette.cursor,
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

class _Cursor extends StatelessWidget {
  const _Cursor({required this.controller, required this.color});
  final Animation<double> controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: FadeTransition(
          opacity: controller,
          child: Container(
            width: 2.5.r,
            height: 40.sp,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.5.r),
            ),
          ),
        ),
      ),
    );
  }
}
