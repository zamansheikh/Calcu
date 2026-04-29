import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

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
              return CustomScrollView(
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
                  SliverToBoxAdapter(child: _Footer(palette: palette)),
                ],
              );
            },
          ),
        ),
      ),
    );
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Unlock ${pack.name}'),
        content: Text(
          pack.priceLabel == null
              ? 'Add ${pack.name} to your library?'
              : 'Unlock ${pack.name} for ${pack.priceLabel}? '
                  'Billing is mocked in this build — no charge will be made.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await theme.purchasePack(pack.id);
    if (!ok || !context.mounted) return;
    theme.selectPack(pack.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${pack.name} unlocked & applied')),
    );
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
              'Customise Calcu with curated themes. Owned packs apply instantly; '
              'premium packs ship with a one-time unlock.',
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

class _Footer extends StatelessWidget {
  const _Footer({required this.palette});
  final CalcuPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, 8.r, 20.r, 24.r),
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
                'Premium themes are stubbed for local testing. Wire the platform '
                'billing API into ThemeProvider.purchasePack to ship real IAP.',
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
