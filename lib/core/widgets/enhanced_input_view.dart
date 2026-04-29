import 'package:calcu/presentation/providers/calculator_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class EnhancedInputView extends StatefulWidget {
  const EnhancedInputView({super.key});

  @override
  State<EnhancedInputView> createState() => _EnhancedInputViewState();
}

class _EnhancedInputViewState extends State<EnhancedInputView>
    with TickerProviderStateMixin {
  late AnimationController _cursorController;
  bool _showCursor = false;
  // Used to get the size for alignment math during hit-testing
  final GlobalKey _containerKey = GlobalKey();
  // Track horizontal scroll so hit-testing works when user scrolls
  final ScrollController _hScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _cursorController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _hScrollController.dispose();
    super.dispose();
  }

  void _handleTap(
    TapDownDetails details,
    String input,
    CalculatorProvider provider,
  ) {
    if (input.isEmpty) {
      provider.inputController.setCursorPosition(0);
      setState(() {
        _showCursor = true;
      });
      return;
    }

    // We render numbers with commas. Hit-test using the same formatted text
    // and then map the position back to the raw, unformatted string.
    final formatted = _addCommasToNumbers(input);

    // Build a TextPainter exactly like the display text
    final textStyle = TextStyle(
      fontSize: input.length > 15 ? 24.sp : 28.sp,
      color: Theme.of(context).colorScheme.inversePrimary,
      fontWeight: FontWeight.w400,
    );

    // Lay out the full text width (unconstrained) to get accurate glyph widths
    final containerSize = _containerKey.currentContext?.size;
    final horizontalPadding = 8.sp * 2; // left + right padding from Container
    final containerWidth = (containerSize?.width ?? 0).clamp(
      0.0,
      double.infinity,
    );
    final leftPadding = 8.sp;

    final painter = TextPainter(
      text: TextSpan(text: formatted, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: double.infinity);

    final textWidth = painter.width;

    // Convert tap x from viewport space to full text space.
    // Read precise viewport width from the scroll controller when available.
    final hasClients = _hScrollController.hasClients;
    final viewportWidth = hasClients
        ? _hScrollController.position.viewportDimension
        : math.max(0.0, containerWidth - horizontalPadding);
    final localXInViewport = (details.localPosition.dx - leftPadding).clamp(
      0.0,
      viewportWidth,
    );

    // With reverse: true, pixels increase as you reveal earlier content.
    final pixels = hasClients ? _hScrollController.position.pixels : 0.0;
    final maxHiddenOnLeft = textWidth > viewportWidth
        ? (textWidth - viewportWidth)
        : 0.0;
    // Visible left = maxHiddenOnLeft - pixels (clamped)
    final viewportLeftInTextSpace = (maxHiddenOnLeft - pixels).clamp(
      0.0,
      maxHiddenOnLeft,
    );
    final xInTextSpace = (viewportLeftInTextSpace + localXInViewport).clamp(
      0.0,
      textWidth,
    );

    // Get the caret position at this x within the full text
    final posInFormatted = painter
        .getPositionForOffset(Offset(xInTextSpace, 0))
        .offset;

    // Map formatted index back to raw index (skip commas)
    int rawIndex = 0;
    for (int i = 0; i < posInFormatted && i < formatted.length; i++) {
      if (formatted[i] != ',') rawIndex++;
    }
    // If tapped at/after the end, clamp to raw length
    rawIndex = rawIndex.clamp(0, input.length);

    provider.inputController.setCursorPosition(rawIndex);
    setState(() {
      _showCursor = true;
    });

    // Restart cursor animation for visibility feedback
    _cursorController
      ..reset()
      ..repeat();
  }

  String _addCommasToNumbers(String input) {
    return input.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(\.|$))'),
      (Match match) => '${match.group(1)},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculatorProvider, _) {
        return GestureDetector(
          onLongPress: () {
            calculatorProvider.saveInputResult();
          },
          onTapDown: (details) {
            _handleTap(
              details,
              calculatorProvider.inputController.input,
              calculatorProvider,
            );
          },
          child: Container(
            key: _containerKey,
            width: double.infinity,
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.sp),
              border: Border.all(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            child: SingleChildScrollView(
              reverse: true,
              controller: _hScrollController,
              scrollDirection: Axis.horizontal,
              child: _buildDisplayText(context, calculatorProvider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisplayText(BuildContext context, calculatorProvider) {
    final inputController = calculatorProvider.inputController;
    final text = inputController.input;
    final cursorPosition = inputController.cursorPosition;

    // Consistent text style
    final textStyle = TextStyle(
      fontSize: text.length > 15 ? 24.sp : 28.sp,
      color: Theme.of(context).colorScheme.inversePrimary,
      fontWeight: FontWeight.w400,
    );

    if (text.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '0',
            style: textStyle.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.inversePrimary.withValues(alpha: 0.5),
            ),
          ),
          // Show cursor even when empty
          if (_showCursor)
            FadeTransition(
              opacity: _cursorController,
              child: Container(
                width: 3.sp,
                height: (text.length > 15 ? 24.sp : 28.sp) * 0.9,
                margin: EdgeInsets.only(left: 2.sp),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onTertiary,
                  borderRadius: BorderRadius.circular(1.sp),
                ),
              ),
            ),
        ],
      );
    }

    // Split text at cursor position
    final beforeCursor = text.substring(0, cursorPosition);
    final afterCursor = text.substring(cursorPosition);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (beforeCursor.isNotEmpty)
          Text(_addCommasToNumbers(beforeCursor), style: textStyle),
        // Custom animated cursor
        if (_showCursor)
          FadeTransition(
            opacity: _cursorController,
            child: Container(
              width: 3.sp,
              height: (text.length > 15 ? 24.sp : 28.sp) * 0.9,
              margin: EdgeInsets.symmetric(horizontal: 1.sp),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onTertiary,
                borderRadius: BorderRadius.circular(1.sp),
              ),
            ),
          ),
        if (afterCursor.isNotEmpty)
          Text(_addCommasToNumbers(afterCursor), style: textStyle),
      ],
    );
  }
}
