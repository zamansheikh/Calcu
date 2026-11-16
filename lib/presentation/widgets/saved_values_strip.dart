import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../theme/calcu_palette.dart';
import '../providers/calculator_provider.dart';
import 'animated_tap.dart';
import 'keypad_toolbar.dart';

/// Horizontal strip of saved-result chips. Tap to insert into the expression;
/// long-press to delete.
class SavedValuesStrip extends StatelessWidget {
  const SavedValuesStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Consumer<CalculatorProvider>(
      builder: (context, calc, _) {
        if (calc.savedValues.isEmpty) {
          return _EmptyHint(palette: palette);
        }
        // Chips that run past the end fade out rather than being cut off.
        // The list's own end padding is as wide as the fade, so the last
        // chip is fully visible once scrolled to.
        final fade = 22.r;
        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: const [Colors.white, Colors.white, Colors.transparent],
            stops: [0, 1 - fade / bounds.width, 1],
          ).createShader(bounds),
          child: ListView.separated(
            controller: calc.savedScrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(
              left: KeypadToolbar.edgeInset,
              right: fade,
            ),
            itemCount: calc.savedValues.length,
            separatorBuilder: (context, index) => SizedBox(width: 8.r),
            itemBuilder: (context, index) {
              final value = calc.savedValues[index];
              return _SavedChip(
                index: index,
                value: value,
                palette: palette,
                onTap: () => calc.useSavedValue(index),
                onLongPress: () => _confirmDelete(context, calc, index),
              );
            },
          ),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    CalculatorProvider calc,
    int index,
  ) {
    calc.deleteSavedValue(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Saved value removed'),
        duration: const Duration(milliseconds: 1200),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }
}

class _SavedChip extends StatelessWidget {
  const _SavedChip({
    required this.index,
    required this.value,
    required this.palette,
    required this.onTap,
    required this.onLongPress,
  });

  final int index;
  final String value;
  final CalcuPalette palette;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return AnimatedTap(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.r),
        decoration: BoxDecoration(
          color: palette.savedChip,
          borderRadius: BorderRadius.circular(KeypadToolbar.itemRadius),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'M${index + 1}',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: palette.savedChipText.withValues(alpha: 0.55),
              ),
            ),
            SizedBox(width: 8.r),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: palette.savedChipText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.palette});
  final CalcuPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: KeypadToolbar.edgeInset + 4.r),
      child: Row(
        children: [
          Icon(Icons.bookmark_border,
              size: 16.sp, color: palette.placeholderText),
          SizedBox(width: 6.r),
          Flexible(
            child: Text(
              'Long-press the result to save it here',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12.sp,
                color: palette.placeholderText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
