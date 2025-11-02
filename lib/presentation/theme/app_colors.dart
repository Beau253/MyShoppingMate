import 'package:flutter/material.dart';

// This class holds all the static color values for the app.
class AppColors {
  // This prevents the class from being instantiated.
  AppColors._(); 

  // --- Primary Accent Color Palette ---
  // This is the main color that the user can potentially customize.
  // We'll use a nice, modern blue as the default.
  static const Color primary = Color(0xFF357AF6);
  static const Color primaryDark = Color(0xFF0B4FBC);

  // --- Light Theme Colors ---
  static const Color lightBackground = Color(0xFFF7F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF2D3748); // For text
  static const Color lightOnSurface = Color(0xFF4A5568);   // For secondary text

  // --- Dark Theme Colors ---
  static const Color darkBackground = Color(0xFF1A202C);
  static const Color darkSurface = Color(0xFF2D3748);
  static const Color darkOnBackground = Color(0xFFF7F9FC); // For text
  static const Color darkOnSurface = Color(0xFFEDF2F7);   // For secondary text

  // --- Common Colors ---
  static const Color success = Color(0xFF48BB78);
  static const Color error = Color(0xFFE53E3E);
  static const Color white = Color(0xFFFFFFFF);
  
}