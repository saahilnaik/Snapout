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

  // The one accent — mutable so Pro users can re-theme it. Changing these and
  // rebuilding the app root recolors everything that reads them.
  static Color accent = const Color(0xFFBFFF00);
  static Color accentSoft = const Color(0xFF2B330A); // tinted fill on dark
  static Color onAccent = const Color(0xFF0A0B0D);

  // Text.
  static const Color textPrimary = Color(0xFFF4F5F7);
  static const Color textMuted = Color(0xFF9BA1AC);
  static const Color textFaint = Color(0xFF6B7280);

  /// Apply an accent preset (call before building the app theme).
  static void applyAccent(AccentPreset p) {
    accent = p.accent;
    accentSoft = p.accentSoft;
    onAccent = p.onAccent;
  }
}

/// A Pro accent option. No blues/purples (design rule).
class AccentPreset {
  const AccentPreset({
    required this.key,
    required this.name,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
  });

  final String key;
  final String name;
  final Color accent;
  final Color accentSoft;
  final Color onAccent;

  static const lime = AccentPreset(
    key: 'lime', name: 'Lime',
    accent: Color(0xFFBFFF00), accentSoft: Color(0xFF2B330A), onAccent: Color(0xFF0A0B0D),
  );
  static const amber = AccentPreset(
    key: 'amber', name: 'Amber',
    accent: Color(0xFFFFB300), accentSoft: Color(0xFF33260A), onAccent: Color(0xFF0A0B0D),
  );
  static const coral = AccentPreset(
    key: 'coral', name: 'Coral',
    accent: Color(0xFFFF6B5A), accentSoft: Color(0xFF331512), onAccent: Color(0xFF0A0B0D),
  );
  static const mint = AccentPreset(
    key: 'mint', name: 'Mint',
    accent: Color(0xFF28E0A0), accentSoft: Color(0xFF0A2B20), onAccent: Color(0xFF0A0B0D),
  );

  static const all = [lime, amber, coral, mint];

  static AccentPreset byKey(String key) =>
      all.firstWhere((p) => p.key == key, orElse: () => lime);
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
