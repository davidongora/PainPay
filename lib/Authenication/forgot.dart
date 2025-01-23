// import 'package:flutter/material.dart';
// import 'package:notes/onboarding/Auth/Recover/emailver.dart';
// import 'package:notes/shared/buttons.dart';
// // import 'package:notes/shared/fields.dart'; // Assuming InputField is defined in fields.dart

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreen();
// }

// class _ForgotPasswordScreen extends State<ForgotPasswordScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool _obscureText = true;

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         // title: const Text('Forgot Password'),
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back,
//             color: Colors.white,
//           ),
//           onPressed: () {
//             Navigator.pop(
//                 context); // This will pop the current screen and go back to the previous one
//           },
//         ),
//         backgroundColor: Colors.black, // Adjust the AppBar color if needed
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Top Text
//               const Text(
//                 'Forgot Password?',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 34,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 60),
//               const Text(
//                 'Enter your registered email, and we will send you instructions to reset your password',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.white,
//                 ),
//               ),
//               // Input Fields
//               const SizedBox(height: 16),
//               InputField(
//                 labelText: 'Email',
//                 hintText: 'Enter your email',
//                 controller: emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 prefixIcon: const Icon(Icons.email),
//                                 // onChanged: () {},

//               ),
//               const SizedBox(height: 16),

//               const Spacer(),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Column(
//                   children: [
//                     Buttons(
//                       buttonText: 'Continue',
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => emailverification()));
//                         // Handle form submission
//                         print('Email: ${emailController.text}');
//                         print('Password: ${passwordController.text}');
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
