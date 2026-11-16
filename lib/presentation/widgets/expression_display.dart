import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/math/math_document.dart';
import '../../core/utils/number_formatter.dart';
import '../../theme/calcu_palette.dart';
import '../providers/calculator_provider.dart';
import 'math/math_layout.dart';

/// Top half of the display: the expression, typeset the way it would be
/// written by hand — exponents raised, fractions stacked, roots under a bar —
/// with a caret that can be placed by tapping. Long-press saves the result.
///
/// The expression is laid out once per build into a [MathLayout], and that
/// one layout paints it, positions the caret and resolves taps.
class ExpressionDisplay extends StatefulWidget {
  const ExpressionDisplay({super.key});

  @override
  State<ExpressionDisplay> createState() => _ExpressionDisplayState();
}

class _ExpressionDisplayState extends State<ExpressionDisplay>
    with SingleTickerProviderStateMixin {
  /// A tall expression is shrunk to fit the display, but not below this.
  static const _minFitScale = 0.45;

  final GlobalKey _paintKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _cursorController;

  MathLayout? _layout;
  bool _focused = false;

  // The edit the scroll position was last adjusted for.
  String? _revealedText;
  int? _revealedCursor;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _scrollController.dispose();
    _layout?.dispose();
    super.dispose();
  }

  MathLayout _buildLayout(
    MathDocument document,
    MathStyle style,
    double maxHeight,
  ) {
    var layout = MathLayout(document, style);
    if (maxHeight.isFinite && layout.size.height > maxHeight) {
      final scale =
          (maxHeight / layout.size.height).clamp(_minFitScale, 1.0);
      layout.dispose();
      layout = MathLayout(
        document,
        style.copyWith(fontSize: style.fontSize * scale),
      );
    }
    return layout;
  }

  void _handleTap(TapUpDetails details) {
    final provider = context.read<CalculatorProvider>();
    final layout = _layout;
    final box = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    if (provider.expression.isNotEmpty && layout != null && box != null) {
      final local = box.globalToLocal(details.globalPosition);
      provider.moveCursor(layout.stopAt(local));
    }
    setState(() => _focused = true);
  }

  /// Scrolls so the caret is on screen after an edit or a caret move. Left
  /// alone otherwise, so the user can still pan a long expression by hand.
  void _revealCaret(String text, int cursor, double caretX, double width) {
    if (text == _revealedText && cursor == _revealedCursor) return;
    _revealedText = text;
    _revealedCursor = cursor;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Restart the blink so the caret is solid the moment it moves.
      _cursorController
        ..value = 1
        ..repeat(reverse: true);
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      final viewport = position.viewportDimension;
      final margin = 28.r;
      // The view is reversed: `pixels` counts in from the right-hand end.
      final visibleRight = width - position.pixels;
      final visibleLeft = visibleRight - viewport;

      double? target;
      if (caretX > visibleRight - margin) {
        target = width - caretX - margin;
      } else if (caretX < visibleLeft + margin) {
        target = width - viewport - caretX + margin;
      }
      if (target == null) return;
      position.jumpTo(
        target.clamp(position.minScrollExtent, position.maxScrollExtent),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Consumer<CalculatorProvider>(
      builder: (context, calc, _) {
        final input = calc.expression;
        final hasInput = input.isNotEmpty;
        final cursor = calc.input.cursor;

        // The caret is centred on the gap between two characters, so at
        // either end of the expression half of it hangs outside. The gutter
        // keeps that half inside the scroll view, which would otherwise clip
        // it once the expression is long enough to scroll.
        final caretWidth = 2.5.r;
        final gutter = caretWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: _handleTap,
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final style = MathStyle(
                  fontSize: MediaQuery.textScalerOf(context).scale(46.sp),
                  fontWeight: MediaQuery.boldTextOf(context)
                      ? FontWeight.w700
                      : FontWeight.w600,
                  color: hasInput
                      ? palette.expressionText
                      : palette.placeholderText,
                  placeholderColor:
                      palette.expressionText.withValues(alpha: 0.35),
                );

                _layout?.dispose();
                final layout = _layout = _buildLayout(
                  hasInput ? calc.input.document : MathDocument.parse('0'),
                  style,
                  constraints.maxHeight,
                );

                final CaretMetrics caret;
                if (hasInput) {
                  caret = layout.caretAt(cursor);
                } else {
                  // Nothing typed yet: the caret waits after the grey 0.
                  final end = layout.caretAt(1);
                  caret = CaretMetrics(
                    x: end.x + 2.r,
                    top: end.top,
                    bottom: end.bottom,
                  );
                }

                final width = layout.size.width + 2 * gutter;
                _revealCaret(input, cursor, gutter + caret.x, width);

                // While typing straight along the main line the caret stays
                // out of the way until the display is tapped. Inside an
                // exponent or a fraction it is the only thing that shows
                // where the next key will land, so it is always drawn.
                final document = calc.input.document;
                final atPlainEnd = cursor == input.length &&
                    identical(document.ownerOf(cursor), document.root);
                final showCaret = _focused || (hasInput && !atPlainEnd);

                return Align(
                  alignment: Alignment.centerRight,
                  child: ClipRect(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        width: width,
                        height: layout.size.height,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: gutter,
                              top: 0,
                              child: Semantics(
                                label: hasInput
                                    ? NumberFormatter.addThousandsSeparators(
                                        input)
                                    : '0',
                                child: CustomPaint(
                                  key: _paintKey,
                                  size: layout.size,
                                  painter: _MathPainter(layout),
                                ),
                              ),
                            ),
                            if (showCaret)
                              Positioned(
                                left: gutter + caret.x - caretWidth / 2,
                                top: caret.top,
                                child: _Cursor(
                                  controller: _cursorController,
                                  color: palette.cursor,
                                  width: caretWidth,
                                  height: caret.height,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _MathPainter extends CustomPainter {
  const _MathPainter(this.layout);

  final MathLayout layout;

  @override
  void paint(Canvas canvas, Size size) => layout.paint(canvas, Offset.zero);

  @override
  bool shouldRepaint(_MathPainter oldDelegate) =>
      !identical(oldDelegate.layout, layout);
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
      child: FadeTransition(
        opacity: controller,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(width / 2),
          ),
        ),
      ),
    );
  }
}
