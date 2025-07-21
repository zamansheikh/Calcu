import 'package:calcu/presentation/providers/calculator_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class EnhancedInputView extends StatefulWidget {
  const EnhancedInputView({super.key});

  @override
  State<EnhancedInputView> createState() => _EnhancedInputViewState();
}

class _EnhancedInputViewState extends State<EnhancedInputView>
    with TickerProviderStateMixin {
  late AnimationController _cursorController;
  bool _showCursor = false;

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

    // Get the exact tap position
    final tapX = details.localPosition.dx - 8.sp; // Account for padding

    // Create a TextPainter to measure text accurately
    final textPainter = TextPainter(
      text: TextSpan(
        text: input,
        style: TextStyle(
          fontSize: input.length > 15 ? 24.sp : 28.sp,
          color: Theme.of(context).colorScheme.inversePrimary,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: double.infinity);

    // Find the closest character position to the tap
    int closestPosition = 0;
    double closestDistance = double.infinity;

    for (int i = 0; i <= input.length; i++) {
      final offset = textPainter.getOffsetForCaret(
        TextPosition(offset: i),
        Rect.zero,
      );

      final distance = (offset.dx - tapX).abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closestPosition = i;
      }
    }

    // Set the cursor position
    provider.inputController.setCursorPosition(closestPosition);
    setState(() {
      _showCursor = true;
    });

    // Start cursor animation
    _cursorController.reset();
    _cursorController.repeat();
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
