import 'dart:math' as math;

import 'package:calcu/core/math/exact_form.dart';
import 'package:calcu/core/math/expression_editor.dart';
import 'package:calcu/core/services/calculator_engine.dart';
import 'package:calcu/core/services/storage_service.dart';
import 'package:calcu/data/models/saved_entry.dart';
import 'package:calcu/data/repositories/saved_values_repository.dart';
import 'package:calcu/presentation/providers/calculator_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ExactForm', () {
    test('fractions', () {
      expect(ExactForm.of(0.75), 'frac(3,4)');
      expect(ExactForm.of(1 / 3), 'frac(1,3)');
      expect(ExactForm.of(-5 / 3), '-frac(5,3)');
      expect(ExactForm.of(0.1 + 0.2), 'frac(3,10)');
      expect(ExactForm.of(22 / 7), 'frac(22,7)');
    });

    test('whole numbers have no other form', () {
      expect(ExactForm.of(5), isNull);
      expect(ExactForm.of(0), isNull);
      expect(ExactForm.of(-12), isNull);
      // Three, apart from floating-point residue.
      expect(ExactForm.of(2.9999999999999996), isNull);
    });

    test('square roots', () {
      expect(ExactForm.of(math.sqrt(2)), '√(2)');
      expect(ExactForm.of(math.sqrt(8)), '2√(2)');
      expect(ExactForm.of(math.sqrt(0.5)), 'frac(√(2),2)');
      expect(ExactForm.of(-math.sqrt(3) / 2), '-frac(√(3),2)');
    });

    test('multiples of π', () {
      expect(ExactForm.of(math.pi), 'π');
      expect(ExactForm.of(2 * math.pi), '2π');
      expect(ExactForm.of(math.pi / 2), 'frac(π,2)');
      expect(ExactForm.of(3 * math.pi / 4), 'frac(3π,4)');
    });

    test('numbers with no simple form are left alone', () {
      expect(ExactForm.of(math.e), isNull);
      expect(ExactForm.of(math.log(2)), isNull);
      expect(ExactForm.of(math.pi + 1), isNull);
      expect(ExactForm.of(math.sqrt(2) + math.sqrt(3)), isNull);
      // Too large for its digits after the point to mean anything.
      expect(ExactForm.of(1e6 * math.pi + 0.3), isNull);
    });

    test('never invents a fraction for a random decimal', () {
      final random = math.Random(7);
      var invented = 0;
      for (var i = 0; i < 20000; i++) {
        if (ExactForm.of(random.nextDouble() * 100) != null) invented++;
      }
      expect(invented, 0);
    });
  });

  group('asOperand', () {
    test('brackets only what needs them', () {
      expect(ExpressionEditor.asOperand('42'), '42');
      expect(ExpressionEditor.asOperand('frac(1,2)'), 'frac(1,2)');
      expect(ExpressionEditor.asOperand('√(9)'), '√(9)');
      expect(ExpressionEditor.asOperand('(1+2)'), '(1+2)');
      expect(ExpressionEditor.asOperand('1+2'), '(1+2)');
      expect(ExpressionEditor.asOperand('-5'), '(-5)');
      expect(ExpressionEditor.asOperand('2^3'), '(2^3)');
    });
  });

  group('engine', () {
    const engine = CalculatorEngine();

    test('reports the closed form alongside the decimal', () {
      final result = engine.evaluate('3÷4');
      expect(result.display, '0.75');
      expect(result.exact, 'frac(3,4)');
      expect(engine.evaluate('frac(1,2)+frac(1,3)').exact, 'frac(5,6)');
      expect(engine.evaluate('√(8)').exact, '2√(2)');
      expect(engine.evaluate('6÷2').exact, isNull);
    });
  });

  group('pressing = again', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    Future<CalculatorProvider> provider() async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.create();
      return CalculatorProvider(
        engine: const CalculatorEngine(),
        savedValuesRepository: SavedValuesRepository(storage),
      );
    }

    test('steps decimal → fraction → precise → decimal', () async {
      final calc = await provider();
      calc
        ..insertNumber('3')
        ..insertOperator('÷')
        ..insertNumber('4');
      expect(calc.nextResultFormat, isNull, reason: 'not settled yet');

      calc.calculate();
      expect(calc.output, '0.75');
      expect(calc.nextResultFormat, ResultFormat.fraction);

      calc.calculate();
      expect(calc.resultFormat, ResultFormat.fraction);
      expect(calc.output, 'frac(3,4)');

      calc.calculate();
      expect(calc.output, '0.750');

      calc.calculate();
      expect(calc.output, '0.75');
    });

    test('skips the fraction when there is none', () async {
      final calc = await provider();
      calc
        ..insertNumber('6')
        ..insertOperator('÷')
        ..insertNumber('2')
        ..calculate();
      expect(calc.nextResultFormat, ResultFormat.precise);
      calc.calculate();
      expect(calc.output, '3.000');
    });

    test('editing the expression returns to the decimal', () async {
      final calc = await provider();
      calc
        ..insertNumber('1')
        ..insertOperator('÷')
        ..insertNumber('3')
        ..calculate()
        ..calculate();
      expect(calc.resultFormat, ResultFormat.fraction);

      calc.insertNumber('0');
      expect(calc.resultFormat, ResultFormat.decimal);
      expect(calc.nextResultFormat, isNull);
    });

    test('moving the caret keeps the format', () async {
      final calc = await provider();
      calc
        ..insertNumber('1')
        ..insertOperator('÷')
        ..insertNumber('3')
        ..calculate()
        ..calculate()
        ..moveCursorLeft();
      expect(calc.resultFormat, ResultFormat.fraction);
    });

    test('a saved result remembers its expression', () async {
      final calc = await provider();
      calc
        ..insertNumber('1')
        ..insertOperator('+')
        ..insertNumber('2');
      expect(calc.saveCurrentResult(), isTrue);
      expect(
        calc.savedEntries.single,
        const SavedEntry(value: '3', expression: '1+2'),
      );
    });

    test('pasting the expression into an empty display restores it', () async {
      final calc = await provider();
      calc
        ..insertNumber('1')
        ..insertOperator('+')
        ..insertNumber('2')
        ..saveCurrentResult()
        ..clearAll()
        ..useSavedExpression(0);
      expect(calc.expression, '1+2');
    });

    test('pasting it into another expression keeps its meaning', () async {
      final calc = await provider();
      calc
        ..insertNumber('1')
        ..insertOperator('+')
        ..insertNumber('2')
        ..saveCurrentResult()
        ..clearAll()
        ..insertNumber('3')
        ..insertOperator('×')
        ..useSavedExpression(0);
      expect(calc.expression, '3×(1+2)');
      expect(calc.output, '9');

      // The result half pastes the number, as before.
      calc
        ..clearAll()
        ..insertNumber('3')
        ..insertOperator('×')
        ..useSavedValue(0);
      expect(calc.expression, '3×3');
    });

    test('saved entries survive a restart, with their expressions', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.create();
      final repository = SavedValuesRepository(storage);
      final first = CalculatorProvider(
        engine: const CalculatorEngine(),
        savedValuesRepository: repository,
      );
      first
        ..insertTemplate(MathTemplate.fraction)
        ..insertNumber('1')
        ..insertSymbol(')')
        ..insertNumber('4')
        ..saveCurrentResult();

      final second = CalculatorProvider(
        engine: const CalculatorEngine(),
        savedValuesRepository: repository,
      );
      expect(
        second.savedEntries.single,
        const SavedEntry(value: '0.25', expression: 'frac(1,4)'),
      );
    });

    test('values saved by an earlier version are carried over', () async {
      SharedPreferences.setMockInitialValues({
        'flutter.calculator.saved_values': <String>['16.6722414061', '42'],
      });
      final storage = await StorageService.create();
      final calc = CalculatorProvider(
        engine: const CalculatorEngine(),
        savedValuesRepository: SavedValuesRepository(storage),
      );
      expect(calc.savedEntries, const [
        SavedEntry(value: '16.6722414061'),
        SavedEntry(value: '42'),
      ]);
      // With no expression to paste, that half falls back to the value.
      calc.useSavedExpression(1);
      expect(calc.expression, '42');
    });

    test('a removed entry can be put back where it was', () async {
      final calc = await provider();
      for (final digit in ['1', '2', '3']) {
        calc
          ..clearAll()
          ..insertNumber(digit)
          ..saveCurrentResult();
      }
      final removed = calc.deleteSavedValue(1);
      expect(removed, const SavedEntry(value: '2', expression: '2'));
      expect([for (final e in calc.savedEntries) e.value], ['1', '3']);

      calc.restoreSavedEntry(1, removed!);
      expect([for (final e in calc.savedEntries) e.value], ['1', '2', '3']);
    });

    test('a saved fraction is stored as its decimal', () async {
      final calc = await provider();
      calc
        ..insertNumber('3')
        ..insertOperator('÷')
        ..insertNumber('4')
        ..calculate()
        ..calculate();
      expect(calc.saveCurrentResult(), isTrue);
      expect(calc.savedEntries.last.value, '0.75');
      expect(calc.savedEntries.last.expression, '3÷4');
    });
  });
}
