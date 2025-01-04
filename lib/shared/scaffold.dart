import 'package:flutter/material.dart';
import 'package:pain_pay/shared/colors.dart';

class AppScaffoldMessenger extends StatelessWidget {
  final String message;
  final ScaffoldMessageType messageType;
  final Duration? duration;

  const AppScaffoldMessenger({
    Key? key,
    required this.message,
    required this.messageType,
    this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    IconData icon;

    // Determine message style based on type
    switch (messageType) {
      case ScaffoldMessageType.success:
        backgroundColor = AppColors.success;
        icon = Icons.check_circle;
        break;
      case ScaffoldMessageType.error:
        backgroundColor = AppColors.error;
        icon = Icons.error;
        break;
      case ScaffoldMessageType.progress:
        backgroundColor = AppColors.progress;
        icon = Icons.info;
        break;
    }

    return ScaffoldMessenger(
      child: Scaffold(
        body: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(icon, color: AppColors.iconColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(color: AppColors.textColor),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: backgroundColor,
                  duration: duration ?? const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.only(top: 16, right: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              );
            });

            return const SizedBox
                .shrink(); // Empty widget to allow Snackbar display
          },
        ),
      ),
    );
  }
}

enum  ScaffoldMessageType {
  success,
  error,
  progress,
}
