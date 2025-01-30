import 'package:flutter/material.dart';
import 'package:pain_pay/shared/colors.dart';

class InputField extends StatelessWidget {
  final String label;
  final String hint;
  final Icon? suffixIcon;
  final Icon? prefixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;


  const InputField({
    Key? key,
    required this.hint,
    required this.label,
    this.suffixIcon,
    this.prefixIcon,
    this.controller,
    this.obscureText = false, 
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 375.6,
      height: 64,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textColor),
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.textColor),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.textColor, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
