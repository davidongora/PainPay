import 'package:flutter/material.dart';
import 'package:pain_pay/Authenication/auth_code.dart';
import 'package:pain_pay/shared/Texts.dart';
import 'package:pain_pay/shared/buttons.dart';
import 'package:pain_pay/shared/colors.dart';
import 'package:pain_pay/shared/otp.dart';

class AppModal {
  static void showModal({
    required BuildContext context,
    required String title,
    required String content,
    required MessageType messageType,
    VoidCallback? onPressed,
  }) {
    Color backgroundColor;
    IconData icon;

    switch (messageType) {
      case MessageType.success:
        backgroundColor = AppColors.success;
        icon = Icons.check_circle;
        break;
      case MessageType.error:
        backgroundColor = AppColors.error;
        icon = Icons.error;
        break;
      case MessageType.info:
        backgroundColor = AppColors.info;
        icon = Icons.info;
        break;
      case MessageType.progress:
        backgroundColor = AppColors.progress;
        icon = Icons.info;
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: backgroundColor),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: backgroundColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onPressed;
                  },
                  child: const Text('OK',
                      style: TextStyle(color: AppColors.textColor)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WelcomeAppModal {
  static void showModal({
    required BuildContext context,
    required String title,
    required String content,
    required MessageType messageType,
  }) {
    Color backgroundColor;
    // Image icon;

    // switch (messageType) {
    //   case MessageType.success:
    //     backgroundColor = AppColors.success;
    //     // icon = Image.asset('asset/welcomePage.png');
    //     break;
    //   case MessageType.error:
    //     backgroundColor = AppColors.error;
    //     icon = Image.asset('asset/welcomePage.png');
    //     break;
    //   case MessageType.info:
    //     backgroundColor = AppColors.info;
    //     icon = Image.asset('asset/welcomePage.png');
    //     break;
    //   case MessageType.progress:
    //     backgroundColor = AppColors.progress;
    //     icon = Image.asset('asset/welcomePage.png');
    //     break;
    // }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/welcomePage.png'),
                const SizedBox(height: 12),
                Text(
                  'welcome to pain Pay',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    // color: backgroundColor,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    'simplify cross-border transactions while addressing the pain points of traditional apps',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: 'USE APP',
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class PaymentAppModal {
  static void showModal({
    required BuildContext context,
    required String title,
    required String content,
    required MessageType messageType,
  }) {
    Color backgroundColor;
    // Image icon;

    // switch (messageType) {
    //   case MessageType.success:
    //     backgroundColor = AppColors.success;
    //     // icon = Image.asset('asset/welcomePage.png');
    //     break;
    //   case MessageType.error:
    //     backgroundColor = AppColors.error;
    //     icon = Image.asset('asset/welcomePage.png');
    //     break;
    //   case MessageType.info:
    //     backgroundColor = AppColors.info;
    //     icon = Image.asset('asset/welcomePage.png');
    //     break;
    //   case MessageType.progress:
    //     backgroundColor = AppColors.progress;
    //     icon = Image.asset('asset/welcomePage.png');
    //     break;
    // }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/welcomePage.png',
                  height: 120,
                  width: 120,
                ),
                const SizedBox(height: 12),
                Text(
                  'Payment Sucess',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    // color: backgroundColor,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    Row(
                      children: [
                        NormalText(text: 'Transaction Id'),
                        Spacer(),
                        NormalText(text: '930')
                      ],
                    ),
                    Row(
                      children: [
                        NormalText(text: 'Transaction Id'),
                        Spacer(),
                        NormalText(text: '930')
                      ],
                    ),
                    Row(
                      children: [
                        NormalText(text: 'Transaction Id'),
                        Spacer(),
                        NormalText(text: '930')
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    'simplify cross-border transactions while addressing the pain points of traditional apps',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: 'USE APP',
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class verifyEmail {
  static get controller => null;

  static get focusNode => null;

  static get onChanged => null;

  static void showModal({
    required BuildContext context,
    required String title,
    required String content,
    required MessageType messageType,
    VoidCallback? onPressed,
  }) {
    Color backgroundColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/welcomePage.png'),
                const SizedBox(height: 12),
                Text(
                  'welcome to pain Pay',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    // color: backgroundColor,
                  ),
                ),
                const SizedBox(height: 12),
                SquareNumberInput(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged),

                // Flexible(
                //   child: Text(
                //     'simplify cross-border transactions while addressing the pain points of traditional apps',
                //     textAlign: TextAlign.center,
                //     style: const TextStyle(fontSize: 16),
                //   ),
                // ),
                const SizedBox(height: 20),
                AppButton(
                    text: 'Verify',
                    onPressed: () {
                      AppModal.showModal(
                        context: context,
                        title: 'Email Verified',
                        content: 'Email verified Successfull',
                        messageType: MessageType.success,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      );

                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => AuthCode()));
                    })
              ],
            ),
          ),
        );
      },
    );
  }
}

enum MessageType {
  success,
  error,
  progress,
  info,
}
