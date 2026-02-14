import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization.dart';

class LanguageManager {
  static const String _languageKey = 'app_language';
  static AppLanguage _currentLanguage = AppLanguage.en;
  static final ValueNotifier<AppLanguage> _languageNotifier = ValueNotifier(AppLanguage.en);

  static AppLanguage get currentLanguage => _currentLanguage;
  static ValueNotifier<AppLanguage> get languageNotifier => _languageNotifier;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);

    if (languageCode != null) {
      _currentLanguage = _languageFromString(languageCode);
      _languageNotifier.value = _currentLanguage;
    }
  }

  static Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    _languageNotifier.value = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, _languageToString(language));
  }

  static String _languageToString(AppLanguage language) {
    switch (language) {
      case AppLanguage.cs:
        return 'cs';
      case AppLanguage.sk:
        return 'sk';
      case AppLanguage.hu:
        return 'hu';
      case AppLanguage.en:
        return 'en';
      case AppLanguage.de:
        return 'de';
      case AppLanguage.fr:
        return 'fr';
      case AppLanguage.es:
        return 'es';
      case AppLanguage.pt:
        return 'pt';
    }
  }

  static AppLanguage _languageFromString(String code) {
    switch (code) {
      case 'cs':
        return AppLanguage.cs;
      case 'sk':
        return AppLanguage.sk;
      case 'hu':
        return AppLanguage.hu;
      case 'en':
        return AppLanguage.en;
      case 'de':
        return AppLanguage.de;
      case 'fr':
        return AppLanguage.fr;
      case 'es':
        return AppLanguage.es;
      case 'pt':
        return AppLanguage.pt;
      default:
        return AppLanguage.en;
    }
  }

  static Locale toLocale(AppLanguage language) {
    return Locale(_languageToString(language));
  }
}
