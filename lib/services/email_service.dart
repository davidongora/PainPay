import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailService {
  final String smtpServer = 'smtp.gmail.com';
  final int smtpPort = 587;
  // final String username = dotenv.get('SMTP_EMAIL');
  // final String password = dotenv.get('SMTP_PASSWORD');

  final String username = 'ongoradavid5@gmail.com';
  final String password = 'vapbexbbmyqfumdr';


  Future<void> sendEmail({
    required String recipient,
    required String subject,
    required String body,
  }) async {
    final smtpServer = SmtpServer(
      this.smtpServer,
      port: smtpPort,
      username: username,
      password: password,
      ignoreBadCertificate: true,
    );

    final message = Message()
      ..from = Address(username, 'Pain Pay')
      ..recipients.add(recipient)
      ..subject = subject
      ..text = body;

    try {
      if (username.isEmpty || password.isEmpty) {
        throw Exception(
            'SMTP_EMAIL or SMTP_PASSWORD is not set in the .env file.');
      }
      final sendReport = await send(message, smtpServer);
      print('Email sent successfully: $sendReport');
    } catch (e) {
      print('Failed to send email: $e');
      rethrow;
    }
  }
}
