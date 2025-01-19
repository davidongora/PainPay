// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:pain_pay/services/notification_service.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String? _token;

//   @override
//   void initState() {
//     super.initState();
//     _fetchToken();
//   }

//   Future<void> _fetchToken() async {
//     try {
//       final FirebaseMessaging messaging = FirebaseMessaging.instance;
//       final String? token = await messaging.getToken();
//       setState(() {
//         _token = token;
//       });
//       print("FCM Token: $_token");
//     } catch (e) {
//       print("Error fetching FCM token: $e");
//     }
//   }

//   Future<void> _sendTestNotification() async {
//     if (_token == null) {
//       print("Token is null. Unable to send notification.");
//       return;
//     }

//     final notificationService = NotificationService();
//     final success = await notificationService.sendNotification(
//       recipientToken: _token!,
//       title: "Test Notification",
//       body: "This is a test notification sent from the app.",
//       data: {"key": "value"},
//     );

//     if (success) {
//       print("Test notification sent successfully!");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Notification sent successfully!")),
//       );
//     } else {
//       print("Failed to send test notification.");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to send notification.")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("FCM Token")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _token != null
//                 ? Text(
//                     "FCM Token:\n$_token",
//                     textAlign: TextAlign.center,
//                   )
//                 : CircularProgressIndicator(),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _sendTestNotification,
//               child: Text("Send Test Notification"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
