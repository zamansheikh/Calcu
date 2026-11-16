import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection.dart';
import '../../core/services/billing_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/calcu_palette.dart';
import '../../theme/theme_catalog.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_preview.dart';

/// The theme picker: a carousel of the calculator in each theme.
///
/// Swiping brings a theme to the centre, and the whole page takes on its
/// colours, so a theme is seen as it would look before it is applied (or
/// bought). The button underneath applies or unlocks the one in the centre.
class ThemeStorePage extends StatefulWidget {
  const ThemeStorePage({super.key});

  @override
  State<ThemeStorePage> createState() => _ThemeStorePageState();
}

class _ThemeStorePageState extends State<ThemeStorePage> {
  /// Something for the previews to show: a little of everything the display
  /// can typeset.
  static const _sampleExpression = 'frac(3,4)+√(16+9)×2^(3)';

  late final PageController _pages;
  late final CalculatorProvider _sample;
  late int _focused;

  @override
  void initState() {
    super.initState();
    final theme = context.read<ThemeProvider>();
    _focused = theme.packs
        .indexWhere((pack) => pack.id == theme.activePackId)
        .clamp(0, theme.packs.length - 1);
    _pages = PageController(initialPage: _focused, viewportFraction: 0.72);
    // The previews get a calculator of their own, so they show the sample
    // rather than whatever is half-typed on the real one.
    _sample = sl<CalculatorProvider>()..loadExpression(_sampleExpression);
  }

  @override
  void dispose() {
    _pages.dispose();
    _sample.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pages.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        _drainStatusMessages(context, theme);
        final dark = theme.isDarkMode;
        final pack = theme.packs[_focused];
        final palette = dark ? pack.darkPalette : pack.lightPalette;

        return AnimatedTheme(
          duration: const Duration(milliseconds: 260),
          data: AppTheme.build(
            palette: palette,
            brightness: dark ? Brightness.dark : Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: palette.background,
            body: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: palette.backgroundGradient,
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _Header(
                          palette: palette,
                          dark: dark,
                          onToggleBrightness: theme.toggleLightDark,
                        ),
                        Expanded(child: _carousel(theme, dark)),
                        SizedBox(height: 14.r),
                        _Dots(
                          packs: theme.packs,
                          focused: _focused,
                          onTap: _goTo,
                        ),
                        SizedBox(height: 14.r),
                        _Details(
                          pack: pack,
                          palette: palette,
                          priceLabel: theme.priceLabel(pack),
                          isOwned: theme.isOwned(pack.id),
                        ),
                        SizedBox(height: 14.r),
                        _ActionButton(
                          pack: pack,
                          palette: palette,
                          priceLabel: theme.priceLabel(pack),
                          isOwned: theme.isOwned(pack.id),
                          isActive: theme.activePackId == pack.id,
                          onApply: () => _applyPack(context, theme, pack),
                          onPurchase: () => _purchasePack(context, theme, pack),
                        ),
                        if (theme.isStoreConfigured)
                          TextButton(
                            onPressed: theme.isBusy
                                ? null
                                : () => _restore(context, theme),
                            child: Text(
                              'Restore purchases',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: palette.placeholderText,
                              ),
                            ),
                          )
                        else
                          SizedBox(height: 12.r),
                      ],
                    ),
                    if (theme.isBusy)
                      const Positioned.fill(child: _BusyOverlay()),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _carousel(ThemeProvider theme, bool dark) {
    return ChangeNotifierProvider<CalculatorProvider>.value(
      value: _sample,
      child: PageView.builder(
        controller: _pages,
        physics: const BouncingScrollPhysics(),
        itemCount: theme.packs.length,
        onPageChanged: (index) => setState(() => _focused = index),
        itemBuilder: (context, index) {
          final pack = theme.packs[index];
          final isFocused = index == _focused;
          return Center(
            child: GestureDetector(
              onTap: isFocused ? null : () => _goTo(index),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                scale: isFocused ? 1 : 0.9,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 260),
                  opacity: isFocused ? 1 : 0.55,
                  child: _PreviewCard(
                    pack: pack,
                    dark: dark,
                    isActive: theme.activePackId == pack.id,
                    isLocked: !theme.isOwned(pack.id),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _drainStatusMessages(BuildContext context, ThemeProvider theme) {
    final msg = theme.consumeStatusMessage();
    if (msg == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(msg)));
    });
  }

  void _applyPack(BuildContext context, ThemeProvider theme, ThemePack pack) {
    theme.selectPack(pack.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${pack.name} applied')));
  }

  Future<void> _purchasePack(
    BuildContext context,
    ThemeProvider theme,
    ThemePack pack,
  ) async {
    final priceLabel = theme.priceLabel(pack);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Unlock ${pack.name}'),
        content: Text(
          theme.isStoreConfigured
              ? 'Continue to checkout? You will be charged '
                    '${priceLabel ?? 'the listed price'}.'
              : 'Add ${pack.name} to your library? '
                    '(billing is mocked locally — no charge)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(theme.isStoreConfigured ? 'Continue' : 'Unlock'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final ok = await theme.purchasePack(pack.id);
      if (!ok || !context.mounted) return;
      theme.selectPack(pack.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${pack.name} unlocked & applied')),
      );
    } on BillingException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Purchase failed: ${e.message}')));
    }
  }

  Future<void> _restore(BuildContext context, ThemeProvider theme) async {
    try {
      await theme.restorePurchases();
    } on BillingException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Restore failed: ${e.message}')));
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.palette,
    required this.dark,
    required this.onToggleBrightness,
  });

  final CalcuPalette palette;
  final bool dark;
  final VoidCallback onToggleBrightness;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.r, 4.r, 8.r, 6.r),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
            icon: Icon(Icons.arrow_back_rounded, color: palette.expressionText),
          ),
          SizedBox(width: 2.r),
          Expanded(
            child: Text(
              'Themes',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: palette.expressionText,
              ),
            ),
          ),
          // Every theme has a light and a dark side; this flips the preview
          // (and the app) between them.
          IconButton(
            onPressed: onToggleBrightness,
            tooltip: dark ? 'Show light' : 'Show dark',
            icon: Icon(
              dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: palette.expressionText,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.pack,
    required this.dark,
    required this.isActive,
    required this.isLocked,
  });

  final ThemePack pack;
  final bool dark;
  final bool isActive;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(26.r);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: isActive
                  ? pack.previewColor
                  : Colors.white.withValues(alpha: dark ? 0.14 : 0.7),
              width: isActive ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.45 : 0.14),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: ThemePreview(pack: pack, dark: dark),
          ),
        ),
        if (isActive || isLocked)
          Positioned(
            top: 12.r,
            right: 12.r,
            child: _Badge(
              icon: isActive ? Icons.check_rounded : Icons.lock_rounded,
              color: pack.previewColor,
            ),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.r,
      height: 30.r,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Icon(icon, size: 17.sp, color: Colors.white),
    );
  }
}

/// One dot per theme, in that theme's own colour. Tapping one jumps to it.
class _Dots extends StatelessWidget {
  const _Dots({
    required this.packs,
    required this.focused,
    required this.onTap,
  });

  final List<ThemePack> packs;
  final int focused;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < packs.length; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(i),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.r, vertical: 6.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: i == focused ? 22.r : 9.r,
                height: 9.r,
                decoration: BoxDecoration(
                  color: packs[i].previewColor.withValues(
                    alpha: i == focused ? 1 : 0.5,
                  ),
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.pack,
    required this.palette,
    required this.priceLabel,
    required this.isOwned,
  });

  final ThemePack pack;
  final CalcuPalette palette;
  final String? priceLabel;
  final bool isOwned;

  @override
  Widget build(BuildContext context) {
    final tag = !pack.isPremium
        ? 'Free'
        : isOwned
        ? 'Owned'
        : 'Premium';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.r),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  pack.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: palette.expressionText,
                  ),
                ),
              ),
              SizedBox(width: 10.r),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 4.r),
                decoration: BoxDecoration(
                  color: palette.specialButton,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: palette.specialButtonText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.r),
          // Two lines are reserved so the button below does not jump as
          // descriptions of different lengths swipe past.
          SizedBox(
            height: 38.sp,
            child: Text(
              pack.description,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: palette.placeholderText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.pack,
    required this.palette,
    required this.priceLabel,
    required this.isOwned,
    required this.isActive,
    required this.onApply,
    required this.onPurchase,
  });

  final ThemePack pack;
  final CalcuPalette palette;
  final String? priceLabel;
  final bool isOwned;
  final bool isActive;
  final VoidCallback onApply;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final price = priceLabel ?? pack.priceLabel ?? '';
    final (IconData icon, String label, VoidCallback? onPressed) = isActive
        ? (Icons.check_circle_rounded, 'In use', null)
        : isOwned
        ? (Icons.brush_rounded, 'Apply ${pack.name}', onApply)
        : (
            Icons.lock_open_rounded,
            price.isEmpty ? 'Unlock ${pack.name}' : 'Unlock for $price',
            onPurchase,
          );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.r),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20.sp),
        label: Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: FilledButton.styleFrom(
          minimumSize: Size(double.infinity, 54.r),
          backgroundColor: palette.equalsButton,
          foregroundColor: palette.equalsButtonText,
          disabledBackgroundColor: palette.specialButton,
          disabledForegroundColor: palette.specialButtonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
      ),
    );
  }
}

class _BusyOverlay extends StatelessWidget {
  const _BusyOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black26,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: context.palette.surfaceElevated,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12.r),
              Text(
                'Working…',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: context.palette.expressionText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
