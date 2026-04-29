import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../theme/calcu_palette.dart';
import '../pages/theme_store_page.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import 'animated_tap.dart';
import 'app_info_dialog.dart';

/// Custom top bar replacing AppBar — gives finer control over spacing,
/// gradients, and the theme toggle's animation.
class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  IconData _modeIcon(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => Icons.brightness_auto_outlined,
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: EdgeInsets.fromLTRB(14.r, 8.r, 14.r, 6.r),
      child: Row(
        children: [
          _IconBubble(
            icon: Icons.info_outline_rounded,
            tooltip: 'About Calcu',
            palette: palette,
            onTap: () => _showInfo(context),
            onLongPress: () => _confirmClearSaved(context),
          ),
          SizedBox(width: 10.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calcu',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: palette.expressionText,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  context.watch<ThemeProvider>().activePack.name,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: palette.placeholderText,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          _IconBubble(
            icon: Icons.palette_outlined,
            tooltip: 'Themes',
            palette: palette,
            onTap: () => _openStore(context),
          ),
          SizedBox(width: 8.r),
          Consumer<ThemeProvider>(
            builder: (context, theme, _) => _IconBubble(
              icon: _modeIcon(theme.themeMode),
              tooltip: 'Theme mode',
              palette: palette,
              onTap: () {
                theme.cycleMode();
                HapticFeedback.lightImpact();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showInfo(BuildContext context) async {
    HapticFeedback.selectionClick();
    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => AppInfoDialog(packageInfo: info),
    );
  }

  void _openStore(BuildContext context) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ThemeStorePage(),
      ),
    );
  }

  void _confirmClearSaved(BuildContext context) {
    final calc = context.read<CalculatorProvider>();
    if (calc.savedValues.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all saved values?'),
        content: const Text(
          'This removes every saved result. The action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              calc.clearSavedValues();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.tooltip,
    required this.palette,
    required this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final String tooltip;
  final CalcuPalette palette;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AnimatedTap(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          width: 42.r,
          height: 42.r,
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: palette.border),
          ),
          child: Icon(icon, size: 20.sp, color: palette.expressionText),
        ),
      ),
    );
  }
}
