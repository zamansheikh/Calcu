import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/services/billing_service.dart';
import '../../theme/calcu_palette.dart';
import '../../theme/theme_catalog.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_pack_tile.dart';

class ThemeStorePage extends StatelessWidget {
  const ThemeStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: palette.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Consumer<ThemeProvider>(
            builder: (context, theme, _) {
              _drainStatusMessages(context, theme);
              return Stack(
                children: [
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _Header(palette: palette)),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 16.r),
                        sliver: SliverList.separated(
                          itemCount: theme.packs.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 12.r),
                          itemBuilder: (context, index) {
                            final pack = theme.packs[index];
                            return ThemePackTile(
                              pack: pack,
                              priceLabel: theme.priceLabel(pack),
                              isOwned: theme.isOwned(pack.id),
                              isActive: theme.activePackId == pack.id,
                              useDarkPreview: theme.isDarkMode,
                              onUse: () => _applyPack(context, theme, pack),
                              onPurchase: () =>
                                  _purchasePack(context, theme, pack),
                            );
                          },
                        ),
                      ),
                      if (theme.isStoreConfigured)
                        SliverToBoxAdapter(
                          child: _RestoreSection(
                            palette: palette,
                            isBusy: theme.isBusy,
                            onRestore: () => _restore(context, theme),
                          ),
                        ),
                      SliverToBoxAdapter(child: _Footer(palette: palette)),
                    ],
                  ),
                  if (theme.isBusy)
                    const Positioned.fill(child: _BusyOverlay()),
                ],
              );
            },
          ),
        ),
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

  void _applyPack(
    BuildContext context,
    ThemeProvider theme,
    ThemePack pack,
  ) {
    theme.selectPack(pack.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${pack.name} applied')),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: ${e.message}')),
      );
    }
  }

  Future<void> _restore(BuildContext context, ThemeProvider theme) async {
    try {
      await theme.restorePurchases();
    } on BillingException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: ${e.message}')),
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.palette});
  final CalcuPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              SizedBox(width: 4.r),
              Text(
                'Theme store',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: palette.expressionText,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.r),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.r),
            child: Text(
              'Customise Calcu with curated themes. Purchases unlock instantly '
              'and stay on your account — restore them on any device you sign '
              'in to.',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: palette.placeholderText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestoreSection extends StatelessWidget {
  const _RestoreSection({
    required this.palette,
    required this.isBusy,
    required this.onRestore,
  });

  final CalcuPalette palette;
  final bool isBusy;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, 4.r, 20.r, 0),
      child: OutlinedButton.icon(
        onPressed: isBusy ? null : onRestore,
        icon: Icon(Icons.restore, size: 18.sp, color: palette.accent),
        label: Text(
          'Restore purchases',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: palette.accent,
          ),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, 48.r),
          side: BorderSide(color: palette.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.palette});
  final CalcuPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, 12.r, 20.r, 24.r),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                size: 18.sp, color: palette.placeholderText),
            SizedBox(width: 10.r),
            Expanded(
              child: Text(
                'Payments are processed by your store provider. Refunds and '
                'subscription changes are handled there too.',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 11.sp,
                  color: palette.placeholderText,
                  height: 1.4,
                ),
              ),
            ),
          ],
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
