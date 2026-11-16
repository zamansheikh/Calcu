import 'dart:math' as math;

import 'package:calcu/core/services/billing_service.dart';
import 'package:calcu/core/services/storage_service.dart';
import 'package:calcu/data/repositories/theme_repository.dart';
import 'package:calcu/presentation/providers/theme_provider.dart';
import 'package:calcu/theme/calcu_palette.dart';
import 'package:calcu/theme/theme_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// WCAG contrast ratio between two opaque colours, from 1 (none) to 21.
double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  final palettes = <String, CalcuPalette>{
    for (final pack in ThemeCatalog.packs) ...{
      '${pack.name} light': pack.lightPalette,
      '${pack.name} dark': pack.darkPalette,
    },
  };

  group('every theme is readable', () {
    for (final MapEntry(key: name, value: p) in palettes.entries) {
      test(name, () {
        // Text against what it is drawn on. Key symbols are large and bold,
        // so 3:1 is the bar; the expression and result are held higher.
        final pairs = <String, (Color, Color, double)>{
          'expression on display': (p.expressionText, p.displayBackground, 7),
          'result on background': (
            p.resultText,
            p.backgroundGradient.first,
            4.5,
          ),
          'digit on its key': (p.numberButtonText, p.numberButton, 7),
          'symbol on a function key': (p.specialButtonText, p.specialButton, 3),
          'symbol on an operator key': (
            p.operatorButtonText,
            p.operatorButton,
            3,
          ),
          '= on its key': (p.equalsButtonText, p.equalsButton, 3),
          'AC on its key': (p.clearButtonText, p.clearButton, 3),
          'saved value on its chip': (p.savedChipText, p.savedChip, 3),
        };
        for (final MapEntry(key: what, value: (fg, bg, minimum))
            in pairs.entries) {
          expect(
            contrast(fg, bg),
            greaterThanOrEqualTo(minimum),
            reason: '$name: $what',
          );
        }
      });
    }
  });

  group('every key stands off the background', () {
    for (final pack in ThemeCatalog.packs) {
      // The keypad sits at the bottom of the gradient. A dark theme has
      // nothing but tone to separate a key from it; a light theme also has
      // the key's shadow, so only the plain number key is held to this.
      test('${pack.name} dark', () {
        final p = pack.darkPalette;
        for (final MapEntry(key: what, value: key) in {
          'number key': p.numberButton,
          'function key': p.specialButton,
          'operator key': p.operatorButton,
          'equals key': p.equalsButton,
        }.entries) {
          expect(
            contrast(key, p.backgroundGradient.last),
            greaterThanOrEqualTo(1.12),
            reason: '${pack.name} dark: $what',
          );
        }
      });

      test('${pack.name} light', () {
        final p = pack.lightPalette;
        expect(
          contrast(p.numberButton, p.backgroundGradient.last),
          greaterThanOrEqualTo(1.1),
          reason: '${pack.name} light: number key',
        );
      });
    }
  });

  group('ownership', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    Future<ThemeProvider> provider([
      Map<String, Object> stored = const {},
    ]) async {
      SharedPreferences.setMockInitialValues(stored);
      final repository = ThemeRepository(await StorageService.create());
      return ThemeProvider(
        repository: repository,
        billing: BillingService(repository),
      );
    }

    test('free packs can be applied without buying anything', () async {
      final theme = await provider();
      final free = ThemeCatalog.packs.where((pack) => !pack.isPremium);
      expect(
        free.map((pack) => pack.id),
        containsAll(['classic', 'rose', 'sand', 'citrus']),
      );
      for (final pack in free) {
        expect(theme.isOwned(pack.id), isTrue, reason: pack.id);
        expect(theme.selectPack(pack.id), isTrue, reason: pack.id);
        expect(theme.activePackId, pack.id);
      }
    });

    test('premium packs still need a purchase', () async {
      final theme = await provider();
      for (final pack in ThemeCatalog.packs.where((pack) => pack.isPremium)) {
        expect(theme.isOwned(pack.id), isFalse, reason: pack.id);
        expect(theme.selectPack(pack.id), isFalse, reason: pack.id);
      }
      expect(theme.activePackId, ThemeCatalog.defaultId);
    });

    test(
      'a free pack chosen earlier is still active after a restart',
      () async {
        final theme = await provider({'flutter.theme.active_pack_id': 'sand'});
        expect(theme.activePackId, 'sand');
      },
    );

    test('pack ids are unique', () {
      final ids = [for (final pack in ThemeCatalog.packs) pack.id];
      expect(ids.toSet(), hasLength(ids.length));
    });
  });
}
