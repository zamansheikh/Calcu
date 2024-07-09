import 'package:calcu/core/widgets/button.dart';
import 'package:calcu/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Buttonrow3 extends StatelessWidget {
  const Buttonrow3({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, value, _) {
        return Row(
          children: [
            Expanded(
              child: CustomButton(
                  buttonName: "7",
                  buttonColor: Theme.of(context).colorScheme.onSurface,
                  onPressed: () {
                    value.sevenButton();
                  },
                textColor: Theme.of(context).colorScheme.inversePrimary,),
            ),
            Expanded(
              child: CustomButton(
                  buttonName: "8",
                  buttonColor: Theme.of(context).colorScheme.onSurface,
                  onPressed: () {
                    value.eightButton();
                  },
                textColor: Theme.of(context).colorScheme.inversePrimary,),
            ),
            Expanded(
              child: CustomButton(
                  buttonName: "9",
                  buttonColor: Theme.of(context).colorScheme.onSurface,
                  onPressed: () {
                    value.nineButton();
                  },
                textColor: Theme.of(context).colorScheme.inversePrimary,),
            ),
            Expanded(
              child: CustomButton(
                  buttonName: "x",
                 buttonColor: Theme.of(context).colorScheme.onTertiary,
                  onPressed: () {
                    value.multiButton();
                  },
                textColor: Theme.of(context).colorScheme.inversePrimary,),
            ),
          ],
        );
      }
    );
  }
}
