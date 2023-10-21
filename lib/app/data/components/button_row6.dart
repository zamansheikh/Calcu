import 'package:calcu/app/data/components/button.dart';
import 'package:calcu/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';

class Buttonrow6 extends StatelessWidget {
  final HomeController controller;
  Buttonrow6({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomButton(
            buttonName: "0",
            buttonColor: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              controller.zeroButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            buttonName: ".",
            buttonColor: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              controller.dotButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            buttonName: "=",
            buttonColor:
                Theme.of(context).colorScheme.inversePrimary.withOpacity(.8),
            onPressed: () {
              controller.equalButton();
            },
            onLongPressed: () {
              controller.equalButtonLong();
            },
            textColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
