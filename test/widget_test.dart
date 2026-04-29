import 'package:calcu/core/services/calculator_engine.dart';
import 'package:calcu/core/utils/number_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = CalculatorEngine();

  group('CalculatorEngine.evaluate', () {
    test('basic arithmetic', () {
      expect(engine.evaluate('2+3').display, '5');
      expect(engine.evaluate('12×11').display, '132');
      expect(engine.evaluate('100÷4').display, '25');
      expect(engine.evaluate('10-7').display, '3');
    });

    test('parentheses and precedence', () {
      expect(engine.evaluate('(2+3)×4').display, '20');
      expect(engine.evaluate('2+3×4').display, '14');
    });

    test('decimal results', () {
      expect(engine.evaluate('1÷4').display, '0.25');
      expect(engine.evaluate('10÷3', decimals: 3).display, '3.333');
    });

    test('power via ^', () {
      expect(engine.evaluate('2^10').display, '1024');
      expect(engine.evaluate('3^3').display, '27');
    });

    test('square root', () {
      expect(engine.evaluate('√(16)').display, '4');
      expect(engine.evaluate('√(2)', decimals: 3).display, '1.414');
    });

    test('percentage standalone and percentage-of', () {
      expect(engine.evaluate('50%').display, '0.5');
      expect(engine.evaluate('200×20%').display, '40');
      expect(engine.evaluate('20%200').display, '40');
    });

    test('modulo via long-press shortcut Xmod(Y)', () {
      expect(engine.evaluate('8mod(3)').display, '2');
      expect(engine.evaluate('17mod(5)').display, '2');
    });

    test('division by zero is an error', () {
      expect(engine.evaluate('5÷0').isError, isTrue);
    });

    test('incomplete input returns empty preview', () {
      expect(engine.evaluate('2+').display, '');
      expect(engine.evaluate('(2+3').display, '');
      expect(engine.evaluate('').display, '');
    });
  });

  group('NumberFormatter', () {
    test('thousands separators', () {
      expect(NumberFormatter.addThousandsSeparators('1234567'), '1,234,567');
      expect(NumberFormatter.addThousandsSeparators('1234.5678'), '1,234.5678');
    });

    test('formatResult trims trailing zeros', () {
      expect(NumberFormatter.formatResult(5.0), '5');
      expect(NumberFormatter.formatResult(5.5000), '5.5');
      expect(NumberFormatter.formatResult(3.14), '3.14');
    });

    test('formatPrecise pads to N decimals', () {
      expect(NumberFormatter.formatPrecise(3.14159, 3), '3.142');
      expect(NumberFormatter.formatPrecise(1, 3), '1.000');
    });
  });
}
