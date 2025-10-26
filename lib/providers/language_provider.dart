import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _currentLocale = const Locale('en');

  LanguageProvider() {
    _loadLanguage();
  }

  Locale get currentLocale => _currentLocale;

  String get currentLanguageName {
    return _getLanguageName(_currentLocale.languageCode);
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);

    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) {
      return;
    }

    _currentLocale = Locale(languageCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  String _getLanguageName(String code) {
    final languages = {
      'en': 'English',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'it': 'Italiano',
      'pt': 'Português',
      'ru': 'Русский',
      'zh': '中文',
      'ja': '日本語',
      'ko': '한국어',
      'ar': 'العربية',
      'hi': 'हिन्दी',
      'id': 'Bahasa Indonesia',
      'tr': 'Türkçe',
      'nl': 'Nederlands',
      'ta': 'தமிழ்',
      'te': 'తెలుగు',
      'ml': 'മലയാളം',
    };
    return languages[code] ?? 'English';
  }

  List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español'},
      {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
      {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch'},
      {'code': 'it', 'name': 'Italian', 'nativeName': 'Italiano'},
      {'code': 'pt', 'name': 'Portuguese', 'nativeName': 'Português'},
      {'code': 'ru', 'name': 'Russian', 'nativeName': 'Русский'},
      {'code': 'zh', 'name': 'Chinese', 'nativeName': '中文'},
      {'code': 'ja', 'name': 'Japanese', 'nativeName': '日本語'},
      {'code': 'ko', 'name': 'Korean', 'nativeName': '한국어'},
      {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
      {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
      {'code': 'id', 'name': 'Indonesian', 'nativeName': 'Bahasa Indonesia'},
      {'code': 'tr', 'name': 'Turkish', 'nativeName': 'Türkçe'},
      {'code': 'nl', 'name': 'Dutch', 'nativeName': 'Nederlands'},
      {'code': 'ta', 'name': 'Tamil', 'nativeName': 'தமிழ்'},
      {'code': 'te', 'name': 'Telugu', 'nativeName': 'తెలుగు'},
      {'code': 'ml', 'name': 'Malayalam', 'nativeName': 'മലയാളം'},
    ];
  }
}