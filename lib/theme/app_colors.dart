import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF2E5AAC); // Indigo-ish
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFDEE7FF);
  static const Color onPrimaryContainer = Color(0xFF0F204A);

  static const Color secondary = Color(0xFF00A8E8); // Cyan/Aqua
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFD1F2FF);
  static const Color onSecondaryContainer = Color(0xFF073A4A);

  static const Color tertiary = Color(0xFF2E7D32); // Success green
  static const Color onTertiary = Colors.white;

  // Surfaces
  static const Color background = Color(0xFFFDFDFE);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceVariant = Color(0xFFF1F3F5);

  // Text
  static const Color onSurface = Color(0xFF1E293B);
  static const Color onSurfaceVariant = Color(0xFF475569);

  // Outline/border
  static const Color outline = Color(0xFFCBD5E1);

  // Feedback
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFD32F2F);

  // Gradients
  static const List<Color> headerGradient = [
    Color(0xFF2E5AAC),
    Color(0xFF00A8E8),
  ];
}