import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pain_pay/Onboarding/Kyc/upload_photo.dart';
import 'package:pain_pay/services/email_service.dart';
import 'package:pain_pay/shared/Texts.dart';
import 'package:pain_pay/shared/app_bar.dart';
import 'package:pain_pay/shared/buttons.dart';
import 'package:pain_pay/shared/modal.dart';
import 'package:pain_pay/shared/otp.dart';
import 'package:pain_pay/wallets/send_sms.dart';
import 'package:sms_autofill/sms_autofill.dart';

class AuthCodeEmail extends StatefulWidget {
  final String userEmail;
  final String phonenumber;
  const AuthCodeEmail(
      {super.key, required this.userEmail, required this.phonenumber});

  @override
  State<AuthCodeEmail> createState() => _AuthCodeEmailState();
}

class _AuthCodeEmailState extends State<AuthCodeEmail>
    with CodeAutoFill, TickerProviderStateMixin {
  String? otpCode;
  final int otpLength = 4;
  bool isLoading = false;
  late AnimationController _appearanceController;
  late Animation<double> _appearanceAnimation;

  final List<TextEditingController> controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );


  Future sendAuthEmail() async {
    final useEmail = widget.userEmail;
    final otpCode = OTPManager();
    final otp = otpCode.generateOTP();

    try {
      print('sending email to $useEmail');
      final emailOtp = EmailService();
      emailOtp.sendEmail(
          recipient: useEmail,
          subject: 'Authenication code ',
          body: 'Hello use this code $otp for authenication ');
    } catch (e) {
      print(e);
      print('unable to send email');
    }
  }

  Future<void> sendAuthCode() async {
    final phonenumber = widget.phonenumber;
    try {
      print('the phone number is $phonenumber');
      print('Sending auth code to: ${widget.phonenumber}');
      final otp = await sendSms(phonenumber: widget.phonenumber);
      if (mounted) {
        extractCodeFromMessage(otp);
      }
    } catch (e) {
      print('Error sending SMS: $e');
      if (mounted) {
        _showError('Failed to send verification code');
      }
    }
  }



  // Future<void> _initializeRemoteConfig() async {
  //   final remoteConfig = FirebaseRemoteConfig.instance;

  //   // Fetch and activate remote values
  //   await remoteConfig.setConfigSettings(RemoteConfigSettings(
  //     fetchTimeout: const Duration(seconds: 10),
  //     minimumFetchInterval: const Duration(hours: 1),
  //   ));

  //   await remoteConfig.fetchAndActivate();

  //   final enableSendAuthCode = remoteConfig.getBool('enable_send_auth_code');
  //   if (enableSendAuthCode) {
  //     // sendAuthCode();
  //   }
  // }

  void _setupAnimations() {
    _appearanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _appearanceAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: Curves.easeInOut,
    );

    _appearanceController.forward();
  }

  Future<void> _initSmsListener() async {
    try {
      await SmsAutoFill().listenForCode();
      final signature = await SmsAutoFill().getAppSignature;
      print('Listening for SMS with signature: $signature');
    } catch (e) {
      print('Error initializing SMS listener: $e');
    }
  }

  @override
  void codeUpdated() {
    print('Code received: $code'); // Debug print
    if (code != null) {
      String? extractedCode = extractCodeFromMessage(code!);
      if (extractedCode != null) {
        setState(() {
          otpCode = extractedCode;
          // Fill the controllers one by one
          for (int i = 0; i < otpLength && i < extractedCode.length; i++) {
            controllers[i].text = extractedCode[i];
          }
        });
      } else {
        print('Failed to extract OTP code from message: $code');
      }
    }
  }

  String? extractCodeFromMessage(String message) {
    // Try multiple patterns to extract the code
    final patterns = [
      r'<#> Your verification code is: (\d{4})',
      r'verification code is: (\d{4})',
      r'code is: (\d{4})',
      r'(\d{4})', // fallback to any 4 digits
    ];

    for (String pattern in patterns) {
      RegExp regExp = RegExp(pattern);
      Match? match = regExp.firstMatch(message);
      if (match != null && match.groupCount >= 1) {
        print('Found code using pattern: $pattern');
        return match.group(1);
      }
    }

    print('No code found in message: $message');
    return null;
  }ii

  void _handleKeyPress(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (controllers[index].text.isEmpty && index > 0) {
          focusNodes[index - 1].requestFocus();
          controllers[index - 1].selection = TextSelection.fromPosition(
            TextPosition(offset: controllers[index - 1].text.length),
          );
        }
      }
    }
  }

  void _verifyOtp() async {
    final code = controllers.map((c) => c.text).join();
    if (code.length != otpLength) {
      _showError('Please enter a valid $otpLength-digit code');
      return;
    }

    setState(() => isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));
      print('Verified OTP: $code');
      // Add your verification logic here
    } catch (e) {
      _showError('Verification failed. Please try again.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _resendCode() async {
    setState(() => isLoading = true);
    try {
      await sendAuthEmail(); // Use the actual send SMS function
      _showSuccess('Code resent successfully');
    } catch (e) {
      _showError('code is not expired. Please try again.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    cancel();
    _appearanceController.dispose();
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Rest of the build method remains the same...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Auth Pa   vvvge')),
      // appBar: const CustomAppBar(
      //   title: 'Auth Page',
      // ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final maxHeight = constraints.maxHeight;

          return Stack(
            children: [
              SafeArea(
                child: FadeTransition(
                  opacity: _appearanceAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(_appearanceAnimation),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: maxWidth * 0.05,
                        vertical: maxHeight * 0.02,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: maxHeight * 0.04),
                          const NormalText(text: 'ENTER OTP CODE:'),
                          SizedBox(height: maxHeight * 0.06),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              4,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: RawKeyboardListener(
                                  focusNode: FocusNode(),
                                  onKey: (event) =>
                                      _handleKeyPress(index, event),
                                  child: SquareNumberInput(
                                    controller: controllers[index],
                                    focusNode: focusNodes[index],
                                    onChanged: (value) {
                                      if (value.length == 1 &&
                                          index < otpLength - 1) {
                                        focusNodes[index + 1].requestFocus();
                                      } else if (value.isEmpty && index > 0) {
                                        focusNodes[index - 1].requestFocus();
                                      }

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UploadPhoto()));
                                      WelcomeAppModal.showModal(
                                          // onTap: Navigator.pop(),
                                          context: context,
                                          title: 'Verified',
                                          content:
                                              'Your Phone Number has been verified',
                                          messageType: MessageType.success);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextButton(
                            onPressed: isLoading ? null : _resendCode,
                            child: Text(
                              'Resend Code',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const Spacer(),
                          AppButton(
                            text: isLoading ? 'Verifying...' : 'Continue',
                            onPressed: isLoading ? null : _verifyOtp,
                          ),
                          SizedBox(height: maxHeight * 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
