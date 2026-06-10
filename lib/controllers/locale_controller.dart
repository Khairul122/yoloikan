import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's language preference and persists it.
class LocaleController extends ChangeNotifier {
  static const _prefsKey = 'app_locale';

  Locale _locale = const Locale('id');

  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == 'en') {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('id');
    }
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    _locale = Locale(code);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
  }
}
