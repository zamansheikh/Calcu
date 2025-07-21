import 'package:calcu/core/widgets/snakebar.dart';
import 'package:calcu/presentation/providers/calculator_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class EnhancedSavedView extends StatelessWidget {
  const EnhancedSavedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculatorProvider, _) {
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
              // Saved values list
              Expanded(
                child: calculatorProvider.savedValues.isEmpty
                    ? Center(
                        child: Text(
                          'No saved values',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.inversePrimary.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: calculatorProvider.scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: calculatorProvider.savedValues.length,
                        itemBuilder: (BuildContext context, int index) {
                          final value = calculatorProvider.savedValues[index];
                          return Row(
                            children: [
                              // Saved value chip
                              InkWell(
                                onTap: () {
                                  calculatorProvider.useSavedValue(index);
                                },
                                borderRadius: BorderRadius.circular(10.sp),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.sp,
                                    vertical: 8.sp,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(10.sp),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${index + 1}:",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary
                                              .withValues(alpha: 0.7),
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      SizedBox(width: 4.sp),
                                      Text(
                                        double.tryParse(value) != null
                                            ? double.parse(
                                                value,
                                              ).toStringAsFixed(2)
                                            : value,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.inversePrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Delete button
                              Padding(
                                padding: EdgeInsets.only(left: 4.sp),
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 28.sp,
                                  height: 28.sp,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(14.sp),
                                  ),
                                  child: IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      calculatorProvider.deleteSavedValue(
                                        index,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      size: 14.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(width: 8.sp);
                        },
                      ),
              ),
              // Clear all button
              if (calculatorProvider.savedValues.isNotEmpty) ...[
                SizedBox(width: 8.sp),
                InkWell(
                  onLongPress: () {
                    calculatorProvider.clearAllSavedValues();
                    showCustomSnackbar(context, "All values deleted", "OK");
                  },
                  borderRadius: BorderRadius.circular(10.sp),
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
            ],
          ),
        );
      },
    );
  }
}
