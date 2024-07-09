import 'package:calcu/core/widgets/button.dart';
import 'package:calcu/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Buttonrow4 extends StatelessWidget {
  const Buttonrow4({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, value, _) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              buttonName: "4",
              buttonColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                value.fourButton();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Expanded(
            child: CustomButton(
              buttonName: "5",
              buttonColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                value.fiveButton();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Expanded(
            child: CustomButton(
              buttonName: "6",
              buttonColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                value.sixButton();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Expanded(
            child: CustomButton(
              buttonName: "-",
              buttonColor: Theme.of(context).colorScheme.onTertiary,
              onPressed: () {
                value.minusButton();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      );
    });
  }
}
