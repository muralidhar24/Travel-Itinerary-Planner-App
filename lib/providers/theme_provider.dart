import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final storedThemeModeIndex = prefs.getInt(_themeModeKey);

    if (storedThemeModeIndex == null) {
      return;
    }

    if (storedThemeModeIndex < 0 || storedThemeModeIndex >= ThemeMode.values.length) {
      return;
    }

    final storedThemeMode = ThemeMode.values[storedThemeModeIndex];
    if (storedThemeMode != _themeMode) {
      _themeMode = storedThemeMode;
      notifyListeners();
    }
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    await setThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) {
      return;
    }

    _themeMode = themeMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, themeMode.index);
  }
}