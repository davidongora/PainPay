import 'package:flutter/material.dart';

class ScreenSizes {
  final BuildContext context;
  ScreenSizes(this.context);

  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;
}
