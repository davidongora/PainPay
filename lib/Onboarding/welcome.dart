import 'package:flutter/material.dart';
import 'package:pain_pay/Authenication/login.dart';
import 'package:pain_pay/Authenication/sign_up.dart';
import 'package:pain_pay/shared/Texts.dart';
import 'package:pain_pay/shared/buttons.dart';
import 'package:pain_pay/shared/colors.dart';
import 'package:pain_pay/shared/size.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;
    final screenSize = ScreenSizes(context);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: screenSize.screenHeight * 0.1),
              Center(
                child: Image.asset(
                  'assets/welcomePage.png',
                  height: screenSize.screenHeight * 0.3,
                  width: screenSize.screenWidth * 0.6,
                ),
              ),
              SizedBox(height: screenSize.screenHeight * 0.05),
              Center(
                child: TitleText(
                  text: 'Welcome to PainPay',

                  // textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          // Bottom content
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenSize.screenWidth * 0.1,
                  vertical: screenSize.screenHeight * 0.05),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    text: 'Create new account',
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SignUp()));
                    },
                  ),
                  SizedBox(height: screenSize.screenHeight * 0.02),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SignUp()));
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'I already have an account? ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      // Adapts to the theme
                                    ),

                                // style: TextStyle(color: const Color.fromARGB(255, 14, 13, 13)),
                              ),
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(color: AppColors.linktext),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
