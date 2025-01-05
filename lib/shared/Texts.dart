import 'package:flutter/material.dart';
import 'package:pain_pay/shared/colors.dart';

class TitleText extends StatelessWidget {
  final String text;

  const TitleText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 26.42,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
        // color: AppColors.whiteextColor
      ),
      textAlign: TextAlign.start,
    );
  }
}

class SubTitle extends StatelessWidget {
  final String text;

  const SubTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
        // color: AppColors.textColor
      ),
      textAlign: TextAlign.start,
    );
  }
}

class NormalText extends StatelessWidget {
  final String text;

  const NormalText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.normal,
        // color: AppColors.textColor,
      ),
      textAlign: TextAlign.start,
    );
  }
}

class LinkText extends StatelessWidget {
  final String text;

  const LinkText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.normal,
        color: AppColors.linktext,
      ),
      textAlign: TextAlign.start,
    );
  }
}
