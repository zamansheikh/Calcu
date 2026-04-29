import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/url_helper.dart';
import '../../theme/calcu_palette.dart';

class AppInfoDialog extends StatelessWidget {
  const AppInfoDialog({super.key, required this.packageInfo});

  final PackageInfo packageInfo;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: palette.surfaceElevated,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 24.r),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420.r,
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(palette: palette, version: packageInfo.version),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.r, 4.r, 24.r, 16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Features', palette: palette),
                    SizedBox(height: 8.r),
                    ..._features.map(
                      (f) => _FeatureRow(
                        icon: f.$1,
                        text: f.$2,
                        palette: palette,
                      ),
                    ),
                    SizedBox(height: 18.r),
                    _SectionTitle('Gestures', palette: palette),
                    SizedBox(height: 8.r),
                    ..._gestures.map(
                      (g) => _FeatureRow(
                        icon: g.$1,
                        text: g.$2,
                        palette: palette,
                      ),
                    ),
                    SizedBox(height: 18.r),
                    _SectionTitle('Developer', palette: palette),
                    SizedBox(height: 8.r),
                    Text(
                      AppConstants.developerName,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: palette.expressionText,
                      ),
                    ),
                    SizedBox(height: 12.r),
                    Wrap(
                      spacing: 8.r,
                      runSpacing: 8.r,
                      children: [
                        _LinkChip(
                          icon: Icons.code_rounded,
                          label: 'GitHub',
                          url: AppConstants.githubUrl,
                          palette: palette,
                        ),
                        _LinkChip(
                          icon: Icons.public,
                          label: 'Repository',
                          url: AppConstants.repoUrl,
                          palette: palette,
                        ),
                        _LinkChip(
                          icon: Icons.send_outlined,
                          label: 'Telegram',
                          url: AppConstants.telegramUrl,
                          palette: palette,
                        ),
                        _LinkChip(
                          icon: Icons.coffee_outlined,
                          label: 'Donate',
                          url: AppConstants.donateUrl,
                          palette: palette,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 16.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<(IconData, String)> _features = [
    (Icons.calculate_outlined, 'Standard arithmetic with parentheses'),
    (Icons.functions, 'Powers, square roots, modulo, and percentages'),
    (Icons.bookmark_outline, 'Memory chips — tap to recall, long-press to remove'),
    (Icons.touch_app_outlined, 'Tap anywhere in the expression to position the cursor'),
    (Icons.palette_outlined, 'Multiple themes — light, dark, and premium packs'),
  ];

  static const List<(IconData, String)> _gestures = [
    (Icons.touch_app_outlined, 'Tap input → place cursor'),
    (Icons.swipe_outlined, 'Long-press input → save its result'),
    (Icons.bookmark_add_outlined, 'Long-press result → save to memory'),
    (Icons.equalizer, 'Long-press = → 3-decimal precision'),
    (Icons.percent, 'Long-press % → insert mod('),
    (Icons.delete_sweep_outlined, 'Long-press info → clear all memory'),
  ];
}

class _Header extends StatelessWidget {
  const _Header({required this.palette, required this.version});
  final CalcuPalette palette;
  final String version;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.r, 22.r, 24.r, 18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.accent.withValues(alpha: 0.18),
            palette.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: palette.accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.calculate, color: palette.accent, size: 24.sp),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: palette.expressionText,
                  ),
                ),
                Text(
                  '${AppConstants.tagline} · v$version',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: palette.placeholderText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.palette});
  final String text;
  final CalcuPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6.r),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.6,
          color: palette.accent,
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.text,
    required this.palette,
  });

  final IconData icon;
  final String text;
  final CalcuPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: palette.accent),
          SizedBox(width: 10.r),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: palette.expressionText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({
    required this.icon,
    required this.label,
    required this.url,
    required this.palette,
  });

  final IconData icon;
  final String label;
  final String url;
  final CalcuPalette palette;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: () async {
        HapticFeedback.lightImpact();
        await UrlHelper.open(url);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: palette.accent),
            SizedBox(width: 6.r),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: palette.expressionText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
