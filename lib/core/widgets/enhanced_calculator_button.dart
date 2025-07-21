import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CalculatorButtonType { number, operator, special, clear, equals }

class EnhancedCalculatorButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final VoidCallback? onLongPressed;
  final CalculatorButtonType type;
  final Widget? icon;
  final bool isExpanded;

  const EnhancedCalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.onLongPressed,
    this.type = CalculatorButtonType.number,
    this.icon,
    this.isExpanded = false,
  });

  @override
  State<EnhancedCalculatorButton> createState() =>
      _EnhancedCalculatorButtonState();
}

class _EnhancedCalculatorButtonState extends State<EnhancedCalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getButtonColor(BuildContext context) {
    switch (widget.type) {
      case CalculatorButtonType.number:
        return Theme.of(context).colorScheme.onSurface;
      case CalculatorButtonType.operator:
        return Theme.of(context).colorScheme.onTertiary;
      case CalculatorButtonType.special:
        return Theme.of(context).colorScheme.tertiary;
      case CalculatorButtonType.clear:
        return Colors.red.shade400;
      case CalculatorButtonType.equals:
        return Theme.of(context).colorScheme.onTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.isExpanded ? 2 : 1,
      child: Padding(
        padding: EdgeInsets.all(2.sp),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                onTap: widget.onPressed,
                onLongPress: widget.onLongPressed,
                child: Container(
                  height: 70.sp,
                  decoration: BoxDecoration(
                    color: _getButtonColor(context),
                    borderRadius: BorderRadius.circular(16.sp),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child:
                        widget.icon ??
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
