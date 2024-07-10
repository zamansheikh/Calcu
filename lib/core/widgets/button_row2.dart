import 'package:calcu/core/widgets/button.dart';
import 'package:calcu/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Buttonrow2 extends StatelessWidget {
  const Buttonrow2({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, value, _) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              buttonName: "x²",
              buttonColor: Theme.of(context).colorScheme.tertiary,
              onPressed: () {
                value.squareButton();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Expanded(
            child: CustomButton(
              buttonName: "√(x)",
              buttonColor: Theme.of(context).colorScheme.tertiary,
              onPressed: () {
                value.rootOverButton();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Expanded(
            child: CustomButton(
              buttonName: "%",
              buttonColor: Theme.of(context).colorScheme.tertiary,
              onPressed: () {
                value.percentageButton();
              },
              onLongPressed: () {
                value.modButton();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Expanded(
            child: CustomButton(
              buttonName: "÷",
              buttonColor: Theme.of(context).colorScheme.onTertiary,
              onPressed: () {
                value.divisionButton();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      );
    });
  }
}
