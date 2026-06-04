import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_tokens.dart';

// Re-export tokens so `import 'app_theme.dart'` also gets AppColors/AppSpacing/etc.
export 'app_tokens.dart';

class AppTheme {
  const AppTheme._();

  /// Status/nav bar styling — transparent bars; icon brightness flips with theme.
  static SystemUiOverlayStyle overlayFor(Brightness brightness) {
    final iconsLight = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: iconsLight ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: AppColors.bg,
      systemNavigationBarIconBrightness: iconsLight ? Brightness.light : Brightness.dark,
    );
  }

  /// Build the theme from the current [AppColors] for the given brightness.
  /// Call [AppColors.applyTheme] / [AppColors.applyAccent] first.
  static ThemeData theme(Brightness brightness) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      outline: AppColors.border,
    );

    // Type pairing (bundled Fontshare assets — see pubspec.yaml):
    //   ClashDisplay → expressive headlines/display (weights 400/500/600/700)
    //   Satoshi      → body + UI text (weights 400/500/700)
    const display = 'ClashDisplay';
    const body = 'Satoshi';
    final textTheme = base.textTheme
        .apply(
          fontFamily: body,
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        )
        .copyWith(
          displayLarge: const TextStyle(
            fontFamily: display, fontSize: 56, fontWeight: FontWeight.w700,
            letterSpacing: -2, height: 1.0,
          ).copyWith(color: AppColors.textPrimary),
          displayMedium: const TextStyle(
            fontFamily: display, fontSize: 44, fontWeight: FontWeight.w700,
            letterSpacing: -1.5, height: 1.05,
          ).copyWith(color: AppColors.textPrimary),
          headlineSmall: const TextStyle(
            fontFamily: display, fontSize: 26, fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ).copyWith(color: AppColors.textPrimary),
          titleMedium: const TextStyle(
            fontFamily: display, fontSize: 17, fontWeight: FontWeight.w600,
          ).copyWith(color: AppColors.textPrimary),
          bodyLarge: const TextStyle(
            fontFamily: body, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
          ).copyWith(color: AppColors.textMuted),
          bodyMedium: const TextStyle(
            fontFamily: body, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5,
          ).copyWith(color: AppColors.textMuted),
          labelLarge: const TextStyle(
            fontFamily: body, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2,
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
        systemOverlayStyle: overlayFor(brightness),
        titleTextStyle: textTheme.headlineSmall,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border, thickness: 1, space: 1,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    );
  }
}
