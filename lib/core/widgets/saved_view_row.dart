import 'package:calcu/core/widgets/snakebar.dart';
import 'package:calcu/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SavedViewRaw extends StatelessWidget {
  const SavedViewRaw({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, value, _) {
        return Container(
          padding: EdgeInsets.all(8.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.sp),
            border: Border.all(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ListView.separated(
                  controller: value.scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: value.savedValue.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      children: [
                        InkWell(
                          onTap: () {
                            value.pasteFromResult(index);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(8.sp),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10.sp),
                              // border: Border.all(
                              //   color: Theme.of(context).colorScheme.inversePrimary,
                              // ),
                            ),
                            child: Text(
                              "${index + 1} : ${double.parse(value.savedValue[index]).toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Theme.of(
                                  context,
                                ).colorScheme.inversePrimary,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 3.sp),
                          child: Container(
                            alignment: Alignment.center,
                            height: 35.sp,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: .8),
                              borderRadius: BorderRadius.all(
                                Radius.circular(100.sp),
                              ),
                            ),
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                value.delASingleItem(index);
                                value.writeData();
                              },
                              icon: Icon(Icons.clear, size: 16.sp),
                              color: Colors.white,
                              iconSize: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(width: 5.sp);
                  },
                ),
              ),
              SizedBox(width: 5.sp),
              InkWell(
                onLongPress: () {
                  value.delAllItem();
                  value.writeData();
                  showCustomSnackbar(context, "All Deleted", "Ok?");
                },
                child: Container(
                  padding: EdgeInsets.all(10.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.sp),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_forever,
                    color: Theme.of(context).colorScheme.inversePrimary,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
