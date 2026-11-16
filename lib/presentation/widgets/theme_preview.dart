import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_theme.dart';
import '../../theme/theme_catalog.dart';
import 'calculator_body.dart';

/// A theme pack shown as the calculator wearing it.
///
/// This is not a mock-up. The real [CalculatorBody] is laid out at full phone
/// size under the pack's palette and scaled down as a whole, so what the
/// preview shows is exactly what applying the theme gives. It takes its
/// content from the nearest `CalculatorProvider` and ignores touches.
class ThemePreview extends StatelessWidget {
  const ThemePreview({super.key, required this.pack, required this.dark});

  final ThemePack pack;
  final bool dark;

  /// Width over height of the preview: about that of a phone screen below
  /// its app bar.
  static const double aspectRatio = 0.58;

  @override
  Widget build(BuildContext context) {
    final palette = dark ? pack.darkPalette : pack.lightPalette;
    final width = MediaQuery.sizeOf(context).width;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: FittedBox(
        child: SizedBox(
          width: width,
          height: width / aspectRatio,
          child: Theme(
            data: AppTheme.build(
              palette: palette,
              brightness: dark ? Brightness.dark : Brightness.light,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: palette.backgroundGradient,
                ),
              ),
              child: IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.r),
                  child: const CalculatorBody(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
