import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/calculator_provider.dart';
import 'calculator_button.dart';

/// 6×4 calculator keypad. Each row stretches to fill its share of the
/// available vertical space; each button stretches across its row.
class ButtonGrid extends StatelessWidget {
  const ButtonGrid({super.key});

  Widget _row(List<Widget> children) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calc = context.read<CalculatorProvider>();
    return Column(
      children: [
        // Row 1: AC ( ) ⌫
        _row([
          CalculatorButton(
            label: 'AC',
            style: CalculatorButtonStyle.clear,
            onTap: calc.clearAll,
          ),
          CalculatorButton(
            label: '(',
            style: CalculatorButtonStyle.special,
            onTap: () => calc.insertSymbol('('),
          ),
          CalculatorButton(
            label: ')',
            style: CalculatorButtonStyle.special,
            onTap: () => calc.insertSymbol(')'),
          ),
          CalculatorButton(
            icon: Icons.backspace_outlined,
            style: CalculatorButtonStyle.special,
            onTap: calc.backspace,
          ),
        ]),
        // Row 2: x^  √  %  ÷
        _row([
          CalculatorButton(
            label: 'xʸ',
            style: CalculatorButtonStyle.special,
            onTap: () => calc.insertSymbol('^'),
          ),
          CalculatorButton(
            label: '√',
            style: CalculatorButtonStyle.special,
            onTap: () => calc.insertSymbol('√('),
          ),
          CalculatorButton(
            label: '%',
            subLabel: 'mod',
            style: CalculatorButtonStyle.special,
            onTap: () => calc.insertSymbol('%'),
            onLongPress: () => calc.insertSymbol('mod('),
          ),
          CalculatorButton(
            label: '÷',
            style: CalculatorButtonStyle.operator,
            onTap: () => calc.insertOperator('÷'),
          ),
        ]),
        // Row 3: 7 8 9 ×
        _row([
          CalculatorButton(label: '7', onTap: () => calc.insertNumber('7')),
          CalculatorButton(label: '8', onTap: () => calc.insertNumber('8')),
          CalculatorButton(label: '9', onTap: () => calc.insertNumber('9')),
          CalculatorButton(
            label: '×',
            style: CalculatorButtonStyle.operator,
            onTap: () => calc.insertOperator('×'),
          ),
        ]),
        // Row 4: 4 5 6 -
        _row([
          CalculatorButton(label: '4', onTap: () => calc.insertNumber('4')),
          CalculatorButton(label: '5', onTap: () => calc.insertNumber('5')),
          CalculatorButton(label: '6', onTap: () => calc.insertNumber('6')),
          CalculatorButton(
            label: '−',
            style: CalculatorButtonStyle.operator,
            onTap: () => calc.insertOperator('-'),
          ),
        ]),
        // Row 5: 1 2 3 +
        _row([
          CalculatorButton(label: '1', onTap: () => calc.insertNumber('1')),
          CalculatorButton(label: '2', onTap: () => calc.insertNumber('2')),
          CalculatorButton(label: '3', onTap: () => calc.insertNumber('3')),
          CalculatorButton(
            label: '+',
            style: CalculatorButtonStyle.operator,
            onTap: () => calc.insertOperator('+'),
          ),
        ]),
        // Row 6: 0(wide) . =
        _row([
          CalculatorButton(
            label: '0',
            flex: 2,
            onTap: () => calc.insertNumber('0'),
          ),
          CalculatorButton(label: '.', onTap: () => calc.insertSymbol('.')),
          CalculatorButton(
            label: '=',
            subLabel: 'precise',
            style: CalculatorButtonStyle.equals,
            onTap: calc.calculate,
            onLongPress: calc.calculatePrecise,
          ),
        ]),
      ],
    );
  }
}
