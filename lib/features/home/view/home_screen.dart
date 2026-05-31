import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

/// Branded placeholder home — the Session 1 "hello-world".
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'SnapOut',
                style: t.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your phone's bouncer.",
                style: t.titleMedium?.copyWith(color: AppColors.textMuted),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.push('/onboarding'),
                child: const Text('Start onboarding'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push('/stats'),
                      child: const Text('Stats'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push('/settings'),
                      child: const Text('Settings'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
