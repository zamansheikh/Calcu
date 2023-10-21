import 'package:calcu/app/data/components/button.dart';
import 'package:calcu/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';

class Buttonrow1 extends StatelessWidget {
  final HomeController controller;
  const Buttonrow1({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            buttonName: "AC",
            buttonColor: Colors.red.shade400,
            onPressed: () {
              controller.acButton();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            buttonName: "(",
            buttonColor: Theme.of(context).colorScheme.tertiary,
            onPressed: () {
              controller.parenThesisForward();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            buttonName: ")",
            buttonColor: Theme.of(context).colorScheme.tertiary,
            onPressed: () {
              controller.parenThesisBackward();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            hasChild: true,
            buttonName: "",
            buttonColor: Theme.of(context).colorScheme.tertiary,
            onPressed: () {
              controller.delFromInput();
            },
            textColor: Theme.of(context).colorScheme.inversePrimary,
            child: Icon(
              Icons.backspace,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
      ],
    );
  }
}
