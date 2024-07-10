import 'package:calcu/core/widgets/button.dart';
import 'package:calcu/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Buttonrow5 extends StatelessWidget {
  const Buttonrow5({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, value, _) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              buttonName: "1",
              buttonColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                value.oneButton();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Expanded(
            child: CustomButton(
              buttonName: "2",
              buttonColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                value.twoButton();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Expanded(
            child: CustomButton(
              buttonName: "3",
              buttonColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                value.threeButton();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Expanded(
            child: CustomButton(
              buttonName: "+",
              buttonColor: Theme.of(context).colorScheme.onTertiary,
              onPressed: () {
                value.plusButton();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      );
    });
  }
}
