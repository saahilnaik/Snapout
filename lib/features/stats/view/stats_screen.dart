import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/fade_slide_in.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time saved', style: t.bodyMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text('0h 0m',
                          style: t.displayLarge?.copyWith(color: AppColors.accent)),
                      const SizedBox(height: 4),
                      Text('Skipped opens add up. Start protecting an app to see this grow.',
                          style: t.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: Row(
                  children: const [
                    Expanded(child: _Metric(value: '0', label: 'Total skips')),
                    SizedBox(width: AppSpacing.md),
                    Expanded(child: _Metric(value: '0', label: 'Day streak', accent: true)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('This week', style: t.titleMedium),
                      const SizedBox(height: AppSpacing.xl),
                      const _WeekBars(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: const Duration(milliseconds: 240),
                child: AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded, color: AppColors.textFaint),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('30-day insights & shareable card', style: t.titleMedium),
                            const SizedBox(height: 2),
                            Text('Part of SnapOut Pro', style: t.bodyMedium?.copyWith(fontSize: 13)),
                          ],
                        ),
                      ),
                      _ProBadge(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label, this.accent = false});
  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: t.displayMedium?.copyWith(
                fontSize: 36,
                color: accent ? AppColors.accent : AppColors.textPrimary,
              )),
          const SizedBox(height: 2),
          Text(label, style: t.bodyMedium?.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}

class _WeekBars extends StatelessWidget {
  const _WeekBars();
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final d in _days)
          Column(
            children: [
              Container(
                width: 26,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(d, style: t.bodyMedium?.copyWith(fontSize: 12)),
            ],
          ),
      ],
    );
  }
}

class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text('PRO',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.onAccent,
                fontSize: 12,
              )),
    );
  }
}
