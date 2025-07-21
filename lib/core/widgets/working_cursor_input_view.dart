import 'package:calcu/presentation/providers/calculator_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class WorkingCursorInputView extends StatefulWidget {
  const WorkingCursorInputView({super.key});

  @override
  State<WorkingCursorInputView> createState() => _WorkingCursorInputViewState();
}

class _WorkingCursorInputViewState extends State<WorkingCursorInputView>
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

    // Get the container's render box to understand the layout
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Account for container padding and alignment
    final containerWidth = renderBox.size.width;
    final tapX = details.localPosition.dx;

    // Create TextPainter with exact same style as display
    final textStyle = TextStyle(fontSize: 50.sp);
    final textPainter = TextPainter(
      text: TextSpan(text: input, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: double.infinity);

    // Calculate the actual text start position (accounting for right alignment)
    final textWidth = textPainter.width;
    final containerPadding = 8.sp;
    final textStartX = containerWidth - textWidth - containerPadding;

    // Adjust tap position relative to text start
    final relativeTapX = tapX - textStartX;

    // Find the closest character position
    int closestPosition = input.length; // Default to end
    double closestDistance = double.infinity;

    for (int i = 0; i <= input.length; i++) {
      final offset = textPainter.getOffsetForCaret(
        TextPosition(offset: i),
        Rect.zero,
      );

      final distance = (offset.dx - relativeTapX).abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closestPosition = i;
      }
    }

    provider.inputController.setCursorPosition(closestPosition);
    setState(() {
      _showCursor = true;
    });
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
        final input = calculatorProvider.inputController.input;

        return GestureDetector(
          onLongPress: () {
            calculatorProvider.saveInputResult();
            calculatorProvider.scrollController.animateTo(
              calculatorProvider.scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
          onTapDown: (details) {
            _handleTap(details, input, calculatorProvider);
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
              child: _buildTextWithCursor(
                context,
                input,
                calculatorProvider.inputController.cursorPosition,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextWithCursor(
    BuildContext context,
    String input,
    int cursorPosition,
  ) {
    if (input.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '0',
            style: TextStyle(
              fontSize: 50.sp,
              color: Theme.of(
                context,
              ).colorScheme.inversePrimary.withValues(alpha: 0.5),
            ),
          ),
          if (_showCursor)
            FadeTransition(
              opacity: _cursorController,
              child: Container(
                width: 3.sp,
                height: 45.sp,
                margin: EdgeInsets.only(left: 4.sp),
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
    String beforeCursor = input.substring(0, cursorPosition);
    String afterCursor = input.substring(cursorPosition);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (beforeCursor.isNotEmpty)
          Text(
            _addCommasToNumbers(beforeCursor),
            style: TextStyle(
              fontSize: 50.sp,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        // Animated cursor
        if (_showCursor)
          FadeTransition(
            opacity: _cursorController,
            child: Container(
              width: 3.sp,
              height: 45.sp,
              margin: EdgeInsets.symmetric(horizontal: 1.sp),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onTertiary,
                borderRadius: BorderRadius.circular(1.sp),
              ),
            ),
          ),
        if (afterCursor.isNotEmpty)
          Text(
            _addCommasToNumbers(afterCursor),
            style: TextStyle(
              fontSize: 50.sp,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
      ],
    );
  }
}
