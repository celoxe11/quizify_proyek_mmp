import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // Use a primary color from constants to seed the Material 3 ColorScheme
  static const Color _seedColor = AppColors.primaryBlue;

  static final mainTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.fredoka().fontFamily,
    textTheme: GoogleFonts.fredokaTextTheme(),
    brightness:
        Brightness.light, // Set the default brightness (can be Light or Dark)
    // Generate a ColorScheme based on the primary color
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      // You can manually assign specific colors if needed:
      primary: AppColors.primaryBlue,
      secondary: AppColors.accentRed,

      surface: AppColors.surfaceLight, // For cards, sheets, etc.
      onSurface: AppColors.textDark, // Text color on surfaces
    ),

    // Customize core widget themes
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.pureWhite,
      foregroundColor: AppColors.darkTurquoise, // Text/icon color on the AppBar
      centerTitle: true,
      elevation: 0,
    ),

    // Customize Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textLight,
      ),
    ),

    // Customize Card Theme (applies globally)
    // cardTheme: CardThemeData(
    //   color: AppColors.textLight, // Default white/light card color
    //   elevation: 2,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    // ),

    // Extensions are optional if you don't need them yet, but here's how to include one:
    // extensions: <ThemeExtension<dynamic>>[
    //   // If you were to add one later, it would go here.
    // ],
  );
}
