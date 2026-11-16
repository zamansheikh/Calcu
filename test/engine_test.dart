import 'package:calcu/core/math/exact_form.dart';
import 'package:calcu/core/math/expression_editor.dart';
import 'package:calcu/core/services/calculator_engine.dart';
import 'package:calcu/core/services/storage_service.dart';
import 'package:calcu/core/utils/number_formatter.dart';
import 'package:calcu/data/repositories/saved_values_repository.dart';
import 'package:calcu/presentation/providers/calculator_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const engine = CalculatorEngine();
  String result(String source) => engine.evaluate(source).display;

  group('large and small numbers', () {
    test('a result past the range of a double is still a number', () {
      expect(result('2^1024'), '1.79769313486×10^308');
      expect(result('10^309'), '1×10^309');
      expect(result('999^99999'), startsWith('3.542'));
      expect(result('999^99999'), endsWith('×10^299953'));
      expect(result('9^9^9'), endsWith('×10^369693099'));
    });

    test('and so is one too small for a double', () {
      expect(result('2^-2000'), '8.70980981622×10^-603');
      expect(result('1÷10^400'), '1×10^-400');
    });

    test('arithmetic carries on out there', () {
      expect(result('10^400÷10^399'), '10');
      expect(result('10^400×10^-400'), '1');
      expect(result('10^400-10^400'), '0');
      expect(result('√(10^400)'), '1×10^200');
      expect(result('log(10,10^400)'), '400');
      expect(result('-(10^400)'), '-1×10^400');
    });

    test('whole numbers keep every digit', () {
      expect(result('999999999999×999'), '998999999999001');
      expect(result('123456789012345×1'), '123456789012345');
      expect(result('999999999999999'), '999999999999999');
    });

    test('past fifteen digits the result is written in scientific form', () {
      expect(result('10^15'), '1×10^15');
      expect(
        result('99999999999999999999×99999999999999999999'),
        '1×10^40',
      );
      expect(result('1÷3^30'), '4.85693574962×10^-15');
    });

    test('only what cannot be represented at all is an error', () {
      expect(result('9^9^9^9'), 'Too large');
    });

    test('a scientific result is expression source and evaluates back', () {
      final huge = result('2^1024');
      expect(result('($huge)÷2^1023'), '2');
    });

    test('precise mode rounds the mantissa', () {
      expect(engine.evaluate('999^99999', decimals: 3).display,
          '3.542×10^299953');
      expect(engine.evaluate('1÷3', decimals: 3).display, '0.333');
    });
  });

  group('formatting', () {
    test('twelve significant digits, trailing zeros dropped', () {
      expect(result('1÷3'), '0.333333333333');
      expect(result('2÷3'), '0.666666666667');
      expect(result('0.1+0.2'), '0.3');
      expect(result('log(10,1000)'), '3');
      expect(result('123456789012.5'), '123456789012.5');
    });

    test('small values', () {
      expect(result('0.000001'), '0.000001');
      expect(result('0.0000001'), '1×10^-7');
    });

    test('the exponent keeps its zeros', () {
      // Trimming trailing zeros once reached into the exponent: 10^40 → 10^4.
      expect(NumberFormatter.formatResult(1e40), '1×10^40');
      expect(NumberFormatter.formatResult(1e100), '1×10^100');
      expect(NumberFormatter.formatResult(-2.5e-20), '-2.5×10^-20');
    });
  });

  group('percent applies to any operand', () {
    test('after a bracket, a root, a fraction, a power', () {
      expect(result('(1+2)%'), '0.03');
      expect(result('√(9)%'), '0.03');
      expect(result('frac(1,2)%'), '0.005');
      expect(result('2^2%'), '0.04');
      expect(result('50%%'), '0.005');
    });

    test('and still means what it did after a number', () {
      expect(result('50%'), '0.5');
      expect(result('200×20%'), '40');
      expect(result('20%200'), '40');
      expect(result('50%+10%'), '0.6');
    });
  });

  group('mod applies to whole operands', () {
    test('a power or a fraction before it', () {
      expect(result('2^3mod(3)'), '2');
      expect(result('frac(7,2)mod(2)'), '1.5');
      expect(result('8mod(frac(6,2))'), '2');
    });

    test('and binds like multiplication', () {
      expect(result('10mod(3)+1'), '2');
      expect(result('8mod(3)'), '2');
      expect(result('-7mod(3)'), '-1');
    });
  });

  group('powers of negative numbers', () {
    test('odd roots are real', () {
      expect(result('(-8)^frac(1,3)'), '-2');
      expect(result('(-8)^frac(2,3)'), '4');
      expect(result('(-2)^3'), '-8');
      expect(result('-2^2'), '-4');
    });

    test('even roots are not', () {
      expect(result('(-8)^frac(1,2)'), 'Not a real number');
    });
  });

  group('errors say why', () {
    test('division by zero', () {
      expect(result('5÷0'), "Can't divide by 0");
      expect(result('0÷0'), "Can't divide by 0");
      expect(result('8mod(0)'), "Can't divide by 0");
    });

    test('outside the real numbers', () {
      expect(result('√(-4)'), 'Not a real number');
      expect(result('ln(0)'), 'Not a real number');
      expect(result('log(1,5)'), 'Not a real number');
    });

    test('they are all still errors', () {
      for (final source in ['5÷0', '√(-4)', '9^9^9^9', '5××3']) {
        expect(engine.evaluate(source).isError, isTrue, reason: source);
      }
    });
  });

  group('no closed form is invented for a tiny number', () {
    test('1e-7 is not √0', () {
      expect(ExactForm.of(1e-7), isNull);
      expect(ExactForm.of(3.3e-12), isNull);
      expect(ExactForm.of(0.001), 'frac(1,1000)');
    });
  });

  group('typing operators', () {
    String typed(String keys) {
      var state = const EditState('', 0);
      for (final key in keys.split('')) {
        state = ExpressionEditor.insert(state.text, state.cursor, key);
      }
      return state.text;
    }

    test('a second operator replaces the first', () {
      expect(typed('5+×3'), '5×3');
      expect(typed('5××3'), '5×3');
      expect(typed('5×÷+3'), '5+3');
      expect(typed('5--3'), '5-3');
    });

    test('a minus after × or ÷ starts a negative number', () {
      expect(typed('5×-3'), '5×-3');
      expect(typed('5÷-3'), '5÷-3');
      // …and a further operator replaces both.
      expect(typed('5×-+3'), '5+3');
    });

    test('an expression cannot open with × ÷ or +', () {
      expect(typed('×5'), '5');
      expect(typed('+5'), '5');
      expect(typed('-5'), '-5');
      expect(typed('-×5'), '5');
      expect(typed('(×5'), '(5');
      expect(typed('(-5'), '(-5');
    });

    test('a sign is allowed in an exponent', () {
      expect(typed('10^-2'), '10^-2');
    });
  });

  group('typing the decimal point', () {
    String typed(String keys) {
      var state = const EditState('', 0);
      for (final key in keys.split('')) {
        state = ExpressionEditor.insert(state.text, state.cursor, key);
      }
      return state.text;
    }

    test('one per number', () {
      expect(typed('1.2.3'), '1.23');
      expect(typed('1..5'), '1.5');
      expect(typed('1.5+2.5'), '1.5+2.5');
    });

    test('a leading point gets its zero', () {
      expect(typed('.5'), '0.5');
      expect(typed('2+.5'), '2+0.5');
    });
  });

  group('closing brackets', () {
    test('supplies the ones left open', () {
      expect(ExpressionEditor.closeBrackets('(2+3'), '(2+3)');
      expect(ExpressionEditor.closeBrackets('2×(3+(4'), '2×(3+(4))');
      expect(ExpressionEditor.closeBrackets('2^(3+1'), '2^(3+1)');
      expect(ExpressionEditor.closeBrackets('(2+3)'), '(2+3)');
      expect(ExpressionEditor.closeBrackets('2+3'), '2+3');
    });
  });

  group('provider', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    Future<CalculatorProvider> provider() async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.create();
      return CalculatorProvider(
        engine: const CalculatorEngine(),
        savedValuesRepository: SavedValuesRepository(storage),
      );
    }

    test('= closes brackets left open', () async {
      final calc = await provider();
      calc
        ..insertSymbol('(')
        ..insertNumber('2')
        ..insertOperator('+')
        ..insertNumber('3');
      expect(calc.output, '', reason: 'no preview while a bracket is open');
      calc.calculate();
      expect(calc.expression, '(2+3)');
      expect(calc.output, '5');
    });

    test('= leaves a truly unfinished expression alone', () async {
      final calc = await provider();
      calc
        ..insertSymbol('(')
        ..insertNumber('2')
        ..insertOperator('+')
        ..calculate();
      expect(calc.expression, '(2+');
    });

    test('a huge result can be saved and pasted back', () async {
      final calc = await provider();
      calc
        ..insertNumber('2')
        ..insertSymbol('^')
        ..insertNumber('1024')
        ..saveCurrentResult()
        ..clearAll()
        ..insertNumber('4')
        ..insertOperator('÷')
        ..useSavedValue(0);
      // Bracketed, so the division takes the whole of it.
      expect(calc.expression, '4÷(1.79769313486×10^308)');
      expect(calc.hasError, isFalse);
    });

    test('a plain saved number is pasted without brackets', () async {
      final calc = await provider();
      calc
        ..insertNumber('42')
        ..saveCurrentResult()
        ..clearAll()
        ..insertNumber('2')
        ..insertOperator('×')
        ..useSavedValue(0);
      expect(calc.expression, '2×42');
    });

    test('precise form of a huge result', () async {
      final calc = await provider();
      calc
        ..insertNumber('999')
        ..insertSymbol('^')
        ..insertNumber('99999')
        ..calculatePrecise();
      expect(calc.output, '3.542×10^299953');
    });
  });
}
