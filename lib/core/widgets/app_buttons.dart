import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Primary call-to-action — lime fill, dark label. The dominant tap target.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: AppSpacing.sm)],
        Text(label),
      ],
    );
    return SizedBox(
      width: expand ? double.infinity : null,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: AppColors.surfaceHigh,
          disabledForegroundColor: AppColors.textFaint,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: Theme.of(context).textTheme.labelLarge,
        ),
        child: child,
      ),
    );
  }
}

/// Secondary / quieter action — outlined, no fill. Visually recessive.
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: AppSpacing.sm)],
        Text(label),
      ],
    );
    return SizedBox(
      width: expand ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: Theme.of(context).textTheme.labelLarge,
        ),
        child: child,
      ),
    );
  }
}
