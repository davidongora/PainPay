import 'package:flutter/material.dart';
import 'package:pain_pay/shared/Texts.dart';
import 'package:pain_pay/shared/app_bar.dart';
import 'package:pain_pay/shared/buttons.dart';

class VerEmail extends StatelessWidget {
  const VerEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.symmetric(horizontal: 16)),
            Image.asset('assets/email_ver.png'),
            SizedBox(
              height: 10,
            ),
            SubTitle(text: 'Verify your email'),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.only(left: 20)),
                Flexible(
                    child: NormalText(
                        text:
                            'We sent a verificationemail to you.Please tap the link to reset')),
              ],
            ),
            SizedBox(
              height: 60,
            ),
            // Spacer(),
            AppButton(text: 'Continue', onPressed: () {})
          ],
        ),
      ),
    );
  }
}
