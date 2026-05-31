import 'package:flutter/material.dart';

/// Design tokens — the single source of truth for color, spacing, radius, and
/// motion. Keep values here; screens/components reference these, never literals.
///
/// Aesthetic: professional, minimal, Gen-Z. Restrained dark canvas, one precise
/// neon-lime accent used sparingly, generous whitespace, smooth subtle motion.
class AppColors {
  AppColors._();

  // Surfaces — cool near-blacks, layered by elevation.
  static const Color bg = Color(0xFF0A0B0D);
  static const Color surface = Color(0xFF131519);
  static const Color surfaceHigh = Color(0xFF1C1F24);
  static const Color border = Color(0xFF262A30);

  // The one accent. Use sparingly — primary actions, key highlights.
  static const Color accent = Color(0xFFBFFF00);
  static const Color accentSoft = Color(0xFF2B330A); // tinted fill on dark
  static const Color onAccent = Color(0xFF0A0B0D);

  // Text.
  static const Color textPrimary = Color(0xFFF4F5F7);
  static const Color textMuted = Color(0xFF9BA1AC);
  static const Color textFaint = Color(0xFF6B7280);
}

/// 4-pt spacing scale.
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Corner radii.
class AppRadius {
  AppRadius._();
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;
}

/// Motion — short, smooth, never gimmicky.
class AppMotion {
  AppMotion._();
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Curve curve = Curves.easeOutCubic;
}
