import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/utils/number_formatter.dart';
import '../../data/models/saved_entry.dart';
import '../../theme/calcu_palette.dart';
import '../providers/calculator_provider.dart';
import 'animated_tap.dart';
import 'keypad_toolbar.dart';
import 'math/math_label.dart';

/// Horizontal strip of saved results.
///
/// A chip has two halves: the expression that was saved and the result it
/// gave. Tapping a half pastes that half into the expression being typed;
/// long-pressing the chip deletes it.
class SavedValuesStrip extends StatelessWidget {
  const SavedValuesStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Consumer<CalculatorProvider>(
      builder: (context, calc, _) {
        final entries = calc.savedEntries;
        if (entries.isEmpty) {
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
            itemCount: entries.length,
            separatorBuilder: (context, index) => SizedBox(width: 8.r),
            itemBuilder: (context, index) {
              return _SavedChip(
                index: index,
                entry: entries[index],
                palette: palette,
                onValue: () => calc.useSavedValue(index),
                onExpression: () => calc.useSavedExpression(index),
                onLongPress: () => _delete(context, calc, index),
              );
            },
          ),
        );
      },
    );
  }

  /// How long a removed entry can still be brought back.
  static const _undoWindow = Duration(seconds: 5);

  void _delete(BuildContext context, CalculatorProvider calc, int index) {
    final removed = calc.deleteSavedValue(index);
    if (removed == null) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger
      // One at a time: a second removal replaces the first bar rather than
      // queueing behind it.
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: _undoWindow,
          padding: EdgeInsets.only(left: 16.r, right: 6.r),
          // The Undo button lives in the content rather than in `action`:
          // a snack bar with an action stays up until it is dismissed, and
          // this one has to leave on its own.
          content: _UndoBar(
            window: _undoWindow,
            onUndo: () {
              calc.restoreSavedEntry(index, removed);
              messenger.hideCurrentSnackBar();
            },
          ),
        ),
      );
  }
}

/// "Saved value removed", a ring that empties as the chance to undo runs
/// out, and the Undo button.
class _UndoBar extends StatelessWidget {
  const _UndoBar({required this.window, required this.onUndo});

  final Duration window;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        const Expanded(child: Text('Saved value removed')),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: 0),
          duration: window,
          builder: (context, remaining, _) {
            return SizedBox.square(
              dimension: 26.r,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: remaining,
                      strokeWidth: 2.5,
                      color: palette.accent,
                      backgroundColor: palette.accent.withValues(alpha: 0.18),
                    ),
                  ),
                  Text(
                    '${(remaining * window.inSeconds).ceil()}',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: palette.expressionText,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        TextButton(
          onPressed: onUndo,
          style: TextButton.styleFrom(foregroundColor: palette.accent),
          child: const Text(
            'Undo',
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _SavedChip extends StatelessWidget {
  const _SavedChip({
    required this.index,
    required this.entry,
    required this.palette,
    required this.onValue,
    required this.onExpression,
    required this.onLongPress,
  });

  final int index;
  final SavedEntry entry;
  final CalcuPalette palette;
  final VoidCallback onValue;
  final VoidCallback onExpression;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final expression = entry.expression;
    final textColor = palette.savedChipText;

    final label = Text(
      'M${index + 1}',
      style: TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: textColor.withValues(alpha: 0.55),
      ),
    );
    // A result in scientific form (3.6×10^40) is typeset; a plain number is
    // printed.
    final Widget value = entry.value.contains('^')
        ? MathLabel(
            entry.value,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
          )
        : Text(
            NumberFormatter.addThousandsSeparators(entry.value),
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          );

    return Container(
      decoration: BoxDecoration(
        color: palette.savedChip,
        borderRadius: BorderRadius.circular(KeypadToolbar.itemRadius),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (expression == null)
            // Saved before expressions were kept: there is only the value.
            _half(
              name: 'Paste ${entry.value}',
              onTap: onValue,
              children: [label, SizedBox(width: 8.r), value],
            )
          else ...[
            _half(
              name: 'Paste the expression',
              onTap: onExpression,
              children: [
                label,
                SizedBox(width: 8.r),
                // Typeset small. A tall expression (a fraction of
                // fractions) is scaled to the chip; a long one shows its
                // start.
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 28.r),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: MathLabel(
                      expression,
                      fontSize: 15.sp,
                      color: textColor.withValues(alpha: 0.85),
                      maxWidth: 120.r,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 1,
              margin: EdgeInsets.symmetric(vertical: 8.r),
              color: textColor.withValues(alpha: 0.16),
            ),
            _half(
              name: 'Paste the result ${entry.value}',
              onTap: onValue,
              children: [
                Text(
                  '=',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(width: 6.r),
                value,
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _half({
    required String name,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Semantics(
      button: true,
      label: name,
      excludeSemantics: true,
      child: AnimatedTap(
        onTap: onTap,
        onLongPress: onLongPress,
        scale: 0.94,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 11.r),
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
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
