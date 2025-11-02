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
      backgroundColor: AppColors.lightSurface,
      
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        headline1: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.lightOnBackground),
        headline2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.lightOnBackground),
        bodyText1: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.lightOnBackground),
        bodyText2: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.lightOnSurface),
        button: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
        caption: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.lightOnSurface),
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
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      backgroundColor: AppColors.darkSurface,

      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        headline1: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkOnBackground),
        headline2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkOnBackground),
        bodyText1: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.darkOnBackground),
        bodyText2: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.darkOnSurface),
        button: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
        caption: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.darkOnSurface),
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
      ),
    );
  }
}