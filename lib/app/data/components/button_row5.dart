import 'package:calcu/app/data/components/button.dart';
import 'package:calcu/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';

class Buttonrow5 extends StatelessWidget {
  final HomeController controller;
  Buttonrow5({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            buttonName: "1",
            buttonColor: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              controller.oneButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            buttonName: "2",
            buttonColor: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              controller.twoButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            buttonName: "3",
            buttonColor: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              controller.threeButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            buttonName: "+",
            buttonColor: Theme.of(context).colorScheme.onTertiary,
            onPressed: () {
              controller.plusButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ],
    );
  }
}
