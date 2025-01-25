import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pain_pay/Authenication/auth_code%20email.dart';
import 'package:pain_pay/Onboarding/Kyc/upload_photo.dart';
import 'package:pain_pay/services/email_service.dart';
import 'package:pain_pay/shared/Texts.dart';
import 'package:pain_pay/shared/app_bar.dart';
import 'package:pain_pay/shared/buttons.dart';
import 'package:pain_pay/shared/otp.dart';
import 'package:pain_pay/wallets/send_sms.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class AuthCode extends StatefulWidget {
  final String phonenumber;
  final String userEmail;

  const AuthCode(
      {super.key, required this.phonenumber, required this.userEmail});

  @override
  State<AuthCode> createState() => _AuthCodeState();
}

class _AuthCodeState extends State<AuthCode>
    with CodeAutoFill, TickerProviderStateMixin {
  String? otpCode;
  final int otpLength = 4;
  bool isLoading = false;
  bool isTimerActive = true;
  late Timer _timer;
  late int _timeLeft;

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

  @override
  void initState() {
    super.initState();
    // sendAuthCode();
    sendAuthEmail();
    _timeLeft = 180; // 3 minutes in seconds
    _setupAnimations();
    _initSmsListener();
    _startTimer();
    _initializeRemoteConfig();
  }

  Future<void> _initializeRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      print('Fetching remote configuration...');

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 1), // For testing
      ));

      // Set default values
      remoteConfig.setDefaults({'enable_send_auth_code': false});

      await remoteConfig.fetchAndActivate();

      final enableSendAuthCode = remoteConfig.getBool('enable_send_auth_code');
      print('enable_send_auth_code: $enableSendAuthCode');

      if (enableSendAuthCode) {
        print('Sending auth code as enabled in remote config');
        sendAuthCode();
      } else {
        print('Auth code sending is disabled via remote config');
      }
    } catch (e) {
      print('Error fetching remote config: $e');
    }
  }

  Future sendAuthEmail() async {
    final useEmail = widget.userEmail;
    final userName = useEmail.split('@')[0];
    final otpCode = OTPManager();
    final otp = otpCode.generateOTP();

    try {
      print('$userName sending mail to');
      print('sending email to $useEmail');
      final emailOtp = EmailService();
      emailOtp.sendEmail(
          recipient: useEmail,
          subject: 'Authenication code ',
          body: 'Hello $userName use this code $otp for email verification ');
    } catch (e) {
      print(e);
      print('unable to send email');
    }
  }

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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          isTimerActive = false;
          timer.cancel();
        }
      });
    });
  }

  void _resetTimer() {
    setState(() {
      _timeLeft = 180;
      isTimerActive = true;
    });
    _startTimer();
  }

  String _formatTime() {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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

  Future<void> sendAuthCode() async {
    try {
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

  @override
  void codeUpdated() {
    if (code != null) {
      String? extractedCode = extractCodeFromMessage(code!);
      if (extractedCode != null && mounted) {
        setState(() {
          otpCode = extractedCode;
          for (int i = 0; i < otpLength && i < extractedCode.length; i++) {
            controllers[i].text = extractedCode[i];
          }
        });
      }
    }
  }

  String? extractCodeFromMessage(String message) {
    final patterns = [
      r'<#> Your verification code is: (\d{4})',
      r'verification code is: (\d{4})',
      r'code is: (\d{4})',
      r'(\d{4})',
    ];

    for (String pattern in patterns) {
      RegExp regExp = RegExp(pattern);
      Match? match = regExp.firstMatch(message);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    return null;
  }

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

  void _handleOtpInput(String value, int index) {
    if (value.length == 1) {
      if (index < otpLength - 1) {
        focusNodes[index + 1].requestFocus();
      } else {
        String fullCode = controllers.map((c) => c.text).join();
        if (fullCode.length == otpLength) {
          _verifyAndProceed(fullCode);
        }
      }
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyAndProceed(String code) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() => isLoading = false);

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: const Text('Verified'),
            content: const Text('Your Phone Number has been verified'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UploadPhoto()),
                  );
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showError('Verification failed. Please try again.');
      }
    }
  }

  void _resendCode() async {
    if (isLoading) return;

    setState(() => isLoading = true);
    try {
      await sendAuthCode();
      if (mounted) {
        _showSuccess('Code resent successfully');
        _resetTimer();
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to resend code. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    cancel();
    _timer.cancel();
    _appearanceController.dispose();
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auth Page'),
      ),
      //  const CustomAppBar(title: 'Auth Page'),
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
                              otpLength,
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
                                    onChanged: (value) =>
                                        _handleOtpInput(value, index),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // ElevatedButton(
                          //   onPressed: _initializeRemoteConfig,
                          //   child: Text('Fetch Remote Config'),
                          // ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: isTimerActive ? null : _resendCode,
                            child: Text(
                              'Resend Code ${_formatTime()}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: isTimerActive
                                        ? Colors.grey
                                        : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const Spacer(),
                          AppButton(
                            text: isLoading ? 'Verifying...' : 'Continue',
                            onPressed: isLoading
                                ? null
                                : () {
                                    String code =
                                        controllers.map((c) => c.text).join();
                                    if (code.length == otpLength) {
                                      _verifyAndProceed(code);
                                    } else {
                                      _showError(
                                          'Please enter a valid $otpLength-digit code');
                                    }
                                  },
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
