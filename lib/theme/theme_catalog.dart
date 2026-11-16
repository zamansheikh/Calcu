import 'package:flutter/material.dart';

import 'calcu_palette.dart';

/// Identifies a single theme pack. New packs append; never reorder existing
/// values — these IDs are persisted to local storage.
class ThemePackId {
  static const String classic = 'classic';
  static const String midnight = 'midnight';
  static const String sunset = 'sunset';
  static const String forest = 'forest';
  static const String ocean = 'ocean';
  static const String monochrome = 'monochrome';
  static const String rose = 'rose';
  static const String sand = 'sand';
  static const String citrus = 'citrus';
}

/// A theme pack ships a coordinated light + dark palette. Premium packs are
/// gated behind ownership and unlocked through the in-app store; the others
/// are free to everyone.
@immutable
class ThemePack {
  const ThemePack({
    required this.id,
    required this.name,
    required this.description,
    required this.lightPalette,
    required this.darkPalette,
    required this.previewColor,
    this.isPremium = false,
    this.priceLabel,
  });

  final String id;
  final String name;
  final String description;
  final CalcuPalette lightPalette;
  final CalcuPalette darkPalette;
  final Color previewColor;
  final bool isPremium;
  final String? priceLabel;
}

class ThemeCatalog {
  ThemeCatalog._();

  /// In the order the store lists them: the free packs, then the premium.
  static final List<ThemePack> packs = <ThemePack>[
    _classicPack,
    _rosePack,
    _sandPack,
    _citrusPack,
    _midnightPack,
    _sunsetPack,
    _forestPack,
    _oceanPack,
    _monochromePack,
  ];

  static ThemePack byId(String id) =>
      packs.firstWhere((p) => p.id == id, orElse: () => _classicPack);

  static const String defaultId = ThemePackId.classic;

  // ---------------------------------------------------------------- Classic
  static final ThemePack _classicPack = ThemePack(
    id: ThemePackId.classic,
    name: 'Classic',
    description: 'Clean, balanced blues — the original Calcu look.',
    previewColor: const Color(0xFF0060E5),
    lightPalette: const CalcuPalette(
      background: Color(0xFFF5F7FB),
      surface: Color(0xFFFFFFFF),
      surfaceElevated: Color(0xFFFFFFFF),
      displayBackground: Color(0xFFFFFFFF),
      border: Color(0x14000000),
      divider: Color(0x12000000),
      numberButton: Color(0xFFFFFFFF),
      numberButtonText: Color(0xFF1B2333),
      specialButton: Color(0xFFE6ECF5),
      specialButtonText: Color(0xFF0060E5),
      operatorButton: Color(0xFFDCE7FA),
      operatorButtonText: Color(0xFF0060E5),
      equalsButton: Color(0xFF0060E5),
      equalsButtonText: Color(0xFFFFFFFF),
      clearButton: Color(0xFFFFE5E5),
      clearButtonText: Color(0xFFE5484D),
      expressionText: Color(0xFF1B2333),
      resultText: Color(0xFF0060E5),
      placeholderText: Color(0xFF8A93A6),
      cursor: Color(0xFF0060E5),
      savedChip: Color(0xFFE6ECF5),
      savedChipText: Color(0xFF0060E5),
      error: Color(0xFFE5484D),
      accent: Color(0xFF0060E5),
      backgroundGradient: [Color(0xFFF5F7FB), Color(0xFFE9EEF7)],
    ),
    darkPalette: const CalcuPalette(
      background: Color(0xFF0E1118),
      surface: Color(0xFF161A20),
      surfaceElevated: Color(0xFF1E232C),
      displayBackground: Color(0xFF161A20),
      border: Color(0x1FFFFFFF),
      divider: Color(0x14FFFFFF),
      numberButton: Color(0xFF242933),
      numberButtonText: Color(0xFFE9EEF7),
      specialButton: Color(0xFF363E4C),
      specialButtonText: Color(0xFFCBE1FF),
      operatorButton: Color(0xFF1E2A44),
      operatorButtonText: Color(0xFF7FB1FF),
      equalsButton: Color(0xFF0060E5),
      equalsButtonText: Color(0xFFFFFFFF),
      clearButton: Color(0xFF3A1E22),
      clearButtonText: Color(0xFFFF7A7E),
      expressionText: Color(0xFFE9EEF7),
      resultText: Color(0xFF7FB1FF),
      placeholderText: Color(0xFF6B7488),
      cursor: Color(0xFF7FB1FF),
      savedChip: Color(0xFF242933),
      savedChipText: Color(0xFFCBE1FF),
      error: Color(0xFFFF7A7E),
      accent: Color(0xFF0060E5),
      backgroundGradient: [Color(0xFF0E1118), Color(0xFF161A20)],
    ),
  );

  // -------------------------------------------------------------------- Rose
  static final ThemePack _rosePack = ThemePack(
    id: ThemePackId.rose,
    name: 'Rose',
    description: 'Soft pinks with a raspberry accent.',
    previewColor: const Color(0xFFE64980),
    lightPalette: _palette(
      brightness: Brightness.light,
      wash: [Color(0xFFFFF7F9), Color(0xFFFFE6ED)],
      display: Color(0xFFFFFFFF),
      ink: Color(0xFF2B1420),
      numberKey: Color(0xFFFFFFFF),
      functionKey: Color(0xFFFFD6E2),
      operatorKey: Color(0xFFFFC2D4),
      tint: Color(0xFFC2255C),
      accent: Color(0xFFE64980),
    ),
    darkPalette: _palette(
      brightness: Brightness.dark,
      wash: [Color(0xFF14080E), Color(0xFF210E18)],
      display: Color(0xFF1D0D16),
      ink: Color(0xFFFFE9F0),
      numberKey: Color(0xFF341A28),
      functionKey: Color(0xFF472335),
      operatorKey: Color(0xFF582742),
      tint: Color(0xFFFFA8C5),
      accent: Color(0xFFF0518A),
    ),
  );

  // -------------------------------------------------------------------- Sand
  static final ThemePack _sandPack = ThemePack(
    id: ThemePackId.sand,
    name: 'Sand',
    description: 'Warm paper and caramel, easy on the eyes.',
    previewColor: const Color(0xFFB8651B),
    lightPalette: _palette(
      brightness: Brightness.light,
      wash: [Color(0xFFFCF8EF), Color(0xFFF3E8D4)],
      display: Color(0xFFFFFDF7),
      ink: Color(0xFF2E2418),
      numberKey: Color(0xFFFFFDF7),
      functionKey: Color(0xFFEBDDC0),
      operatorKey: Color(0xFFE0CBA3),
      tint: Color(0xFF8A5422),
      accent: Color(0xFFB8651B),
    ),
    darkPalette: _palette(
      brightness: Brightness.dark,
      wash: [Color(0xFF14110B), Color(0xFF211A10)],
      display: Color(0xFF1D170E),
      ink: Color(0xFFF4EAD8),
      numberKey: Color(0xFF30281B),
      functionKey: Color(0xFF403423),
      operatorKey: Color(0xFF4E3F27),
      tint: Color(0xFFEBC68E),
      accent: Color(0xFFD98A3D),
      onAccent: Color(0xFF2A1A05),
    ),
  );

  // ------------------------------------------------------------------ Citrus
  static final ThemePack _citrusPack = ThemePack(
    id: ThemePackId.citrus,
    name: 'Citrus',
    description: 'Bright lemon on charcoal. Hard to miss.',
    previewColor: const Color(0xFFE0A800),
    lightPalette: _palette(
      brightness: Brightness.light,
      wash: [Color(0xFFFFFEF2), Color(0xFFFFF1AE)],
      display: Color(0xFFFFFFFF),
      ink: Color(0xFF262108),
      numberKey: Color(0xFFFFFFFF),
      functionKey: Color(0xFFFFE680),
      operatorKey: Color(0xFFFFD84D),
      tint: Color(0xFF7A5900),
      accent: Color(0xFFFFC600),
      onAccent: Color(0xFF2B2200),
      result: Color(0xFF8A6500),
    ),
    darkPalette: _palette(
      brightness: Brightness.dark,
      wash: [Color(0xFF100F08), Color(0xFF1C190A)],
      display: Color(0xFF19160B),
      ink: Color(0xFFFFF8D6),
      numberKey: Color(0xFF2A2612),
      functionKey: Color(0xFF3A3418),
      operatorKey: Color(0xFF4A4012),
      tint: Color(0xFFFFE066),
      accent: Color(0xFFFFD21F),
      onAccent: Color(0xFF1F1A00),
    ),
  );

  // ---------------------------------------------------------------- Midnight
  static final ThemePack _midnightPack = ThemePack(
    id: ThemePackId.midnight,
    name: 'Midnight',
    description: 'Deep indigo and electric violet, with answers in aqua.',
    previewColor: const Color(0xFF8B5CF6),
    isPremium: true,
    priceLabel: '\$0.20',
    lightPalette: _palette(
      brightness: Brightness.light,
      wash: [Color(0xFFF8F5FF), Color(0xFFEBE1FF)],
      display: Color(0xFFFFFFFF),
      ink: Color(0xFF1F1535),
      numberKey: Color(0xFFFFFFFF),
      functionKey: Color(0xFFDFD0FF),
      operatorKey: Color(0xFFCDB7FF),
      tint: Color(0xFF6D28D9),
      accent: Color(0xFF7C3AED),
    ),
    darkPalette: _palette(
      brightness: Brightness.dark,
      wash: [Color(0xFF0A0717), Color(0xFF170D36)],
      display: Color(0xFF130C2B),
      ink: Color(0xFFF1EAFF),
      numberKey: Color(0xFF241A4D),
      functionKey: Color(0xFF33246B),
      operatorKey: Color(0xFF40288C),
      tint: Color(0xFFCDBBFF),
      accent: Color(0xFF9166FF),
      result: Color(0xFF8BE9FD),
    ),
  );

  // ------------------------------------------------------------------ Sunset
  static final ThemePack _sunsetPack = ThemePack(
    id: ThemePackId.sunset,
    name: 'Sunset',
    description: 'Plum dusk, peach light and an ember-orange equals.',
    previewColor: const Color(0xFFF97316),
    isPremium: true,
    priceLabel: '\$0.25',
    lightPalette: _palette(
      brightness: Brightness.light,
      wash: [Color(0xFFFFF6EF), Color(0xFFFFE3DA)],
      display: Color(0xFFFFFFFF),
      ink: Color(0xFF2B1512),
      numberKey: Color(0xFFFFFFFF),
      functionKey: Color(0xFFFFD9C7),
      operatorKey: Color(0xFFFFC4B5),
      tint: Color(0xFFC2371F),
      accent: Color(0xFFF9603A),
    ),
    darkPalette: _palette(
      brightness: Brightness.dark,
      wash: [Color(0xFF160810), Color(0xFF2A0F14)],
      display: Color(0xFF200C13),
      ink: Color(0xFFFFEDE3),
      numberKey: Color(0xFF3A1B25),
      functionKey: Color(0xFF4D2430),
      operatorKey: Color(0xFF5F2440),
      tint: Color(0xFFFFB59A),
      accent: Color(0xFFEE5526),
      result: Color(0xFFFFC38F),
    ),
  );

  // ------------------------------------------------------------------ Forest
  static final ThemePack _forestPack = ThemePack(
    id: ThemePackId.forest,
    name: 'Forest',
    description: 'Deep pine and fresh mint. Calm and focused.',
    previewColor: const Color(0xFF059669),
    isPremium: true,
    priceLabel: '\$0.25',
    lightPalette: _palette(
      brightness: Brightness.light,
      wash: [Color(0xFFF2F8F1), Color(0xFFDDEFDF)],
      display: Color(0xFFFFFFFF),
      ink: Color(0xFF10261A),
      numberKey: Color(0xFFFFFFFF),
      functionKey: Color(0xFFCBE7CF),
      operatorKey: Color(0xFFB0DAB9),
      tint: Color(0xFF1B7A48),
      accent: Color(0xFF1F8F55),
    ),
    darkPalette: _palette(
      brightness: Brightness.dark,
      wash: [Color(0xFF06130D), Color(0xFF0C2318)],
      display: Color(0xFF0A1D14),
      ink: Color(0xFFE4F6EA),
      numberKey: Color(0xFF173626),
      functionKey: Color(0xFF1F4A34),
      operatorKey: Color(0xFF24573C),
      tint: Color(0xFF9CEBC0),
      accent: Color(0xFF34D399),
      onAccent: Color(0xFF04261A),
    ),
  );

  // ------------------------------------------------------------------- Ocean
  static final ThemePack _oceanPack = ThemePack(
    id: ThemePackId.ocean,
    name: 'Ocean',
    description: 'Navy depths rising to bright aqua.',
    previewColor: const Color(0xFF0891B2),
    isPremium: true,
    priceLabel: '\$0.30',
    lightPalette: _palette(
      brightness: Brightness.light,
      wash: [Color(0xFFF0FAFC), Color(0xFFD6F1F7)],
      display: Color(0xFFFFFFFF),
      ink: Color(0xFF0D2A33),
      numberKey: Color(0xFFFFFFFF),
      functionKey: Color(0xFFBFE8F1),
      operatorKey: Color(0xFF9FDCEA),
      tint: Color(0xFF0B6F83),
      accent: Color(0xFF0C97B5),
    ),
    darkPalette: _palette(
      brightness: Brightness.dark,
      wash: [Color(0xFF04111D), Color(0xFF06283A)],
      display: Color(0xFF071E2C),
      ink: Color(0xFFE3F8FC),
      numberKey: Color(0xFF0F3446),
      functionKey: Color(0xFF164A60),
      operatorKey: Color(0xFF12506B),
      tint: Color(0xFF8BE6F5),
      accent: Color(0xFF22C3E6),
      onAccent: Color(0xFF032533),
    ),
  );

  // -------------------------------------------------------------- Monochrome
  static final ThemePack _monochromePack = ThemePack(
    id: ThemePackId.monochrome,
    name: 'Monochrome',
    description: 'True black and pure white. Nothing else.',
    previewColor: const Color(0xFF1F2937),
    isPremium: true,
    priceLabel: '\$0.30',
    lightPalette: _palette(
      brightness: Brightness.light,
      wash: [Color(0xFFFAFAFA), Color(0xFFEDEDED)],
      display: Color(0xFFFFFFFF),
      ink: Color(0xFF111111),
      numberKey: Color(0xFFFFFFFF),
      functionKey: Color(0xFFE0E0E0),
      operatorKey: Color(0xFFCFCFCF),
      tint: Color(0xFF111111),
      accent: Color(0xFF111111),
    ),
    darkPalette: _palette(
      brightness: Brightness.dark,
      wash: [Color(0xFF000000), Color(0xFF0A0A0A)],
      display: Color(0xFF0E0E0E),
      ink: Color(0xFFF5F5F5),
      numberKey: Color(0xFF1A1A1A),
      functionKey: Color(0xFF272727),
      operatorKey: Color(0xFF343434),
      tint: Color(0xFFFFFFFF),
      accent: Color(0xFFFFFFFF),
      onAccent: Color(0xFF000000),
    ),
  );

  /// Builds a palette from the few colours that give a theme its character:
  /// the background [wash], the three tones of key, the [tint] their symbols
  /// are drawn in, and the [accent] of the equals key. Everything else
  /// (borders, placeholder text, the clear key) follows from those and from
  /// [brightness].
  ///
  /// In a dark theme each tone of key should be visibly lighter than the
  /// bottom of the wash, where the keypad sits; in a light one, darker.
  static CalcuPalette _palette({
    required Brightness brightness,
    required List<Color> wash,
    required Color display,
    required Color ink,
    required Color numberKey,
    required Color functionKey,
    required Color operatorKey,
    required Color tint,
    required Color accent,
    Color onAccent = const Color(0xFFFFFFFF),
    Color? result,
  }) {
    final dark = brightness == Brightness.dark;
    final resultInk = result ?? tint;
    final alert = dark ? const Color(0xFFFF8A8E) : const Color(0xFFDC3B40);
    return CalcuPalette(
      background: wash.first,
      surface: display,
      surfaceElevated: dark
          ? Color.lerp(display, const Color(0xFFFFFFFF), 0.07)!
          : const Color(0xFFFFFFFF),
      displayBackground: display,
      border: dark ? const Color(0x22FFFFFF) : const Color(0x14000000),
      divider: dark ? const Color(0x14FFFFFF) : const Color(0x12000000),
      numberButton: numberKey,
      numberButtonText: ink,
      specialButton: functionKey,
      specialButtonText: tint,
      operatorButton: operatorKey,
      operatorButtonText: tint,
      equalsButton: accent,
      equalsButtonText: onAccent,
      clearButton: dark ? const Color(0xFF3F1A22) : const Color(0xFFFFE3E3),
      clearButtonText: alert,
      expressionText: ink,
      resultText: resultInk,
      placeholderText: Color.lerp(ink, wash.first, 0.55)!,
      cursor: dark ? resultInk : accent,
      savedChip: functionKey,
      savedChipText: tint,
      error: alert,
      accent: accent,
      backgroundGradient: wash,
    );
  }
}
