import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SnapOut palette — dark default, neon lime accent.
/// No blue/purple gradients, no serifs (see CLAUDE.md design rules).
class AppColors {
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF16181A);
  static const Color surfaceHigh = Color(0xFF1F2225);

  /// Neon lime — the one and only accent.
  static const Color accent = Color(0xFFBFFF00);
  static const Color accentDim = Color(0xFF7A9E00);

  /// Text/icons sitting on top of the lime accent.
  static const Color onAccent = Color(0xFF0A0A0A);

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textMuted = Color(0xFF8A8F98);
}

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    );

    // TODO(fonts): swap to Clash Display / Satoshi (Fontshare) once bundled as
    // local assets — google_fonts only serves the Google catalog. Space Grotesk
    // is the closest modern, bold stand-in available there.
    final textTheme = GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
