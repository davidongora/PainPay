// showcase_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ShowcaseManager extends ChangeNotifier {
  static const String _key = 'has_shown_showcase';
  bool _hasShownShowcase = false;

  ShowcaseManager() {
    _loadShowcaseStatus();
  }

  bool get hasShownShowcase => _hasShownShowcase;

  Future<void> _loadShowcaseStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _hasShownShowcase = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> markShowcaseAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    _hasShownShowcase = true;
    notifyListeners();
  }

  Future<void> resetShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
    _hasShownShowcase = false;
    notifyListeners();
  }
}
