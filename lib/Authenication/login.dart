import 'package:flutter/material.dart';
import 'package:pain_pay/Nav/Home.dart';
import 'package:pain_pay/Onboarding/privacy_policy.dart';
import 'package:pain_pay/shared/TextFields.dart';
import 'package:pain_pay/shared/Texts.dart';
import 'package:pain_pay/shared/app_bar.dart';
import 'package:pain_pay/shared/bottom_nav.dart';
import 'package:pain_pay/shared/buttons.dart';
import 'package:pain_pay/shared/size.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // final screenSize = ScreenSizes(context);

  bool isObsecure = false;
  bool isButtonActive = false;
  String passwordStrength = 'Too weak';
  String emailError = '';
  final FocusNode emailFocusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('$isButtonActive, you button');

    // Add listeners
    emailController.addListener(() {
      _validateEmail();
      _validateForm();
      print('$isButtonActive, you button state on emai_');
    });

    passwordController.addListener(_validateForm);
    passwordController.addListener(() {
      _updatePasswordStrength();
      _validateForm();
      print('$isButtonActive, you button state on pass_');
    });

    // Dispose focus node when the widget is removed
    emailFocusNode.addListener(() {
      setState(() {}); // Rebuild the widget tree when focus changes
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = emailController.text.trim();
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    setState(() {
      if (email.isEmpty) {
        emailError = 'Email cannot be empty';
      } else if (!emailRegex.hasMatch(email)) {
        emailError = 'Enter a valid email address';
      } else {
        emailError = '';
      }
    });
  }

  void _updatePasswordStrength() {
    int length = passwordController.text.trim().length;

    setState(() {
      if (length == 0) {
        passwordStrength = 'Too weak';
      } else if (length < 6) {
        passwordStrength = 'Weak';
      } else if (length < 10) {
        _validateForm();
        passwordStrength = 'Moderate';
      } else {
        passwordStrength = 'Strong';
      }

      _validateForm();
    });
  }

  void _validateForm() {
    setState(() {
      isButtonActive = passwordController.text.trim().isNotEmpty &&
          emailController.text.trim().isNotEmpty &&
          emailError.isEmpty &&
          passwordController.text.trim().length >= 6 &&
          passwordStrength != 'Too weak' &&
          passwordStrength != 'Weak';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSizes(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Login to PainPay',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              NormalText(
                text:
                    'PainPay is your pathway to a \nseamless digital experience.',
              ),
              const SizedBox(height: 40),
              InputField(
                  controller: emailController,
                  hint: 'user@gmail.com',
                  label: 'Email',
                  // errorText: emailError.isNotEmpty ? emailError : null,
                  // focusNode: emailFocusNode,
                  prefixIcon: Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress),
              Text(
                emailError,
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 35),
              InputField(
                controller: passwordController,
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: isObsecure,
                hint: 'Enter your password',
                label: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    isObsecure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      isObsecure = !isObsecure;
                    });
                  },
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: NormalText(text: 'Forgot password?'),
                  ),
                  SizedBox(width: screenSize.screenWidth * 0.12),
                  // GestureDetector(
                  //   child: LinkText(text: 'Privacy Policy'),
                  //   onTap: () {
                  //     Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => PrivacyPolicy()));
                  //   },
                  // )
                ],
              ),
              const Spacer(), // Pushes the button to the bottom
              Center(
                child: AppButton(
                  text: 'Login',
                  onPressed: () {
                    // if(){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainNavigation()));

                    // }else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error logging in ')));
                    // }
                  },
                ),
              ),
              const SizedBox(height: 20), // Space below the button
            ],
          ),
        ),
      ),
    );
  }
}
