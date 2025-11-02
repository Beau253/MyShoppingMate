import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';

  /// Saves the user's selected theme mode and accent color.
  Future<void> saveTheme(ThemeMode themeMode, Color accentColor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode.name);
    await prefs.setInt(_accentColorKey, accentColor.value);
  }

  /// Loads the user's saved theme mode.
  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (e) => e.name == themeName,
      orElse: () => ThemeMode.system, // Default to system
    );
  }

  /// Loads the user's saved accent color.
  Future<Color> loadAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_accentColorKey);
    // Default to the primary blue color if nothing is saved.
    return Color(colorValue ?? 0xFF357AF6);
  }
}