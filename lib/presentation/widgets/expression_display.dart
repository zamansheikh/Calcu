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

  /// The style the expression is actually painted with.
  ///
  /// The ambient [DefaultTextStyle] contributes layout-affecting properties
  /// (Material 3 body text carries letter spacing), so the caret has to be
  /// measured with it too — measuring the bare [_expressionStyle] makes the
  /// caret drift further left with every character.
  TextStyle _resolvedStyle() {
    var style = DefaultTextStyle.of(context).style.merge(_expressionStyle);
    if (MediaQuery.boldTextOf(context)) {
      style = style.merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    return style;
  }

  /// Lays out [text] exactly as the on-screen [RichText] does: same resolved
  /// style, same text scaler. Caret and tap positions come from here.
  TextPainter _layoutPainter(String text) {
    return TextPainter(
      text: TextSpan(text: text, style: _resolvedStyle()),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
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
    painter.dispose();
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

        final painter = _layoutPainter(displayText);
        final textHeight = painter.size.height;
        final double cursorX;
        if (hasInput) {
          final formattedCursor =
              _rawToFormatted(displayText, calc.input.cursor);
          cursorX = painter
              .getOffsetForCaret(
                TextPosition(offset: formattedCursor),
                Rect.zero,
              )
              .dx;
        } else {
          cursorX = painter.size.width + 2.r;
        }
        painter.dispose();

        // The caret is centred on the gap between two characters, so at either
        // end of the text half of it hangs outside the text box. The gutter
        // keeps that half inside the scroll view, which would otherwise clip
        // it once the expression is long enough to scroll.
        final caretWidth = 2.5.r;
        final gutter = caretWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => _handleTap(details, input),
          onLongPress: () => calc.saveExpressionResult(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              18.r - gutter,
              14.r,
              18.r - gutter,
              14.r,
            ),
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: gutter),
                        // RichText paints exactly this span — unlike Text, it
                        // adds nothing from the ambient theme — so it matches
                        // what `_layoutPainter` measures.
                        child: RichText(
                          key: _textKey,
                          textScaler: MediaQuery.textScalerOf(context),
                          text: TextSpan(
                            text: displayText,
                            style: _resolvedStyle().copyWith(
                              color: hasInput
                                  ? palette.expressionText
                                  : palette.placeholderText,
                            ),
                          ),
                        ),
                      ),
                      if (_focused)
                        Positioned(
                          left: gutter + cursorX - caretWidth / 2,
                          top: 0,
                          bottom: 0,
                          child: _Cursor(
                            controller: _cursorController,
                            color: palette.cursor,
                            width: caretWidth,
                            height: textHeight * 0.8,
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
  const _Cursor({
    required this.controller,
    required this.color,
    required this.width,
    required this.height,
  });
  final Animation<double> controller;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: FadeTransition(
          opacity: controller,
          child: Container(
            width: width,
            height: height,
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
