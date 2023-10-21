import 'package:calcu/app/data/components/button.dart';
import 'package:calcu/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';

class Buttonrow2 extends StatelessWidget {
  final HomeController controller;
  Buttonrow2({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            buttonName: "X^",
            buttonColor: Theme.of(context).colorScheme.tertiary,
            onPressed: () {
              controller.squareButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            buttonName: "✓",
            buttonColor: Theme.of(context).colorScheme.tertiary,
            onPressed: () {
              controller.rootOverButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            buttonName: "%",
            buttonColor: Theme.of(context).colorScheme.tertiary,
            onPressed: () {
              controller.percentageButton();
            },
            onLongPressed: () {
              controller.modButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            buttonName: "/",
            buttonColor: Theme.of(context).colorScheme.onTertiary,
            onPressed: () {
              controller.divisionButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ],
    );
  }
}
