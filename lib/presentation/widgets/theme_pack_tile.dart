import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/calcu_palette.dart';
import '../../theme/theme_catalog.dart';
import 'animated_tap.dart';

/// One row in the theme store. Mini-preview on the left, metadata + action on
/// the right. Designed for a single-column list — fits comfortably on phones.
class ThemePackTile extends StatelessWidget {
  const ThemePackTile({
    super.key,
    required this.pack,
    required this.isOwned,
    required this.isActive,
    required this.useDarkPreview,
    required this.onUse,
    required this.onPurchase,
    this.priceLabel,
  });

  final ThemePack pack;
  final bool isOwned;
  final bool isActive;
  final bool useDarkPreview;
  final VoidCallback onUse;
  final VoidCallback onPurchase;

  /// Resolved price (live store price preferred, catalog default otherwise).
  final String? priceLabel;

  CalcuPalette get _preview =>
      useDarkPreview ? pack.darkPalette : pack.lightPalette;

  @override
  Widget build(BuildContext context) {
    final shellPalette = context.palette;

    return AnimatedTap(
      onTap: isOwned ? onUse : onPurchase,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: shellPalette.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive ? pack.previewColor : shellPalette.border,
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: pack.previewColor
                  .withValues(alpha: isActive ? 0.16 : 0.04),
              blurRadius: isActive ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Preview(palette: _preview),
            SizedBox(width: 14.r),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pack.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: shellPalette.expressionText,
                          ),
                        ),
                      ),
                      if (pack.isPremium)
                        Padding(
                          padding: EdgeInsets.only(left: 6.r),
                          child: Icon(
                            Icons.workspace_premium_rounded,
                            size: 14.sp,
                            color: pack.previewColor,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.r),
                  Text(
                    pack.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11.sp,
                      color: shellPalette.placeholderText,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 10.r),
                  _ActionPill(
                    isActive: isActive,
                    isOwned: isOwned,
                    pack: pack,
                    priceLabel: priceLabel,
                    shellPalette: shellPalette,
                    onUse: onUse,
                    onPurchase: onPurchase,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.palette});
  final CalcuPalette palette;

  @override
  Widget build(BuildContext context) {
    Widget swatch(Color color, {double w = 16, double h = 10}) => Container(
          width: w.r,
          height: h.r,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        );

    return Container(
      width: 96.r,
      height: 96.r,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.backgroundGradient,
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 3.r),
            decoration: BoxDecoration(
              color: palette.displayBackground,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              '128',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: palette.resultText,
                height: 1,
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              swatch(palette.numberButton),
              swatch(palette.specialButton),
              swatch(palette.operatorButton),
            ],
          ),
          SizedBox(height: 4.r),
          Row(
            children: [
              Expanded(child: swatch(palette.numberButton, w: 28)),
              SizedBox(width: 4.r),
              swatch(palette.equalsButton, w: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.isActive,
    required this.isOwned,
    required this.pack,
    required this.shellPalette,
    required this.onUse,
    required this.onPurchase,
    this.priceLabel,
  });

  final bool isActive;
  final bool isOwned;
  final ThemePack pack;
  final String? priceLabel;
  final CalcuPalette shellPalette;
  final VoidCallback onUse;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return _Pill(
        background: pack.previewColor.withValues(alpha: 0.14),
        foreground: pack.previewColor,
        icon: Icons.check_circle_rounded,
        label: 'In use',
        onTap: null,
      );
    }
    if (isOwned) {
      return _Pill(
        background: shellPalette.surfaceElevated,
        foreground: shellPalette.expressionText,
        border: shellPalette.border,
        icon: Icons.brush_outlined,
        label: 'Apply',
        onTap: onUse,
      );
    }
    final price = priceLabel ?? pack.priceLabel ?? '';
    return _Pill(
      background: pack.previewColor,
      foreground: Colors.white,
      icon: Icons.lock_open_rounded,
      label: price.isEmpty ? 'Buy' : 'Buy $price',
      onTap: onPurchase,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.label,
    required this.onTap,
    this.border,
  });

  final Color background;
  final Color foreground;
  final Color? border;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 7.r),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10.r),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13.sp, color: foreground),
          SizedBox(width: 6.r),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) {
      return Align(alignment: Alignment.centerLeft, child: pill);
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: onTap,
        child: pill,
      ),
    );
  }
}
