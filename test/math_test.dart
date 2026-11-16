import 'dart:math' show Random;

import 'package:calcu/core/math/expression_editor.dart';
import 'package:calcu/core/math/math_document.dart';
import 'package:calcu/core/math/math_node.dart';
import 'package:calcu/core/services/calculator_engine.dart';
import 'package:calcu/presentation/widgets/math/math_layout.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Types [keys] one editor operation at a time, the way the keypad does.
/// `<` and `>` are the cursor keys, `⌫` is backspace, and a template name in
/// braces (`{fraction}`) inserts that template.
EditState type(String keys, [EditState from = const EditState('', 0)]) {
  var state = from;
  final pattern = RegExp(r'\{(\w+)\}|.');
  for (final match in pattern.allMatches(keys)) {
    final template = match.group(1);
    final key = match.group(0)!;
    if (template != null) {
      state = ExpressionEditor.insertTemplate(
        state.text,
        state.cursor,
        MathTemplate.values.byName(template),
      );
    } else if (key == '<') {
      state = ExpressionEditor.moveLeft(state.text, state.cursor);
    } else if (key == '>') {
      state = ExpressionEditor.moveRight(state.text, state.cursor);
    } else if (key == '⌫') {
      state = ExpressionEditor.backspace(state.text, state.cursor);
    } else {
      state = ExpressionEditor.insert(state.text, state.cursor, key);
    }
  }
  return state;
}

void main() {
  const engine = CalculatorEngine();

  group('parser', () {
    test('an ungrouped exponent is the single operand after ^', () {
      final root = MathDocument.parse('2^5+3').root;
      expect(root.children, hasLength(4));
      final power = root.children[1] as PowerNode;
      expect(power.grouped, isFalse);
      expect((power.exponent.children.single as NumberNode).text, '5');
    });

    test('a sign belongs to the exponent', () {
      final power = MathDocument.parse('10^-2').root.children[1] as PowerNode;
      expect(power.exponent.children, hasLength(2));
    });

    test('towers nest to the right', () {
      final outer = MathDocument.parse('2^3^2').root.children[1] as PowerNode;
      expect(outer.exponent.children.last, isA<PowerNode>());
    });

    test('structures', () {
      final root = MathDocument.parse('frac(1,2)+√(9)+abs(-5)+log(2,8)').root;
      expect(root.children[0], isA<FractionNode>());
      expect(root.children[2], isA<RadicalNode>());
      expect(root.children[4], isA<AbsNode>());
      expect(root.children[6], isA<LogNode>());
    });

    test('half-typed input still parses', () {
      for (final source in ['2^', '(3+', 'frac(1,', '√(', 'log(', ')', '2^(']) {
        expect(() => MathDocument.parse(source), returnsNormally);
      }
    });
  });

  group('caret stops', () {
    test('skip characters that are not drawn', () {
      // 2^(5): no stop between the ^ and its bracket.
      expect(MathDocument.parse('2^(5)').stops, [0, 1, 3, 4, 5]);
      // frac(1,2): no stop inside the name.
      expect(MathDocument.parse('frac(1,2)').stops, [0, 5, 6, 7, 8, 9]);
    });

    test('the end of an ungrouped exponent is inside it', () {
      final doc = MathDocument.parse('2^5');
      expect(doc.containerOf(doc.ownerOf(3)!), isA<PowerNode>());
    });
  });

  group('editing', () {
    test('typing a power then an operator returns to the main line', () {
      expect(type('2^5+3').text, '2^5+3');
    });

    test('templates are inserted closed with the caret inside', () {
      expect(type('{squareRoot}16'), const EditState('√(16)', 4));
      expect(type('{absolute}5'), const EditState('abs(5)', 5));
    });

    test(') leaves a structure instead of adding a bracket', () {
      expect(type('{squareRoot}16)+2').text, '√(16)+2');
      expect(type('2^(1+2)×3').text, '2^(1+2)×3');
    });

    test(') steps between the slots of a fraction', () {
      expect(type('{fraction}1)2)+3').text, 'frac(1,2)+3');
    });

    test('the fraction key takes the number before it as numerator', () {
      expect(type('3{fraction}4'), const EditState('frac(3,4)', 8));
      expect(type('1+2^(3){fraction}4').text, '1+frac(2^(3),4)');
    });

    test('right arrow at the end leaves an exponent', () {
      expect(type('2^5>+1').text, '2^(5)+1');
    });

    test('arrows walk through every slot', () {
      final state = type('{fraction}1)2');
      final seen = <int>[state.cursor];
      var current = state;
      for (var i = 0; i < 6; i++) {
        current = ExpressionEditor.moveLeft(current.text, current.cursor);
        seen.add(current.cursor);
      }
      expect(seen, [8, 7, 6, 5, 0, 0, 0]);
    });

    test('backspace removes what is visible, one step at a time', () {
      // After √(16): step inside, delete 6, delete 1, delete the empty root.
      expect(type('{squareRoot}16)⌫'), const EditState('√(16)', 4));
      expect(type('{squareRoot}16)⌫⌫⌫').text, '√()');
      expect(type('{squareRoot}16)⌫⌫⌫⌫').text, '');
    });

    test('backspace at the start of a structure keeps its contents', () {
      expect(type('{squareRoot}16<<⌫').text, '16');
      expect(type('{fraction}1)2<<<⌫').text, '1÷2');
    });

    test('an empty fraction is deleted whole', () {
      expect(type('5+{fraction}⌫').text, '5+');
    });

    test('visible brackets delete like characters', () {
      expect(type('(2+3)⌫').text, '(2+3');
      expect(type('(⌫').text, '');
    });

    test('the caret never lands on a hidden character', () {
      for (final keys in [
        '2^(5)<<<<',
        '{logarithm}2)8)<<<<<<',
        '{fraction}12)34)⌫⌫⌫⌫⌫⌫⌫',
        '2{modulo}3)⌫⌫',
      ]) {
        final state = type(keys);
        expect(
          MathDocument.parse(state.text).stops,
          contains(state.cursor),
          reason: '$keys → "${state.text}" @ ${state.cursor}',
        );
      }
    });
  });

  group('evaluation', () {
    test('powers', () {
      expect(engine.evaluate('2^5').display, '32');
      expect(engine.evaluate('10^-2').display, '0.01');
      expect(engine.evaluate('2^(1+2)').display, '8');
      expect(engine.evaluate('2^3^2').display, '512');
      // A second power raises everything drawn to its left.
      expect(engine.evaluate('2^(3)^(2)').display, '64');
    });

    test('fractions', () {
      expect(engine.evaluate('frac(1,2)').display, '0.5');
      expect(engine.evaluate('frac(1,2)+frac(1,4)').display, '0.75');
      expect(engine.evaluate('frac(2+4,3)').display, '2');
    });

    test('roots, absolute value, logarithms', () {
      expect(engine.evaluate('√(16+9)').display, '5');
      expect(engine.evaluate('abs(3-10)').display, '7');
      expect(engine.evaluate('log(2,8)').display, '3');
      expect(engine.evaluate('log(10,100)').display, '2');
      expect(engine.evaluate('log(10,1000)').display, '3');
      expect(engine.evaluate('ln(e)').display, '1');
    });

    test('implicit multiplication', () {
      expect(engine.evaluate('2√(9)').display, '6');
      expect(engine.evaluate('3(4)').display, '12');
      expect(engine.evaluate('(2)(3)').display, '6');
      expect(engine.evaluate('2frac(1,2)').display, '1');
      expect(engine.evaluate('2π', decimals: 3).display, '6.283');
    });

    test('floating-point residue is rounded away', () {
      expect(engine.evaluate('0.1+0.2').display, '0.3');
    });

    test('an unfinished structure has no preview', () {
      expect(engine.evaluate('frac(1,)').display, '');
      expect(engine.evaluate('2^').display, '');
      expect(engine.evaluate('√()').display, '');
      expect(engine.evaluate('log(,8)').display, '');
    });
  });

  group('layout', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    MathLayout layout(String source) => MathLayout(
          MathDocument.parse(source),
          const MathStyle(
            fontSize: 40,
            color: Color(0xFF000000),
            placeholderColor: Color(0x55000000),
          ),
        );

    test('every caret stop has a position, and taps resolve back to it', () {
      for (final source in [
        '1234567+89',
        '2^5+3',
        '2^(1+2)^3',
        'frac(1+2,3^4)',
        '√(frac(1,2))',
        'abs(-5)+log(2,8)',
        '(frac(1,2))^2',
        '2^',
        'frac(,)',
      ]) {
        final math = layout(source);
        for (final stop in math.document.stops) {
          final caret = math.caretAt(stop);
          expect(caret.height, greaterThan(0), reason: '$source @ $stop');
          final hit = math.stopAt(
            Offset(caret.x, (caret.top + caret.bottom) / 2),
          );
          final found = math.caretAt(hit);
          expect(found.x, closeTo(caret.x, 0.01), reason: '$source @ $stop');
          expect(found.top, closeTo(caret.top, 0.01),
              reason: '$source @ $stop');
        }
        math.dispose();
      }
    });

    test('an exponent is raised and smaller', () {
      final math = layout('2^5');
      final base = math.caretAt(1);
      final exponent = math.caretAt(3);
      expect(exponent.height, lessThan(base.height));
      expect(exponent.top, lessThan(base.top));
      math.dispose();
    });

    test('random key sequences never break the editor, layout or engine', () {
      const keys = [
        ...['0', '1', '2', '7', '9', '.', '+', '-', '×', '÷', '%', '^'],
        ...['(', ')', 'π', 'e', '<', '>', '⌫', '⌫'],
        ...['{fraction}', '{squareRoot}', '{absolute}', '{logarithm}'],
        ...['{naturalLog}', '{modulo}'],
      ];
      final random = Random(20261116);
      for (var run = 0; run < 300; run++) {
        var state = const EditState('', 0);
        final typed = StringBuffer();
        for (var step = 0; step < 40; step++) {
          final key = keys[random.nextInt(keys.length)];
          typed.write(key);
          state = type(key, state);

          final document = MathDocument.parse(state.text);
          expect(document.stops, contains(state.cursor),
              reason: '$typed → "${state.text}" @ ${state.cursor}');
          expect(() => engine.evaluate(state.text), returnsNormally,
              reason: '$typed → "${state.text}"');
          final math = layout(state.text);
          for (final stop in document.stops) {
            final caret = math.caretAt(stop);
            expect(caret.x.isFinite && caret.height > 0, isTrue,
                reason: '$typed → "${state.text}" @ $stop');
          }
          expect(math.size.isFinite, isTrue);
          math.dispose();
        }
      }
    });

    test('a fraction stacks its parts and is taller than a line', () {
      final plain = layout('12');
      final fraction = layout('frac(1,2)');
      expect(fraction.size.height, greaterThan(plain.size.height));
      expect(fraction.caretAt(6).bottom, lessThan(fraction.caretAt(7).top));
      plain.dispose();
      fraction.dispose();
    });
  });
}
