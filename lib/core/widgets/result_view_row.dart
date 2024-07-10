import 'package:calcu/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResultViewRow extends StatefulWidget {
  const ResultViewRow({super.key});

  @override
  State<ResultViewRow> createState() => _ResultViewRowState();
}

class _ResultViewRowState extends State<ResultViewRow> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, value, _) {
        return InkWell(
          onLongPress: () {
            value.clickOnResult();
            value.scrollController.animateTo(
              value.scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
          child: Container(
            width: double.infinity,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            child: SingleChildScrollView(
              // reverse: true,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    value.addCommasToNumbers(value.output),
                    style: TextStyle(
                      fontSize: 35,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
