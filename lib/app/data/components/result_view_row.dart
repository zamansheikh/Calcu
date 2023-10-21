import 'package:calcu/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResultViewRow extends StatefulWidget {
  final HomeController controller;
  const ResultViewRow({super.key, required this.controller});

  @override
  State<ResultViewRow> createState() => _ResultViewRowState();
}

class _ResultViewRowState extends State<ResultViewRow> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        widget.controller.clickOnResult();
        Get.snackbar(
          'Result',
          'Copied to clipboard',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Theme.of(context).colorScheme.background,
          colorText: Theme.of(context).colorScheme.inversePrimary,
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
          duration: const Duration(seconds: 1),
        );
        widget.controller.scrollController.animateTo(
          widget.controller.scrollController.position.maxScrollExtent,
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
                widget.controller
                    .addCommasToNumbers(widget.controller.output.value),
                style: TextStyle(
                  fontSize: 45,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
