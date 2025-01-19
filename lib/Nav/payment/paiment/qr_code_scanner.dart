import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QrCodeScanner extends StatelessWidget {
  QrCodeScanner({super.key, required this.setResult});

  final Function setResult;
  final MobileScannerController controller = MobileScannerController();

  // Function to handle redirection to a URL
  Future<void> _redirectToUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Center(
          child: Column(
        children: [
          SizedBox(
            height: 300, // Set desired height
            width: 300, // Set desired width
            child: MobileScanner(
              controller: controller,
              onDetect: (BarcodeCapture capture) async {
                final List<Barcode> barcodes = capture.barcodes;
                final barcode = barcodes.first;

                if (barcode.rawValue != null) {
                  setResult(barcode.rawValue);

                  await controller
                      .stop()
                      .then((value) => controller.dispose())
                      .then((value) => Navigator.of(context).pop());
                }

                for (final barcode in barcodes) {
                  final rawValue = barcode.rawValue ?? '';
                  print(rawValue);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Detected: $rawValue')),
                  );

                  // Redirect if the raw value is a valid link
                  if (rawValue.startsWith('http') ||
                      rawValue.startsWith('https')) {
                    _redirectToUrl(context, rawValue);
                    break; // Stop further scanning after redirection
                  }
                }
              },
            ),
          ),
          SizedBox(height: 20),
          Text('Scan Qr code '),
          Text('Scan Qr code to send money ')
        ],
      )),
    );
  }
}
