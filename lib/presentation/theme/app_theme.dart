import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // THEME IS NOW A DYNAMIC FUNCTION
  static ThemeData getTheme({
    required Brightness brightness,
    required Color accentColor,
  }) {
    final isLight = brightness == Brightness.light;
    final backgroundColor = isLight ? AppColors.lightBackground : AppColors.darkBackground;
    final surfaceColor = isLight ? AppColors.lightSurface : AppColors.darkSurface;
    final onBackgroundColor = isLight ? AppColors.lightOnBackground : AppColors.darkOnBackground;
    final onSurfaceColor = isLight ? AppColors.lightOnSurface : AppColors.darkOnSurface;

    return ThemeData(
      brightness: brightness,
      primaryColor: accentColor,
      scaffoldBackgroundColor: backgroundColor,
      
      textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: brightness).textTheme).copyWith(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: onBackgroundColor),
        displayMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: onBackgroundColor),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: onBackgroundColor),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: onSurfaceColor),
        labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: onSurfaceColor),
      ),

      cardTheme: CardTheme(
        elevation: isLight ? 2 : 4,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: onSurfaceColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      ), colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: brightness,
        primary: accentColor,
        surface: surfaceColor
      ).copyWith(surface: surfaceColor, error: AppColors.error),
    );
  }
}