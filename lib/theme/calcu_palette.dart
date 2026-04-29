import 'package:flutter/material.dart';

/// Calculator-specific palette exposed via `ThemeExtension` so any widget can
/// pull theme colors without hard-coding to a single `ColorScheme` slot.
///
/// Adding a new color here is the only place that needs updating when a new
/// theme pack is introduced.
@immutable
class CalcuPalette extends ThemeExtension<CalcuPalette> {
  const CalcuPalette({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.displayBackground,
    required this.border,
    required this.divider,
    required this.numberButton,
    required this.numberButtonText,
    required this.specialButton,
    required this.specialButtonText,
    required this.operatorButton,
    required this.operatorButtonText,
    required this.equalsButton,
    required this.equalsButtonText,
    required this.clearButton,
    required this.clearButtonText,
    required this.expressionText,
    required this.resultText,
    required this.placeholderText,
    required this.cursor,
    required this.savedChip,
    required this.savedChipText,
    required this.error,
    required this.accent,
    required this.backgroundGradient,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color displayBackground;
  final Color border;
  final Color divider;

  final Color numberButton;
  final Color numberButtonText;
  final Color specialButton;
  final Color specialButtonText;
  final Color operatorButton;
  final Color operatorButtonText;
  final Color equalsButton;
  final Color equalsButtonText;
  final Color clearButton;
  final Color clearButtonText;

  final Color expressionText;
  final Color resultText;
  final Color placeholderText;
  final Color cursor;

  final Color savedChip;
  final Color savedChipText;

  final Color error;
  final Color accent;

  /// Two-stop gradient used for app background. Keep both stops opaque so the
  /// content above remains readable on lower-contrast themes.
  final List<Color> backgroundGradient;

  @override
  CalcuPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? displayBackground,
    Color? border,
    Color? divider,
    Color? numberButton,
    Color? numberButtonText,
    Color? specialButton,
    Color? specialButtonText,
    Color? operatorButton,
    Color? operatorButtonText,
    Color? equalsButton,
    Color? equalsButtonText,
    Color? clearButton,
    Color? clearButtonText,
    Color? expressionText,
    Color? resultText,
    Color? placeholderText,
    Color? cursor,
    Color? savedChip,
    Color? savedChipText,
    Color? error,
    Color? accent,
    List<Color>? backgroundGradient,
  }) {
    return CalcuPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      displayBackground: displayBackground ?? this.displayBackground,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      numberButton: numberButton ?? this.numberButton,
      numberButtonText: numberButtonText ?? this.numberButtonText,
      specialButton: specialButton ?? this.specialButton,
      specialButtonText: specialButtonText ?? this.specialButtonText,
      operatorButton: operatorButton ?? this.operatorButton,
      operatorButtonText: operatorButtonText ?? this.operatorButtonText,
      equalsButton: equalsButton ?? this.equalsButton,
      equalsButtonText: equalsButtonText ?? this.equalsButtonText,
      clearButton: clearButton ?? this.clearButton,
      clearButtonText: clearButtonText ?? this.clearButtonText,
      expressionText: expressionText ?? this.expressionText,
      resultText: resultText ?? this.resultText,
      placeholderText: placeholderText ?? this.placeholderText,
      cursor: cursor ?? this.cursor,
      savedChip: savedChip ?? this.savedChip,
      savedChipText: savedChipText ?? this.savedChipText,
      error: error ?? this.error,
      accent: accent ?? this.accent,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
    );
  }

  @override
  CalcuPalette lerp(ThemeExtension<CalcuPalette>? other, double t) {
    if (other is! CalcuPalette) return this;
    return CalcuPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      displayBackground:
          Color.lerp(displayBackground, other.displayBackground, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      numberButton: Color.lerp(numberButton, other.numberButton, t)!,
      numberButtonText:
          Color.lerp(numberButtonText, other.numberButtonText, t)!,
      specialButton: Color.lerp(specialButton, other.specialButton, t)!,
      specialButtonText:
          Color.lerp(specialButtonText, other.specialButtonText, t)!,
      operatorButton: Color.lerp(operatorButton, other.operatorButton, t)!,
      operatorButtonText:
          Color.lerp(operatorButtonText, other.operatorButtonText, t)!,
      equalsButton: Color.lerp(equalsButton, other.equalsButton, t)!,
      equalsButtonText:
          Color.lerp(equalsButtonText, other.equalsButtonText, t)!,
      clearButton: Color.lerp(clearButton, other.clearButton, t)!,
      clearButtonText: Color.lerp(clearButtonText, other.clearButtonText, t)!,
      expressionText: Color.lerp(expressionText, other.expressionText, t)!,
      resultText: Color.lerp(resultText, other.resultText, t)!,
      placeholderText: Color.lerp(placeholderText, other.placeholderText, t)!,
      cursor: Color.lerp(cursor, other.cursor, t)!,
      savedChip: Color.lerp(savedChip, other.savedChip, t)!,
      savedChipText: Color.lerp(savedChipText, other.savedChipText, t)!,
      error: Color.lerp(error, other.error, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      backgroundGradient: _lerpGradient(backgroundGradient, other.backgroundGradient, t),
    );
  }

  static List<Color> _lerpGradient(List<Color> a, List<Color> b, double t) {
    final length = a.length < b.length ? a.length : b.length;
    return List.generate(length, (i) => Color.lerp(a[i], b[i], t)!);
  }
}

extension CalcuPaletteContext on BuildContext {
  CalcuPalette get palette => Theme.of(this).extension<CalcuPalette>()!;
}
