import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pain_pay/shared/buttons.dart';

class IDVerificationPage extends StatefulWidget {
  @override
  _IDVerificationPageState createState() => _IDVerificationPageState();
}

class _IDVerificationPageState extends State<IDVerificationPage> {
  final int totalSteps = 3;
  int currentStep = 0;
  File? _imageFile;
  bool isProcessing = false;
  CameraController? _controller;
  bool isCameraReady = false;
  Map<String, String> extractedData = {}; // To hold extracted ID details

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) {
      setState(() => isCameraReady = true);
    }
  }

  Future<void> _processImage() async {
    if (_imageFile == null) return;

    setState(() => isProcessing = true);

    try {
      final uri = Uri.parse(
          'https://www.ocrwebservice.com/restservices/processDocument?language=english&gettext=true');

      // Set headers
      final headers = {
        'Authorization': 'Basic T05HT1JBREFWSUQ6RjQxQUY0NDMtOUz',
        'Cookie': 'ARRAffinity=b0a70f67dde74f4ddd92e8348ebd14e6',
      };

      // Create a multipart request
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..files
            .add(await http.MultipartFile.fromPath('image', _imageFile!.path));

      // Send the request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      // Parse JSON response
      final jsonResponse = json.decode(responseData);
      if (jsonResponse['ErrorMessage']?.isNotEmpty ?? false) {
        throw Exception(jsonResponse['ErrorMessage']);
      }

      // Extract and display OCR text
      final ocrText =
          (jsonResponse['OCRText'] as List).expand((zone) => zone).join('\n');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Extracted ID Details'),
          content: SingleChildScrollView(
            child: Text(ocrText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error processing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process the ID. Try again.')),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Widget _buildCameraPreview() {
    if (!isCameraReady) return Container();

    return Stack(
      children: [
        CameraPreview(_controller!),
        Positioned.fill(
          child: CustomPaint(
            painter: IDFramePainter(),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: AppButton(
              text: 'Capture',
              onPressed: () async {
                if (!_controller!.value.isInitialized) return;
                final image = await _controller!.takePicture();
                setState(() {
                  _imageFile = File(image.path);
                  currentStep++;
                });
              },
              isDisabled: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: 30,
            height: 8,
            decoration: BoxDecoration(
              color: index <= currentStep ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ID Verification')),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: IndexedStack(
              index: currentStep,
              children: [
                _buildInstructionsStep(),
                _buildCameraStep(),
                _buildVerificationStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Please prepare your ID document',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 20),
          Image.asset('assets/welcomePage.png', height: 200),
          Spacer(),
          AppButton(
            text: 'Continue',
            onPressed: () => setState(() => currentStep++),
            isDisabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraStep() {
    return Column(
      children: [
        Expanded(child: _buildCameraPreview()),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Position your ID within the frame'),
        ),
      ],
    );
  }

  Widget _buildVerificationStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_imageFile != null) Image.file(_imageFile!, height: 200),
          SizedBox(height: 20),
          if (isProcessing)
            CircularProgressIndicator()
          else if (extractedData.isNotEmpty)
            Column(
              children: extractedData.entries
                  .map((entry) => Text('${entry.key}: ${entry.value}'))
                  .toList(),
            )
          else
            AppButton(
              text: 'Verify ID',
              onPressed: _processImage,
              isDisabled: false,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class IDFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final idAspectRatio = 1.58; // Standard ID card aspect ratio
    final frameWidth = size.width * 0.8;
    final frameHeight = frameWidth / idAspectRatio;
    final frameRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameWidth,
      height: frameHeight,
    );

    canvas.drawRect(frameRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
