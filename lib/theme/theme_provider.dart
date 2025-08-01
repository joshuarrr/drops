import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _kThemeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeData getTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isSystemDark = brightness == Brightness.dark;

    if (_themeMode == ThemeMode.system) {
      return isSystemDark ? AppTheme.darkTheme : AppTheme.lightTheme;
    }

    return _themeMode == ThemeMode.dark
        ? AppTheme.darkTheme
        : AppTheme.lightTheme;
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
    _saveThemeMode();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _saveThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_kThemeModeKey);
      if (savedTheme != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.system,
        );
        notifyListeners();
      }
    } catch (e, stack) {
      debugPrint('ThemeProvider: Failed to load theme mode → $e\n$stack');
    }
  }

  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemeModeKey, _themeMode.toString());
    } catch (e, stack) {
      debugPrint('ThemeProvider: Failed to save theme mode → $e\n$stack');
    }
  }
}
