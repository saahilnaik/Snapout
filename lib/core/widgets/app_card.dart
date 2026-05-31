import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Surface container with a hairline border and rounded corners.
/// The default building block for grouped content.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}
