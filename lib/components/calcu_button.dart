import 'package:calcu/styles/app_colors.dart';
import 'package:flutter/material.dart';
import '../styles/app_text.dart';

class CalcuButton extends StatelessWidget {
  final String buttonName;
  final Color buttonColor;
  final Function() onPressed;
  final Function()? onLongPressed;

  const CalcuButton(
      {super.key,
      required this.buttonName,
      required this.buttonColor,
      required this.onPressed,
      this.onLongPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      radius: 16,
      borderRadius: BorderRadius.circular(16),
      onLongPress: onLongPressed,
      onTap: onPressed,
      child: SizedBox(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 60,
          width: 80,
          decoration: BoxDecoration(
              color: buttonColor, borderRadius: BorderRadius.circular(16)),
          child: Text(
            buttonName,
            style: AppText.calc.copyWith(color: AppColors.textColor),
          ),
        ),
      ),
    );
  }
}
