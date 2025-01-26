import 'package:flutter/material.dart';
import 'package:pain_pay/shared/TextFields.dart';
import 'package:pain_pay/shared/Texts.dart';
import 'package:pain_pay/shared/app_bar.dart';
import 'package:pain_pay/shared/buttons.dart';
import 'package:pain_pay/shared/modal.dart';

class Deposit extends StatelessWidget {
  const Deposit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Deposit',
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                SizedBox(height: 40),
                CircleAvatar(
                    radius: 70,
                    child: Flexible(
                      child: Text('image or contacts initials'),
                    )),
                SizedBox(
                  height: 10,
                ),
                NormalText(text: 'UserName'),
                SizedBox(height: 40),
                InputField(hint: '300kshs', label: 'Amount'),
                SizedBox(height: 20),
                NormalText(text: 'Your current balance is 200kshs'),
                SizedBox(height: 20),
                InputField(hint: 'Christmas comfort', label: 'Description'),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.all(20.0), // Add padding around the button
              child: AppButton(
                  text: 'Confirm',
                  onPressed: () {
                    PaymentAppModal.showModal(
                        context: context,
                        title: 'Payment processing',
                        content: 'processing',
                        messageType: MessageType.success);
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
