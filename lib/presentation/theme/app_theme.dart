import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.lightOnBackground),
        displayMedium: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.lightOnBackground),
        bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.lightOnBackground),
        bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.lightOnSurface),
        labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
        bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.lightOnSurface),
      ),

      cardTheme: CardTheme(
        elevation: 2,
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.lightOnSurface, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ), colorScheme: ColorScheme(surface: AppColors.lightSurface),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,

      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkOnBackground),
        displayMedium: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkOnBackground),
        bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.darkOnBackground),
        bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.darkOnSurface),
        labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
        bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.darkOnSurface),
      ),

      cardTheme: CardTheme(
        elevation: 4,
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.darkOnSurface, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ), colorScheme: ColorScheme(surface: AppColors.darkSurface),
    );
  }
}