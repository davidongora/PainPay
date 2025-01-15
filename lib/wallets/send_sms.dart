import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pain_pay/services/api_service.dart';
import 'package:pain_pay/services/notification_service.dart';
import 'package:sms_autofill/sms_autofill.dart';

final ApiService apiService = ApiService();
final NotificationService _notificationService = NotificationService();

Future<String> generateAppSignature() async {
  String appSignature = await SmsAutoFill().getAppSignature;
  print('App Signature: $appSignature');
  return appSignature;
}

class OTPManager {
  final int expiryDurationInSeconds;
  late String _otp;
  late DateTime _timestamp;

  OTPManager({this.expiryDurationInSeconds = 300}); // Default expiry: 5 minutes

  /// Generates and stores an OTP with the current timestamp
  String generateOTP() {
    final random = Random();
    _otp = (1000 + random.nextInt(9000)).toString(); // 4-digit OTP
    _timestamp = DateTime.now();
    return _otp;
  }

  /// Checks if the OTP is still valid
  bool isValid() {
    final currentTime = DateTime.now();
    final difference = currentTime.difference(_timestamp).inSeconds;
    return difference <= expiryDurationInSeconds;
  }

  /// Verifies the provided OTP
  bool verifyOTP(String otp) {
    if (!isValid()) {
      print('OTP has expired.');
      return false;
    }
    if (_otp == otp) {
      print('OTP verified successfully.');
      return true;
    } else {
      print('Invalid OTP.');
      return false;
    }
  }
}

Future sendSms({
  // required String senderID,
  // required String message,
  required String phonenumber,
}) async {
  final otpManager = OTPManager();
  final otp = otpManager.generateOTP();
  final appSignature = await generateAppSignature();

  final message = 'Your verification code is $otp. $appSignature';
  print('final message sent to user $message');

  try {
    final smsData = await apiService.post(
        '',
        type: ApiEndpoint.sms,
        {'senderID': 'MOBILESASA', 'message': message, 'phone': phonenumber});
    print('sms data $smsData');

    if (smsData != null) {
      _notificationService.showNotification(
        title: 'SMS Sent',
        body:
            'An OTP has been sent to $phonenumber app signature \n $appSignature',
      );
      return smsData;
    }
    throw Exception('Error sending SMS: No response from server');
  } catch (e) {
    print('sms error $e ');
    _notificationService.showNotification(
      title: 'Error',
      body: 'Failed to send OTP to $phonenumber.',
    );
    return {'null $e'};
  }
}
