import 'package:flutter/material.dart';

abstract class AppColors {
  AppColors._(); // Prevents instantiation

  // --- 1. Base/Overall Colors (The descriptive names) ---
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightCyan = Color(0xFFd1ebeb);
  static const Color cyan = Color(0xFF57d9dd);
  static const Color dirtyCyan = Color(0xFF77c5c5);
  static const Color darkTurquoise = Color(0xFF0097b2);
  static const Color darkAzure = Color(0xFF006274);
  static const Color darkGrayAzure = Color(0xFF273538);
  
  // --- 2. Functional/Semantic Colors (Reference the base colors) ---
  
  // Primary (The main action color, based on darkTurquoise)
  static const Color primaryBlue = darkTurquoise; 
  // Accent (For highlights and important actions, based on cyan)
  static const Color accentRed = Color(0xFFe63946);
  
  // Surfaces & Backgrounds
  static const Color surfaceLight = lightCyan; 
  static const Color scaffoldBackground = pureWhite; 
  
  // Text & Contrast Colors
  static const Color textLight = pureWhite;
  static const Color textDark = darkGrayAzure;
}
