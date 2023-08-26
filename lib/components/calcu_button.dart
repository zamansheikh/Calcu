import 'package:calcu/controllers/theme_controller.dart';
import 'package:calcu/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../styles/app_text.dart';

// ignore: must_be_immutable
class CalcuButton extends StatelessWidget {
  ThemeController controller = Get.find();
  final String buttonName;
  final Color buttonColor;
  final Function() onPressed;
  final Function()? onLongPressed;
  final bool isHasIcon;

  CalcuButton({
    super.key,
    required this.buttonName,
    required this.buttonColor,
    required this.onPressed,
    this.onLongPressed,
    this.isHasIcon = false,
  });

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
          child: isHasIcon
              ? Icon(
                  Icons.backspace,
                  color: controller.isNightMode.value
                      ? Colors.white
                      : Colors.black,
                )
              : Text(
                  buttonName,
                  style: AppText.calc.copyWith(color: AppColors.textColor),
                ),
        ),
      ),
    );
  }
}
