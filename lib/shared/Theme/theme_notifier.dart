import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pain_pay/shared/colors.dart';
import 'package:flutter/services.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // Light theme
  ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.theme),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      );

  // Dark theme
  ThemeData get darkTheme => ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.theme),
        // textTheme: GoogleFonts.poppinsTextTheme(),
        // listTileTheme: ThemeData.dark() ,
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        useMaterial3: true,
      );

  void setGreenStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF007438), // Green color for the status bar
      statusBarIconBrightness: Brightness.light, // Light icons for readability
    ));
  }
}
