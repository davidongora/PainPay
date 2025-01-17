// import 'package:flutter/material.dart';
// import 'package:pain_pay/Nav/payment/paiment/qr_code_scanner.dart';
// import 'package:pain_pay/Onboarding/contacts_page.dart';
// import 'package:pain_pay/shared/app_bar.dart';

// class Pay extends StatelessWidget {
//   const Pay({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: ('Pay'),
//       ),
//       floatingActionButton: FloatingActionButton(onPressed: () {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => QrCodeScanner(
//                       setResult: (result) {
//                         print(result);
//                       },
//                     )));
//       }),
//       body: Center(
//         child: ContactsPage(),
//       ),
//     );
//   }
// }
