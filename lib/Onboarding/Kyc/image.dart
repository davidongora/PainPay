import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:pain_pay/shared/app_bar.dart';
import 'package:pain_pay/shared/bottom_nav.dart';
import 'dart:io';

import 'package:pain_pay/shared/buttons.dart';
import 'package:pain_pay/shared/modal.dart';
import 'package:pain_pay/shared/scaffold.dart';

class EditMyProfile extends StatefulWidget {
  const EditMyProfile({super.key});

  @override
  State<EditMyProfile> createState() => _EditMyProfileState();
}

class _EditMyProfileState extends State<EditMyProfile> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  File? _selectedImage;
  bool isProcessing = false;

  final ImagePicker _picker = ImagePicker();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<bool> detectFace(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    try {
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      return faces.isNotEmpty;
    } catch (e) {
      print('Error detecting faces: $e');
      return false;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        isProcessing = true;
      });

      final pickedImage = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        // Check for face in the image
        final hasFace = await detectFace(pickedImage.path);

        if (hasFace) {
          setState(() {
            _selectedImage = File(pickedImage.path);
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.blue,
              content: Text('Face detected and image uploaded successfully')));
          AppScaffoldMessenger(
            message: 'Face detected and image uploaded successfully',
            messageType: ScaffoldMessageType.success,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                  'No face detected. Please upload an image with a face.')));
          AppScaffoldMessenger(
            message: 'No face detected in the image. Please try again.',
            messageType: ScaffoldMessageType.error,
          );
        }
      }
    } catch (e) {
      print('Error picking/processing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content:
              Text('No face detected. Please upload an image with a face.')));
      AppScaffoldMessenger(
        message: 'Error processing image',
        messageType: ScaffoldMessageType.error,
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Kyc Data',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 120.0,
                          backgroundColor: Colors.grey.shade200,
                          child: isProcessing
                              ? const CircularProgressIndicator()
                              : _selectedImage != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                        width: 240,
                                        height: 240,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 122, 120, 120),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: isProcessing
                              ? null
                              : () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (BuildContext context) {
                                      return SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(height: 10),
                                            const Text(
                                              'Choose Photo',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.photo_library,
                                                color: Colors.blue,
                                              ),
                                              title: const Text(
                                                  'Choose from Gallery'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _pickImage(ImageSource.gallery);
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.camera_alt,
                                                color: Colors.blue,
                                              ),
                                              title: const Text('Take a Photo'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _pickImage(ImageSource.camera);
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Upload/Take face photo for KYC purposes',
                    // style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please ensure your face is clearly visible',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: AppButton(
              text: 'Save',
              onPressed: _selectedImage == null
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                              'No face detected. Please upload an image with a face.')));
                    }
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Success')));

                      WelcomeAppModal.showModal(
                          context: context,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainNavigation()));
                          },
                          title: 'Welcome to Pain pay',
                          content: 'Enjoy your tour',
                          messageType: MessageType.success);
                    },
            ),
          ),
        ],
      ),
    );
  }
}
