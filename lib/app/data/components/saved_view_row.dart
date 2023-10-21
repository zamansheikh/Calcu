import 'package:calcu/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SavedViewRaw extends StatelessWidget {
  final HomeController controller;
  const SavedViewRaw({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              controller: controller.scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: controller.savedValue.length,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  children: [
                    InkWell(
                      onTap: () {
                        controller.pasteFromResult(index);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          // border: Border.all(
                          //   color: Theme.of(context).colorScheme.inversePrimary,
                          // ),
                        ),
                        child: Text(
                          "${index + 1} : ${double.parse(controller.savedValue[index]).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: Container(
                        alignment: Alignment.center,
                        height: 35,
                        decoration: BoxDecoration(
                            color: Colors.red.withOpacity(.8),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100))),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            controller.delASingleItem(index);
                          },
                          icon: const Icon(Icons.clear),
                          color: Colors.white,
                          iconSize: 16,
                        ),
                      ),
                    )
                  ],
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(width: 5);
              },
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            child: InkWell(
              onTap: () {
                Get.snackbar(
                  'Long Press',
                  'To clear all saved value',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  colorText: Theme.of(context)
                      .colorScheme
                      .inversePrimary
                      .withOpacity(.8),
                  margin: const EdgeInsets.all(10),
                  borderRadius: 10,
                  duration: const Duration(seconds: 1),
                );
              },
              onLongPress: () {
                controller.delAllItem();
                Get.snackbar(
                  'Deleted',
                  'All saved value',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  colorText: Theme.of(context)
                      .colorScheme
                      .inversePrimary
                      .withOpacity(.8),
                  margin: const EdgeInsets.all(10),
                  borderRadius: 10,
                  duration: const Duration(seconds: 1),
                );
              },
              child: Icon(
                Icons.delete_forever,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
