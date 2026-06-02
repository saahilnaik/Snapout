import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Minimal brand mark: a lime breathing ring with a soft inner glow.
/// Echoes the core interaction (pause / breathe).
class SnapMark extends StatelessWidget {
  const SnapMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: size * 0.1),
        color: AppColors.accentSoft,
      ),
      child: Center(
        child: Container(
          width: size * 0.28,
          height: size * 0.28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}

/// "SnapOut" wordmark — restrained: white with a lime second half.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.fontSize = 44});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: fontSize);
    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: 'Snap', style: TextStyle(color: AppColors.textPrimary)),
          TextSpan(text: 'Out', style: TextStyle(color: AppColors.accent)),
        ],
      ),
    );
  }
}
