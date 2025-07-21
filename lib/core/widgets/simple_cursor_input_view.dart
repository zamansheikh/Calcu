import 'package:calcu/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SimpleCursorInputView extends StatefulWidget {
  const SimpleCursorInputView({super.key});

  @override
  State<SimpleCursorInputView> createState() => _SimpleCursorInputViewState();
}

class _SimpleCursorInputViewState extends State<SimpleCursorInputView>
    with TickerProviderStateMixin {
  late AnimationController _cursorController;
  int _cursorPosition = 0;
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

  void _handleTap(String input, TapDownDetails details, BuildContext context) {
    if (input.isEmpty) return;

    RenderBox renderBox = context.findRenderObject() as RenderBox;
    double tapX = details.localPosition.dx;

    // Simple approximation: estimate character position based on tap position
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: input,
        style: TextStyle(fontSize: 50.sp),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    double charWidth = textPainter.width / input.length;
    int newPosition = (tapX / charWidth).round().clamp(0, input.length);

    setState(() {
      _cursorPosition = newPosition;
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
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        // Update cursor position when input changes
        if (_cursorPosition > homeProvider.input.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _cursorPosition = homeProvider.input.length;
            });
          });
        }

        return GestureDetector(
          onLongPress: () {
            homeProvider.clickOnInputDisplay();
            homeProvider.scrollController.animateTo(
              homeProvider.scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
          onTapDown: (details) {
            _handleTap(homeProvider.input, details, context);
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
              child: _buildTextWithCursor(context, homeProvider.input),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextWithCursor(BuildContext context, String input) {
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
    String beforeCursor = input.substring(0, _cursorPosition);
    String afterCursor = input.substring(_cursorPosition);

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
        // Cursor
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
