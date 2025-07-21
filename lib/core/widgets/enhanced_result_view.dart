import 'package:calcu/presentation/providers/calculator_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class EnhancedResultView extends StatelessWidget {
  const EnhancedResultView({super.key});

  String _addCommasToNumbers(String input) {
    if (input.isEmpty || input == 'Error') return input;

    return input.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(\.|$))'),
      (Match match) => '${match.group(1)},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculatorProvider, _) {
        return InkWell(
          onLongPress: () {
            calculatorProvider.saveResult();
            calculatorProvider.scrollController.animateTo(
              calculatorProvider.scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
          child: Container(
            width: double.infinity,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.sp),
              border: Border.all(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Result text
                  Text(
                    calculatorProvider.output.isEmpty
                        ? '0'
                        : _addCommasToNumbers(calculatorProvider.output),
                    style: TextStyle(
                      fontSize: calculatorProvider.output.length > 10
                          ? 28.sp
                          : 35.sp,
                      color: calculatorProvider.output == 'Error'
                          ? Colors.red
                          : Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
