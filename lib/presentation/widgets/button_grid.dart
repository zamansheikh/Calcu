import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/math/expression_editor.dart';
import '../providers/calculator_provider.dart';
import 'calculator_button.dart';

/// Calculator keypad, laid out on a single four-column grid.
///
/// The lower five rows are the familiar pad — digits on the left, operators
/// down the right, a wide zero. The two slimmer rows above it hold the
/// functions. Every row uses the same four columns, so the keys line up from
/// top to bottom.
class ButtonGrid extends StatelessWidget {
  const ButtonGrid({super.key});

  Widget _row(List<Widget> children, {int flex = 10}) {
    return Expanded(
      flex: flex,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calc = context.read<CalculatorProvider>();

    Widget digit(String value, {int flex = 1}) => CalculatorButton(
          label: value,
          flex: flex,
          onTap: () => calc.insertNumber(value),
        );

    Widget operator(String label, String value) => CalculatorButton(
          label: label,
          style: CalculatorButtonStyle.operator,
          onTap: () => calc.insertOperator(value),
        );

    // A function key. Its face is the notation it inserts, typeset the way
    // the display will draw it, with letters standing in for the operands.
    Widget function({
      String? math,
      String? label,
      String? name,
      required VoidCallback onTap,
      String? hint,
      VoidCallback? onLongPress,
    }) =>
        CalculatorButton(
          math: math,
          label: label,
          semanticLabel: name,
          hint: hint,
          dense: true,
          style: CalculatorButtonStyle.special,
          onTap: onTap,
          onLongPress: onLongPress,
        );

    return Column(
      children: [
        // a/b  xʸ  √x  |x|
        _row(flex: 8, [
          function(
            math: 'frac(a,b)',
            name: 'Fraction',
            onTap: () => calc.insertTemplate(MathTemplate.fraction),
          ),
          function(
            math: 'x^y',
            name: 'Power',
            onTap: () => calc.insertSymbol('^'),
          ),
          function(
            math: '√(x)',
            name: 'Square root',
            onTap: () => calc.insertTemplate(MathTemplate.squareRoot),
          ),
          function(
            math: 'abs(x)',
            name: 'Absolute value',
            onTap: () => calc.insertTemplate(MathTemplate.absolute),
          ),
        ]),
        // logₐ(x)  π  (  )
        _row(flex: 8, [
          function(
            math: 'log(a,x)',
            name: 'Logarithm',
            hint: 'ln',
            onTap: () => calc.insertTemplate(MathTemplate.logarithm),
            onLongPress: () => calc.insertTemplate(MathTemplate.naturalLog),
          ),
          function(
            label: 'π',
            hint: 'e',
            onTap: () => calc.insertSymbol('π'),
            onLongPress: () => calc.insertSymbol('e'),
          ),
          function(label: '(', onTap: () => calc.insertSymbol('(')),
          function(label: ')', onTap: () => calc.insertSymbol(')')),
        ]),
        // AC  ⌫  %  ÷
        _row([
          CalculatorButton(
            label: 'AC',
            semanticLabel: 'Clear all',
            style: CalculatorButtonStyle.clear,
            onTap: calc.clearAll,
          ),
          CalculatorButton(
            icon: Icons.backspace_outlined,
            semanticLabel: 'Delete',
            style: CalculatorButtonStyle.special,
            repeat: true,
            onTap: calc.backspace,
          ),
          CalculatorButton(
            label: '%',
            hint: 'mod',
            style: CalculatorButtonStyle.special,
            onTap: () => calc.insertSymbol('%'),
            onLongPress: () => calc.insertTemplate(MathTemplate.modulo),
          ),
          operator('÷', '÷'),
        ]),
        _row([digit('7'), digit('8'), digit('9'), operator('×', '×')]),
        _row([digit('4'), digit('5'), digit('6'), operator('−', '-')]),
        _row([digit('1'), digit('2'), digit('3'), operator('+', '+')]),
        // 0 (wide)  .  =
        _row([
          digit('0', flex: 2),
          CalculatorButton(label: '.', onTap: () => calc.insertSymbol('.')),
          // Once a result is showing, the corner names the form the next
          // press switches it to: fraction, precise, decimal.
          Selector<CalculatorProvider, ResultFormat?>(
            selector: (context, calc) => calc.nextResultFormat,
            builder: (context, next, _) => CalculatorButton(
              label: '=',
              hint: next?.name,
              style: CalculatorButtonStyle.equals,
              onTap: calc.calculate,
              onLongPress: calc.calculatePrecise,
            ),
          ),
        ]),
      ],
    );
  }
}
