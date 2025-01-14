import 'package:flutter/material.dart';
import 'package:pain_pay/Onboarding/Kyc/image.dart';
import 'package:pain_pay/shared/app_bar.dart';
import 'package:pain_pay/shared/buttons.dart';
import 'package:pain_pay/shared/colors.dart';
import 'package:pain_pay/shared/size.dart';

class UploadPhoto extends StatelessWidget {
  const UploadPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSizes(context);
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 40,
                  bottom:
                      100), // Add bottom padding to avoid overlap with button
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/kyc.png'),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(6, (index) {
                          final steps = [
                            'Remove your eye glasses (if you have any).',
                            'Ensure proper lighting on your face.',
                            'Stand in front of a plain background.',
                            'Do not cover your face with hair or hands.',
                            'Keep your head straight and eyes open.',
                            'Place your face in the photo frame.'
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.theme,
                                  radius: 14,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                        color: AppColors.appbar),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(steps[index])),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.all(20), // Add padding for better spacing
              child: AppButton(
                text: 'Next',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditMyProfile()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
