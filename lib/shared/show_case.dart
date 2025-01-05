import 'package:flutter/material.dart';

class ShowCase extends StatelessWidget {
  const ShowCase(
      {super.key,
      required this.globalKey,
      required this.title,
      required this.description,
      required this.child,
      required this.shapeBorder});

  final GlobalKey globalKey;
  final String title;
  final String description;
  final Widget child;
  final ShapeBorder shapeBorder;

  @override
  Widget build(BuildContext context) {
    return ShowCase(
        globalKey: globalKey,
        title: title,
        description: description,
        shapeBorder: shapeBorder,
        child: child);
  }
}
