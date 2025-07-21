import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showCustomSnackbar(
  BuildContext context,
  String content,
  String actionText,
) {
  final snackBar = SnackBar(
    content: Text(
      content,
      style: TextStyle(
        color: Theme.of(
          context,
        ).colorScheme.inversePrimary.withValues(alpha: .8),
      ),
    ),
    backgroundColor: Theme.of(context).colorScheme.surface,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(10.sp),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.sp)),
    duration: const Duration(milliseconds: 800),
    action: SnackBarAction(
      label: actionText,
      textColor: Theme.of(context).colorScheme.inversePrimary,
      onPressed: () {
        // Perform some action if needed
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
