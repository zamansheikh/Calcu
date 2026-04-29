import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../theme/calcu_palette.dart';
import '../providers/calculator_provider.dart';
import 'animated_tap.dart';

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
        return SizedBox(
          height: 44.r,
          child: ListView.separated(
            controller: calc.savedScrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 18.r),
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
        padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
        decoration: BoxDecoration(
          color: palette.savedChip,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
              decoration: BoxDecoration(
                color: palette.savedChipText.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'M${index + 1}',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: palette.savedChipText,
                ),
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
    return SizedBox(
      height: 44.r,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.r),
        child: Row(
          children: [
            Icon(Icons.bookmark_border,
                size: 16.sp, color: palette.placeholderText),
            SizedBox(width: 6.r),
            Text(
              'Long-press the result to save it here',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12.sp,
                color: palette.placeholderText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
