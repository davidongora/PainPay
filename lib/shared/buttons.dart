import 'package:flutter/material.dart';
import 'package:pain_pay/shared/colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 370,
      height: 55,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? AppColors.disabled : AppColors.enabled,
          padding: const EdgeInsets.symmetric(
            horizontal: 12.14,
            vertical: 8.09,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.47),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.buttColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1
          ),
        ),
      ),
    );
  }
}
