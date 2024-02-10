import 'package:flutter/material.dart';

class MLoaders {
  static Widget showLoadingIndicator(
      {Color? color, double? size, String? title}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title != null) Text(title),
          const SizedBox(height: 10),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.blue),
            strokeWidth: size ?? 5,
          ),
        ],
      ),
    );
  }

  static void warningSnackBar(
      {required String title, required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
