import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Initialize with true (dark mode), then load preference
    _loadThemePreference();
    return true;
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getBool('isDarkMode') ?? true;
      state = savedTheme;
    } catch (e) {
      state = true;
    }
  }

  Future<void> toggleTheme() async {
    final newTheme = !state;
    state = newTheme;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', newTheme);
    } catch (e) {
      // Handle error silently or log it
    }
  }

  Future<void> setTheme(bool isDark) async {
    state = isDark;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDark);
    } catch (e) {
      // Handle error silently or log it
    }
  }

  bool get isDarkMode => state;
}

// Riverpod provider - declared only once
final themeProvider = NotifierProvider<ThemeNotifier, bool>(() {
  return ThemeNotifier();
});
