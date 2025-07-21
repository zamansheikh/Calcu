import 'package:calcu/core/widgets/enhanced_calculator_button.dart';
import 'package:calcu/presentation/providers/calculator_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class EnhancedButtonRow1 extends StatelessWidget {
  const EnhancedButtonRow1({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, _) {
        return Row(
          children: [
            EnhancedCalculatorButton(
              text: "AC",
              type: CalculatorButtonType.clear,
              onPressed: () => calculator.clearAll(),
            ),
            EnhancedCalculatorButton(
              text: "(",
              type: CalculatorButtonType.special,
              onPressed: () => calculator.insertOpenParenthesis(),
            ),
            EnhancedCalculatorButton(
              text: ")",
              type: CalculatorButtonType.special,
              onPressed: () => calculator.insertCloseParenthesis(),
            ),
            EnhancedCalculatorButton(
              text: "",
              type: CalculatorButtonType.special,
              onPressed: () => calculator.deleteCharacter(),
              icon: Icon(
                Icons.backspace_outlined,
                size: 24.sp,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class EnhancedButtonRow2 extends StatelessWidget {
  const EnhancedButtonRow2({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, _) {
        return Row(
          children: [
            EnhancedCalculatorButton(
              text: "x²",
              type: CalculatorButtonType.special,
              onPressed: () => calculator.insertPower(),
            ),
            EnhancedCalculatorButton(
              text: "√",
              type: CalculatorButtonType.special,
              onPressed: () => calculator.insertSqrt(),
            ),
            EnhancedCalculatorButton(
              text: "%",
              type: CalculatorButtonType.special,
              onPressed: () => calculator.insertPercent(),
              onLongPressed: () =>
                  calculator.insertInput('mod('), // modulus function
            ),
            EnhancedCalculatorButton(
              text: "÷",
              type: CalculatorButtonType.operator,
              onPressed: () => calculator.insertDivide(),
            ),
          ],
        );
      },
    );
  }
}

class EnhancedButtonRow3 extends StatelessWidget {
  const EnhancedButtonRow3({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, _) {
        return Row(
          children: [
            EnhancedCalculatorButton(
              text: "7",
              onPressed: () => calculator.insertNumber('7'),
            ),
            EnhancedCalculatorButton(
              text: "8",
              onPressed: () => calculator.insertNumber('8'),
            ),
            EnhancedCalculatorButton(
              text: "9",
              onPressed: () => calculator.insertNumber('9'),
            ),
            EnhancedCalculatorButton(
              text: "×",
              type: CalculatorButtonType.operator,
              onPressed: () => calculator.insertMultiply(),
            ),
          ],
        );
      },
    );
  }
}

class EnhancedButtonRow4 extends StatelessWidget {
  const EnhancedButtonRow4({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, _) {
        return Row(
          children: [
            EnhancedCalculatorButton(
              text: "4",
              onPressed: () => calculator.insertNumber('4'),
            ),
            EnhancedCalculatorButton(
              text: "5",
              onPressed: () => calculator.insertNumber('5'),
            ),
            EnhancedCalculatorButton(
              text: "6",
              onPressed: () => calculator.insertNumber('6'),
            ),
            EnhancedCalculatorButton(
              text: "-",
              type: CalculatorButtonType.operator,
              onPressed: () => calculator.insertSubtract(),
            ),
          ],
        );
      },
    );
  }
}

class EnhancedButtonRow5 extends StatelessWidget {
  const EnhancedButtonRow5({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, _) {
        return Row(
          children: [
            EnhancedCalculatorButton(
              text: "1",
              onPressed: () => calculator.insertNumber('1'),
            ),
            EnhancedCalculatorButton(
              text: "2",
              onPressed: () => calculator.insertNumber('2'),
            ),
            EnhancedCalculatorButton(
              text: "3",
              onPressed: () => calculator.insertNumber('3'),
            ),
            EnhancedCalculatorButton(
              text: "+",
              type: CalculatorButtonType.operator,
              onPressed: () => calculator.insertAdd(),
            ),
          ],
        );
      },
    );
  }
}

class EnhancedButtonRow6 extends StatelessWidget {
  const EnhancedButtonRow6({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, _) {
        return Row(
          children: [
            EnhancedCalculatorButton(
              text: "0",
              isExpanded: true,
              onPressed: () => calculator.insertNumber('0'),
            ),
            EnhancedCalculatorButton(
              text: ".",
              onPressed: () => calculator.insertDecimal(),
            ),
            EnhancedCalculatorButton(
              text: "=",
              type: CalculatorButtonType.equals,
              onPressed: () => calculator.calculate(),
              onLongPressed: () => calculator.calculatePrecise(),
            ),
          ],
        );
      },
    );
  }
}
