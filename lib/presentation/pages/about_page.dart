import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/url_helper.dart';
import '../../theme/calcu_palette.dart';
import '../widgets/app_logo.dart';

/// About Calcu: what it does, the shortcuts worth knowing, and who made it.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key, required this.packageInfo});

  final PackageInfo packageInfo;

  static const List<(IconData, String, String)> _features = [
    (
      Icons.functions_rounded,
      'Natural display',
      'Fractions, roots and powers are typeset as you type.',
    ),
    (
      Icons.swap_horiz_rounded,
      'Three answer forms',
      'Decimal, fraction or rounded, one press apart.',
    ),
    (
      Icons.science_outlined,
      'Scientific keys',
      'Logs, roots, absolute value, π and e.',
    ),
    (
      Icons.all_inclusive_rounded,
      'Huge numbers',
      'Answers far past the point where others say Error.',
    ),
    (
      Icons.bookmark_outline_rounded,
      'Saved results',
      'Paste back the answer, or the whole equation.',
    ),
    (
      Icons.palette_outlined,
      'Nine themes',
      'Free and premium looks, each in light and dark.',
    ),
  ];

  /// A key (or what to touch) and what it does beyond the obvious.
  static const List<(String, String)> _tips = [
    ('=', 'Press again for the fraction, then the rounded value.'),
    ('hold =', 'Jump straight to three decimal places.'),
    (')', 'Leaves the root, power or fraction you are in.'),
    ('hold ⌫', 'Keeps deleting until you let go.'),
    ('hold %', 'Inserts mod, the remainder of a division.'),
    ('hold log', 'Inserts ln. Hold π for e.'),
    ('hold result', 'Saves it, with the equation it came from.'),
    ('saved chip', 'Tap either half to paste it. Hold to delete.'),
    ('hold ⓘ', 'Clears every saved value.'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: palette.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.r, 4.r, 8.r, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Back',
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: palette.expressionText,
                      ),
                    ),
                    SizedBox(width: 2.r),
                    Text(
                      'About',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: palette.expressionText,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(18.r, 10.r, 18.r, 28.r),
                  children: [
                    _Hero(palette: palette, packageInfo: packageInfo),
                    _SectionTitle('What it does', palette: palette),
                    _FeatureGrid(features: _features, palette: palette),
                    _SectionTitle('Worth knowing', palette: palette),
                    _Card(
                      palette: palette,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.r,
                        vertical: 6.r,
                      ),
                      child: Column(
                        children: [
                          for (final (i, tip) in _tips.indexed) ...[
                            if (i > 0)
                              Divider(height: 1, color: palette.divider),
                            _TipRow(
                              keyLabel: tip.$1,
                              text: tip.$2,
                              palette: palette,
                            ),
                          ],
                        ],
                      ),
                    ),
                    _SectionTitle('Made by', palette: palette),
                    _DeveloperCard(palette: palette),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.palette, required this.packageInfo});

  final CalcuPalette palette;
  final PackageInfo packageInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.accent.withValues(alpha: 0.22),
            palette.accent.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: palette.accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: AppLogo(size: 76.r),
          ),
          SizedBox(width: 16.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    color: palette.expressionText,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  AppConstants.tagline,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    color: palette.placeholderText,
                  ),
                ),
                SizedBox(height: 10.r),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.r,
                    vertical: 4.r,
                  ),
                  decoration: BoxDecoration(
                    color: palette.specialButton,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Version ${packageInfo.version} (${packageInfo.buildNumber})',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: palette.specialButtonText,
                    ),
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
      padding: EdgeInsets.fromLTRB(4.r, 24.r, 4.r, 10.r),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: palette.resultText,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.palette, required this.child, this.padding});

  final CalcuPalette palette;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: palette.displayBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.border),
      ),
      child: child,
    );
  }
}

/// The features, two to a row, each pair as tall as its taller card.
class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.features, required this.palette});

  final List<(IconData, String, String)> features;
  final CalcuPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < features.length; i += 2) ...[
          if (i > 0) SizedBox(height: 10.r),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _tile(features[i])),
                SizedBox(width: 10.r),
                Expanded(
                  child: i + 1 < features.length
                      ? _tile(features[i + 1])
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _tile((IconData, String, String) feature) {
    final (icon, title, text) = feature;
    return _Card(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: palette.specialButton,
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(icon, size: 20.sp, color: palette.specialButtonText),
          ),
          SizedBox(height: 10.r),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: palette.expressionText,
            ),
          ),
          SizedBox(height: 3.r),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              height: 1.35,
              color: palette.placeholderText,
            ),
          ),
        ],
      ),
    );
  }
}

/// One shortcut: the key drawn as a small keycap, then what it does.
class _TipRow extends StatelessWidget {
  const _TipRow({
    required this.keyLabel,
    required this.text,
    required this.palette,
  });

  final String keyLabel;
  final String text;
  final CalcuPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.r),
      child: Row(
        children: [
          SizedBox(
            width: 94.r,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
                decoration: BoxDecoration(
                  color: palette.specialButton,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Text(
                  keyLabel,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: palette.specialButtonText,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: palette.expressionText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard({required this.palette});

  final CalcuPalette palette;

  static String get _initials => AppConstants.developerName
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0])
      .take(2)
      .join();

  @override
  Widget build(BuildContext context) {
    return _Card(
      palette: palette,
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.equalsButton,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _initials,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: palette.equalsButtonText,
                  ),
                ),
              ),
              SizedBox(width: 14.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.developerName,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: palette.expressionText,
                      ),
                    ),
                    Text(
                      'Designed and built Calcu',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: palette.placeholderText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.r),
          Row(
            children: [
              _SocialButton(
                icon: Icons.facebook_rounded,
                label: 'Facebook',
                url: AppConstants.facebookUrl,
                palette: palette,
              ),
              SizedBox(width: 8.r),
              _SocialButton(
                icon: Icons.code_rounded,
                label: 'GitHub',
                url: AppConstants.githubUrl,
                palette: palette,
              ),
              SizedBox(width: 8.r),
              _SocialButton(
                icon: Icons.telegram,
                label: 'Telegram',
                url: AppConstants.telegramUrl,
                palette: palette,
              ),
            ],
          ),
          SizedBox(height: 10.r),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _open(AppConstants.repoUrl),
                  icon: Icon(
                    Icons.integration_instructions_outlined,
                    size: 18.sp,
                  ),
                  label: const Text('Source code'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.expressionText,
                    minimumSize: Size.fromHeight(46.r),
                    side: BorderSide(color: palette.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    textStyle: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.r),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _open(AppConstants.donateUrl),
                  icon: Icon(Icons.coffee_rounded, size: 18.sp),
                  label: const Text('Buy me a coffee'),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.equalsButton,
                    foregroundColor: palette.equalsButtonText,
                    minimumSize: Size.fromHeight(46.r),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    textStyle: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _open(String url) async {
  HapticFeedback.lightImpact();
  await UrlHelper.open(url);
}

/// A link to one of the developer's profiles: icon over name.
class _SocialButton extends StatelessWidget {
  const _SocialButton({
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
    return Expanded(
      child: Material(
        color: palette.specialButton,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () => _open(url),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 11.r),
            child: Column(
              children: [
                Icon(icon, size: 24.sp, color: palette.specialButtonText),
                SizedBox(height: 4.r),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: palette.specialButtonText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
