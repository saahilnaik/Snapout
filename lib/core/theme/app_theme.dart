import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

// Re-export tokens so `import 'app_theme.dart'` also gets AppColors/AppSpacing/etc.
export 'app_tokens.dart';

class AppTheme {
  const AppTheme._();

  /// Status/nav bar styling — transparent bars, light icons on our dark canvas.
  static const SystemUiOverlayStyle systemUiOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  );

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
      outline: AppColors.border,
    );

    // TODO(fonts): swap to Clash Display / Satoshi (Fontshare) once bundled as
    // local assets — google_fonts only serves the Google catalog. Space Grotesk
    // is the closest modern, bold stand-in.
    final textTheme = GoogleFonts.spaceGroteskTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary)
        .copyWith(
          displayLarge: GoogleFonts.spaceGrotesk(
            fontSize: 56, fontWeight: FontWeight.w700, letterSpacing: -2,
            color: AppColors.textPrimary, height: 1.0,
          ),
          displayMedium: GoogleFonts.spaceGrotesk(
            fontSize: 44, fontWeight: FontWeight.w700, letterSpacing: -1.5,
            color: AppColors.textPrimary, height: 1.05,
          ),
          headlineSmall: GoogleFonts.spaceGrotesk(
            fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
          titleMedium: GoogleFonts.spaceGrotesk(
            fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
          ),
          bodyLarge: GoogleFonts.spaceGrotesk(
            fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textMuted, height: 1.5,
          ),
          bodyMedium: GoogleFonts.spaceGrotesk(
            fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textMuted, height: 1.5,
          ),
          labelLarge: GoogleFonts.spaceGrotesk(
            fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2,
          ),
        );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemUiOverlay,
        titleTextStyle: textTheme.headlineSmall,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border, thickness: 1, space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    );
  }
}
