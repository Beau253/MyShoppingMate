import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const _themeModeKey = 'theme_mode';
  static const _accentColorKey = 'accent_color';

  Future<void> saveTheme(ThemeMode themeMode, Color accentColor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, themeMode.index);
    await prefs.setInt(_accentColorKey, accentColor.toARGB32());
  }

  Future<(ThemeMode, Color)> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load ThemeMode, default to system
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    final themeMode = ThemeMode.values[themeModeIndex];

    // Load accent color, default to a nice blue
    final accentColorValue = prefs.getInt(_accentColorKey) ?? Colors.blue.toARGB32();
    final accentColor = Color(accentColorValue);

    return (themeMode, accentColor);
  }
}