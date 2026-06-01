import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/fade_slide_in.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final stats = ref.watch(statsProvider);
    final hours = stats.minutesSaved ~/ 60;
    final mins = stats.minutesSaved % 60;
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
                      Text('${hours}h ${mins}m',
                          style: t.displayLarge?.copyWith(color: AppColors.accent)),
                      const SizedBox(height: 4),
                      Text(
                        stats.totalSkips == 0
                            ? 'Skipped opens add up. Start protecting an app to see this grow.'
                            : 'Estimated from ${stats.totalSkips} skipped opens (~15 min each).',
                        style: t.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: Row(
                  children: [
                    Expanded(child: _Metric(value: '${stats.totalSkips}', label: 'Total skips')),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                        child: _Metric(
                            value: '${stats.streakDays}', label: 'Day streak', accent: true)),
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
                      _WeekBars(counts: stats.weekSkips),
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
  const _WeekBars({required this.counts});
  final List<int> counts;
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final max = counts.fold<int>(0, (m, c) => c > m ? c : m);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 7; i++)
          Column(
            children: [
              if (counts[i] > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${counts[i]}',
                      style: t.bodyMedium?.copyWith(fontSize: 11, color: AppColors.accent)),
                ),
              Container(
                width: 26,
                height: counts[i] == 0 ? 6.0 : 16.0 + 64.0 * (counts[i] / (max == 0 ? 1 : max)),
                decoration: BoxDecoration(
                  color: counts[i] > 0 ? AppColors.accent : AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(_days[i], style: t.bodyMedium?.copyWith(fontSize: 12)),
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
