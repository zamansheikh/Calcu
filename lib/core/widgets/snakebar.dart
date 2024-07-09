import 'package:flutter/material.dart';

void showCustomSnackbar(BuildContext context, String content, String actionText) {
  final snackBar = SnackBar(
    content: Text(
      'All saved value',
      style: TextStyle(
        color: Theme.of(context).colorScheme.inversePrimary.withOpacity(.8),
      ),
    ),
    backgroundColor: Theme.of(context).colorScheme.surface,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    duration: const Duration(milliseconds: 700),
    action: SnackBarAction(
      label: 'Deleted',
      textColor: Theme.of(context).colorScheme.inversePrimary,
      onPressed: () {
        // Perform some action if needed
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
