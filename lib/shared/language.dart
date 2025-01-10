// import 'package:flutter/material.dart';
// import 'l10n/generated/app_localizations.dart';

// class HomeScreen extends StatelessWidget {
//   final void Function(Locale) onLocaleChange;

//   const HomeScreen({super.key, required this.onLocaleChange});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(AppLocalizations.of(context)!.welcome_message),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: DropdownButton<Locale>(
//               value: Localizations.localeOf(context),
//               underline: const SizedBox(), // Removes the default underline
//               icon: const Icon(Icons.language, color: Colors.white),
//               dropdownColor: Colors.white,
//               items: const [
//                 DropdownMenuItem(
//                   value: Locale('en'),
//                   child: Text('English'),
//                 ),
//                 DropdownMenuItem(
//                   value: Locale('fr'),
//                   child: Text('Français'),
//                 ),
//               ],
//               onChanged: (Locale? newLocale) {
//                 if (newLocale != null) {
//                   onLocaleChange(newLocale); // Update the locale
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//       body: Center(
//         child: Text(AppLocalizations.of(context)!.welcome_message),
//       ),
//     );
//   }
// }
