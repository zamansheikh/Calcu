import 'package:calcu/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputViewRow extends StatefulWidget {
  final HomeController controller;
  const InputViewRow({super.key, required this.controller});

  @override
  State<InputViewRow> createState() => _InputViewRowState();
}

class _InputViewRowState extends State<InputViewRow> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        widget.controller.clickOnInputDisplay();
        Get.snackbar(
          'Input',
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
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        child: SingleChildScrollView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                widget.controller
                    .addCommasToNumbers(widget.controller.input.value),
               
                style: TextStyle(
                  fontSize: 50,
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
