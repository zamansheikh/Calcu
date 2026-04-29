import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/calculator_provider.dart';
import 'calculator_button.dart';

/// 5×4 calculator keypad. Stateless and pulls actions from the provider.
class ButtonGrid extends StatelessWidget {
  const ButtonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.read<CalculatorProvider>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: AC ( ) ⌫
        Row(
          children: [
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
          ],
        ),
        // Row 2: x^  √  %  ÷
        Row(
          children: [
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
          ],
        ),
        // Row 3: 7 8 9 ×
        Row(
          children: [
            CalculatorButton(label: '7', onTap: () => calc.insertNumber('7')),
            CalculatorButton(label: '8', onTap: () => calc.insertNumber('8')),
            CalculatorButton(label: '9', onTap: () => calc.insertNumber('9')),
            CalculatorButton(
              label: '×',
              style: CalculatorButtonStyle.operator,
              onTap: () => calc.insertOperator('×'),
            ),
          ],
        ),
        // Row 4: 4 5 6 -
        Row(
          children: [
            CalculatorButton(label: '4', onTap: () => calc.insertNumber('4')),
            CalculatorButton(label: '5', onTap: () => calc.insertNumber('5')),
            CalculatorButton(label: '6', onTap: () => calc.insertNumber('6')),
            CalculatorButton(
              label: '−',
              style: CalculatorButtonStyle.operator,
              onTap: () => calc.insertOperator('-'),
            ),
          ],
        ),
        // Row 5: 1 2 3 +
        Row(
          children: [
            CalculatorButton(label: '1', onTap: () => calc.insertNumber('1')),
            CalculatorButton(label: '2', onTap: () => calc.insertNumber('2')),
            CalculatorButton(label: '3', onTap: () => calc.insertNumber('3')),
            CalculatorButton(
              label: '+',
              style: CalculatorButtonStyle.operator,
              onTap: () => calc.insertOperator('+'),
            ),
          ],
        ),
        // Row 6: 0(wide) . =
        Row(
          children: [
            CalculatorButton(
              label: '0',
              flex: 2,
              onTap: () => calc.insertNumber('0'),
            ),
            CalculatorButton(label: '.', onTap: () => calc.insertSymbol('.')),
            CalculatorButton(
              label: '=',
              subLabel: '··· precise',
              style: CalculatorButtonStyle.equals,
              onTap: calc.calculate,
              onLongPress: calc.calculatePrecise,
            ),
          ],
        ),
        SizedBox(height: 4.r),
      ],
    );
  }
}
