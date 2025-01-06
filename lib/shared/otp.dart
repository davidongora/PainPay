import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:pain_pay/Authenication/auth_code%20email.dart';
import 'package:pain_pay/shared/Texts.dart';
import 'package:pain_pay/shared/app_bar.dart';
import 'package:pain_pay/shared/buttons.dart';
import 'package:pain_pay/wallets/send_sms.dart';

// Square Input Widget
class SquareNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  const SquareNumberInput({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AuthCode extends StatefulWidget {
  final String phonenumber;
  final String userEmail;

  const AuthCode({
    super.key,
    required this.phonenumber,
    required this.userEmail,
  });

  @override
  State<AuthCode> createState() => _AuthCodeState();
}

class _AuthCodeState extends State<AuthCode>
    with CodeAutoFill, TickerProviderStateMixin {
  String? otpCode;
  final int otpLength = 4;
  bool isLoading = false;
  late AnimationController _appearanceController;
  late Animation<double> _appearanceAnimation;

  // Timer related variables
  Timer? _timer;
  int _remainingSeconds = 180; // 3 minutes in seconds
  bool _canResend = false;

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
    _setupAnimations();
    _initSmsListener();
    sendAuthCode();
    _startTimer();
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
    setState(() {
      _remainingSeconds = 180; // Reset to 3 minutes
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
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

  bool _areAllFieldsFilled() {
    return controllers.every((controller) =>
        controller.text.isNotEmpty && controller.text.length == 1);
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
        // Last digit entered
        if (_areAllFieldsFilled()) {
          String fullCode = controllers.map((c) => c.text).join();
          _verifyAndProceed(fullCode);
        }
      }
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyAndProceed(String code) async {
    if (isLoading) return;

    if (!_areAllFieldsFilled()) {
      _showError('Please fill all fields');
      return;
    }

    setState(() => isLoading = true);

    try {
      // Add your verification logic here
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() => isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AuthCodeEmail(userEmail: widget.userEmail),
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
    if (isLoading || !_canResend) return;

    setState(() => isLoading = true);
    try {
      await sendAuthCode();
      if (mounted) {
        _showSuccess('Code resent successfully');
        _startTimer(); // Restart the timer after resending
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
    _timer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Auth Page'),
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
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed:
                                _canResend && !isLoading ? _resendCode : null,
                            child: Text(
                              _canResend
                                  ? 'Resend Code'
                                  : 'Resend Code (${_formattedTime})',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color:
                                        _canResend ? Colors.blue : Colors.grey,
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
                                    print('$_formattedTime formatted time');
                                    if (_areAllFieldsFilled()) {
                                      String code =
                                          controllers.map((c) => c.text).join();
                                      _verifyAndProceed(code);
                                    } else {
                                      _showError(
                                          'Please fill all fields with valid digits');
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
