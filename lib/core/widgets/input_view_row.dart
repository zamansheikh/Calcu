import 'package:calcu/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class InputViewRow extends StatefulWidget {
  const InputViewRow({super.key});

  @override
  State<InputViewRow> createState() => _InputViewRowState();
}

class _InputViewRowState extends State<InputViewRow> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, value, _) {
      return InkWell(
        onLongPress: () {
          value.clickOnInputDisplay();
          value.scrollController.animateTo(
            value.scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        child: Container(
          width: double.infinity,
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(8.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.sp),
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
                  value.addCommasToNumbers(value.input),
                  style: TextStyle(
                    fontSize: 50.sp,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
