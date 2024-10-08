import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String buttonName;
  final Color buttonColor;
  final Function() onPressed;
  final Function()? onLongPressed;
  final Color textColor;
  final bool hasChild;
  final Widget? child;

  const CustomButton({
    super.key,
    required this.buttonName,
    required this.buttonColor,
    required this.onPressed,
    this.onLongPressed,
    this.hasChild = false,
    this.child,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        radius: 16.sp,
        borderRadius: BorderRadius.circular(16),
        onLongPress: onLongPressed,
        onTap: onPressed,
        child: SizedBox(
          child: Container(
            alignment: Alignment.center,
            padding:  EdgeInsets.all(10.sp),
            margin:  EdgeInsets.symmetric(horizontal: 3.sp),
            decoration: BoxDecoration(
                color: buttonColor, borderRadius: BorderRadius.circular(16.sp)),
            child: hasChild
                ? child
                : Text(
                    buttonName,
                    style: TextStyle(color: textColor, fontSize: 25.sp),
                  ),
          ),
        ),
      ),
    );
  }
}
