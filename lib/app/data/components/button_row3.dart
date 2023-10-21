import 'package:calcu/app/data/components/button.dart';
import 'package:calcu/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';

class Buttonrow3 extends StatelessWidget {
  final HomeController controller;
  const Buttonrow3({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
              buttonName: "7",
              buttonColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                controller.sevenButton();
              },
            textColor: Theme.of(context).colorScheme.inversePrimary,),
        ),
        Expanded(
          child: CustomButton(
              buttonName: "8",
              buttonColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                controller.eightButton();
              },
            textColor: Theme.of(context).colorScheme.inversePrimary,),
        ),
        Expanded(
          child: CustomButton(
              buttonName: "9",
              buttonColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                controller.nineButton();
              },
            textColor: Theme.of(context).colorScheme.inversePrimary,),
        ),
        Expanded(
          child: CustomButton(
              buttonName: "x",
             buttonColor: Theme.of(context).colorScheme.onTertiary,
              onPressed: () {
                controller.multiButton();
              },
            textColor: Theme.of(context).colorScheme.inversePrimary,),
        ),
      ],
    );
  }
}
