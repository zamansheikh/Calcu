import 'package:calcu/core/widgets/button.dart';
import 'package:calcu/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Buttonrow1 extends StatelessWidget {
  const Buttonrow1({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, value, _) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              buttonName: "AC",
              buttonColor: Colors.red.shade400,
              onPressed: () {
                value.acButton();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Expanded(
            child: CustomButton(
              buttonName: "(",
              buttonColor: Theme.of(context).colorScheme.tertiary,
              onPressed: () {
                value.parenThesisForward();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Expanded(
            child: CustomButton(
              buttonName: ")",
              buttonColor: Theme.of(context).colorScheme.tertiary,
              onPressed: () {
                value.parenThesisBackward();
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
                value.delFromInput();
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
    });
  }
}
