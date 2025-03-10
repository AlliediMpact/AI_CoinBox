import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primaryBlue = Color(0xFF193281);
  static const Color primaryPurple = Color(0xFF5E17EB);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Basic colors
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  
  // UI colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFE0E0E0);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
}