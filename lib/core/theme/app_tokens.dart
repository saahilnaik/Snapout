import 'package:flutter/material.dart';

/// Design tokens — the single source of truth for color, spacing, radius, and
/// motion. Keep values here; screens/components reference these, never literals.
///
/// Aesthetic: professional, minimal, Gen-Z. Restrained dark canvas, one precise
/// neon-lime accent used sparingly, generous whitespace, smooth subtle motion.
class AppColors {
  AppColors._();

  // Surfaces — mutable for light/dark. Defaults are the dark palette.
  static Color bg = const Color(0xFF0A0B0D);
  static Color surface = const Color(0xFF131519);
  static Color surfaceHigh = const Color(0xFF1C1F24);
  static Color border = const Color(0xFF262A30);

  // The one accent — mutable so Pro users can re-theme it. Changing these and
  // rebuilding the app root recolors everything that reads them.
  static Color accent = const Color(0xFFBFFF00);
  static Color accentSoft = const Color(0x24BFFF00); // ~14% accent — set in applyAccent
  static Color onAccent = const Color(0xFF0A0B0D);

  // Text — mutable for light/dark.
  static Color textPrimary = const Color(0xFFF4F5F7);
  static Color textMuted = const Color(0xFF9BA1AC);
  static Color textFaint = const Color(0xFF6B7280);

  /// Apply an accent preset. accentSoft is a translucent accent so it tints
  /// correctly on either a light or dark surface.
  static void applyAccent(AccentPreset p) {
    accent = p.accent;
    onAccent = p.onAccent;
    accentSoft = p.accent.withValues(alpha: 0.14);
  }

  /// Swap the surface + text palette for the given brightness.
  static void applyTheme(Brightness brightness) {
    if (brightness == Brightness.light) {
      bg = const Color(0xFFF6F7F9);
      surface = const Color(0xFFFFFFFF);
      surfaceHigh = const Color(0xFFEDEFF3);
      border = const Color(0xFFE2E5EA);
      textPrimary = const Color(0xFF14161A);
      textMuted = const Color(0xFF5A616B);
      textFaint = const Color(0xFF99A0AA);
    } else {
      bg = const Color(0xFF0A0B0D);
      surface = const Color(0xFF131519);
      surfaceHigh = const Color(0xFF1C1F24);
      border = const Color(0xFF262A30);
      textPrimary = const Color(0xFFF4F5F7);
      textMuted = const Color(0xFF9BA1AC);
      textFaint = const Color(0xFF6B7280);
    }
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
