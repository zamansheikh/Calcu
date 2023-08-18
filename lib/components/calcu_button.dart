import 'package:calcu/styles/app_colors.dart';
import 'package:flutter/material.dart';
import '../styles/app_text.dart';

class CalcuButton extends StatelessWidget {
  final String buttonName;
  final Color buttonColor;
  final Function() onPressed;

  const CalcuButton(
      {super.key,
      required this.buttonName,
      required this.buttonColor,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      height: 60,
      width: 80,
      decoration: BoxDecoration(
          color: buttonColor, borderRadius: BorderRadius.circular(16)),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          buttonName,
          style: AppText.calc.copyWith(color: AppColors.textColor),
        ),
      ),
    );
  }
}
