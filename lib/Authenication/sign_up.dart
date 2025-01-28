import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pain_pay/Authenication/auth_code.dart';
import 'package:pain_pay/Nav/Home.dart';
import 'package:pain_pay/Onboarding/privacy_policy.dart';
import 'package:pain_pay/services/email_service.dart';
import 'package:pain_pay/shared/TextFields.dart';
import 'package:pain_pay/shared/Texts.dart';
import 'package:pain_pay/shared/app_bar.dart';
import 'package:pain_pay/shared/buttons.dart';
import 'package:pain_pay/shared/modal.dart';
import 'package:pain_pay/shared/size.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final EmailService emailService = EmailService();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isChecked = false;
  bool isLoading = false;
  String passwordStrength = '';
  String passwordMatch = '';
  bool isFormValid = false;
  String emailValidationMessage = '';
  bool isObsecure = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to controllers to validate form
    emailController.addListener(validateForm);
    phoneController.addListener(validateForm);
    emailController.addListener(() {
      validateEmail();
      validateForm();
    });
    passwordController.addListener(() {
      checkPasswordStrength();
      validateForm();
    });
    confirmPasswordController.addListener(() {
      checkPasswordMatch();
      validateForm();
    });
  }

  void checkPasswordStrength() {
    String password = passwordController.text;
    if (password.isEmpty) {
      setState(() => passwordStrength = '');
    } else if (password.length < 8) {
      setState(() => passwordStrength = 'Weak');
    } else if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      setState(() => passwordStrength = 'Strong');
    } else {
      setState(() => passwordStrength = 'Medium');
    }
  }

  void checkPasswordMatch() {
    setState(() {
      passwordMatch = confirmPasswordController.text == passwordController.text
          ? 'Passwords match'
          : 'Passwords do not match';
    });
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 9) {
      return '+254${digits.substring(digits.length - 9)}';
    }
    return digits;
  }

  void validateForm() {
    setState(() {
      isFormValid = emailController.text.isNotEmpty &&
          isValidEmail(emailController.text) &&
          phoneController.text.isNotEmpty &&
          passwordController.text.length >= 8 &&
          confirmPasswordController.text == passwordController.text &&
          isChecked;
    });
  }

  void logEvent() {
    try {
      analytics.logEvent(
        name: "signup_complete",
        parameters: {"method": "email"},
      );
    } catch (error) {
      // print("Error logging event: $error");
    }
  }

  void validateEmail() {
    if (emailController.text.isEmpty) {
      setState(() => emailValidationMessage = '');
    } else if (!isValidEmail(emailController.text)) {
      setState(() => emailValidationMessage = 'Invalid email format');
    } else {
      setState(() => emailValidationMessage = 'Valid email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String phonenumber = phoneController.text.trim();
    final String userEmail = emailController.text.trim();
    final screensize = ScreenSizes(context);
    final emailError =
        emailController.text.isNotEmpty && !isValidEmail(emailController.text)
            ? 'Invalid email format'
            : null;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Create your account',
      ),
      body: Stack(children: [
        // Center(
        // child:
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // const SubTitle(text: 'Create your account'),
              // const SizedBox(height: 15),
              const NormalText(
                  text:
                      'User-friendly solutions. Join us now to unlock a brighter online journey.'),
              const SizedBox(height: 30),
              InputField(
                controller: emailController,
                hint: 'email@example.com',
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                suffixIcon: Icon(
                  Icons.check_circle_outline_outlined,
                  color: emailValidationMessage == 'Valid email'
                      ? Colors.green
                      : Colors.grey,
                ),
                errorText: emailError,
              ),

              Row(
                children: [
                  Spacer(),
                  Text(
                    emailValidationMessage,
                    style: TextStyle(
                      color: emailValidationMessage == 'Valid email'
                          ? Colors.green
                          : emailValidationMessage.isNotEmpty
                              ? Colors.red
                              : Colors.transparent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              InputField(
                controller: phoneController,
                hint: '+254XXXXXXXXX',
                label: 'Phone Number',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.phone_android_outlined),
                onChanged: (value) {
                  String formatted = formatPhoneNumber(value);
                  if (formatted != value) {
                    phoneController.value = TextEditingValue(
                      text: formatted,
                      selection:
                          TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              ),
              const SizedBox(height: 15),
              InputField(
                controller: passwordController,
                hint: 'Password',
                label: 'Password',
                obscureText: !isObsecure,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    isObsecure
                        ? Icons.visibility
                        : Icons.visibility_off, 
                        color:  passwordStrength == 'Strong' ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isObsecure = !isObsecure; // Toggle visibility state
                    });
                  },
                  // color:
                  //     passwordStrength == 'Strong' ? Colors.green : Colors.grey,
                ),
              ),
              Row(
                children: [
                  Spacer(),
                  Text(
                    passwordStrength,
                    style: TextStyle(
                      color: passwordStrength == 'Strong'
                          ? Colors.green
                          : passwordStrength == 'Medium'
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              InputField(
                controller: confirmPasswordController,
                hint: 'Confirm Password',
                label: 'Confirm Password',
                obscureText: !isObsecure,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: Icon(
                  Icons.check_circle_outline_outlined,
                  color: passwordMatch == 'Passwords match'
                      ? Colors.green
                      : Colors.grey,
                ),
              ),
              Row(
                children: [
                  Spacer(),
                  Text(
                    passwordMatch,
                    style: TextStyle(
                      color: passwordMatch == 'Passwords match'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                        validateForm();
                      });
                    },
                  ),
                  SizedBox(
                    height: screensize.screenHeight * 0.07,
                  ),
                  Flexible(
                    child: GestureDetector(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'I certify that I am 18 years of age or older, and I agree to the User Agreement and ',
                              style: TextStyle(
                                // color: Colors.black, // Default text color
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Colors
                                    .blue, // Highlight color for "Privacy Policy"
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PrivacyPolicy(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screensize.screenHeight * 0.10,
              ),
              Align(
                alignment: Alignment.bottomCenter,
              ),
              AppButton(
                text: isLoading ? 'Loading...' : 'Continue',
                isDisabled: !isFormValid,
                onPressed: () async {
                  setState(() => isLoading = true);

                  // Show demo message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'Demo Mode: Data is not being stored. This is just a showcase.'),
                      duration: const Duration(seconds: 10),
                      action: SnackBarAction(
                        label: 'Dismiss',
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );

                  // verifyEmail.showModal(
                  //   context: context,
                  //   content: '',
                  //   title: 'Enter code sent to your email',
                  //   messageType: MessageType.info,
                  //   onPressed: () {
                  //     Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => AuthCode(
                  //                   phonenumber: phonenumber,
                  //                 )));
                  //   },
                  // );

                  // Log analytics and navigate
                  logEvent();
                  await Future.delayed(Duration(seconds: 1));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AuthCode(
                                phonenumber: phonenumber,
                                userEmail: userEmail,
                              )));

                  setState(() {
                    isLoading = false;
                  });
                },
              ),
            ],
          ),
        ),
        // ),
      ]),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
