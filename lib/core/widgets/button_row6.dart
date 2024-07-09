import 'package:calcu/core/widgets/button.dart';
import 'package:calcu/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Buttonrow6 extends StatelessWidget {
  const Buttonrow6({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, value, _) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: CustomButton(
              buttonName: "0",
              buttonColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                value.zeroButton();
              },
              textColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Expanded(
            child: CustomButton(
              buttonName: ".",
              buttonColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                value.dotButton();
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
                value.equalButton();
              },
              onLongPressed: () {
                value.equalButtonLong();
              },
              textColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      );
    });
  }
}
