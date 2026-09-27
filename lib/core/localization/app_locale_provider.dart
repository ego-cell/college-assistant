import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class AppLocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar'); // Default to Arabic as requested

  AppLocaleProvider() {
    _loadLocale();
  }

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString(AppConstants.keyLocale);
      if (langCode != null && (langCode == 'ar' || langCode == 'en')) {
        _locale = Locale(langCode);
        notifyListeners();
      }
    } catch (_) {
      // Fallback to default
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyLocale, newLocale.languageCode);
    } catch (_) {}
  }

  Future<void> toggleLocale() async {
    final newCode = _locale.languageCode == 'ar' ? 'en' : 'ar';
    await setLocale(Locale(newCode));
  }
}
