import 'package:calcu/app/data/components/button.dart';
import 'package:calcu/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';

class Buttonrow4 extends StatelessWidget {
  final HomeController controller;
  Buttonrow4({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            buttonName: "4",
            buttonColor: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              controller.fourButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            buttonName: "5",
            buttonColor: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              controller.fiveButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            buttonName: "6",
            buttonColor: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              controller.sixButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            buttonName: "-",
            buttonColor: Theme.of(context).colorScheme.onTertiary,
            onPressed: () {
              controller.minusButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ],
    );
  }
}
