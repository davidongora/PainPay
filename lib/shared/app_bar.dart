import 'package:flutter/material.dart';
import 'package:pain_pay/shared/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onBackPressed;
  final actions;

  const CustomAppBar({
    Key? key,
    this.title,
    this.onBackPressed,
    this.actions
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: actions,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: Text(
        title ?? '',
        textAlign: TextAlign.center,
        style: const TextStyle(
          // color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      // backgroundColor: AppColors.appbar,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
