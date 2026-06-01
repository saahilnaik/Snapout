import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/services/protected_apps_store.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/fade_slide_in.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final apps = ref.watch(protectedAppsProvider);
    final stats = ref.watch(statsProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                child: Row(
                  children: [
                    const SnapMark(size: 36),
                    const SizedBox(width: AppSpacing.md),
                    const Wordmark(fontSize: 26),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text('Free', style: t.bodyMedium?.copyWith(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: _StatusHero(textTheme: t, apps: apps),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: Row(
                  children: [
                    Expanded(
                        child: _MiniStat(
                            label: 'Skipped today',
                            value: '${stats.todaySkipped}',
                            accent: true)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                        child: _MiniStat(
                            label: 'Opened today', value: '${stats.todayOpened}')),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeSlideIn(
                delay: const Duration(milliseconds: 240),
                child: PrimaryButton(
                  label: apps.isEmpty ? 'Add an app to protect' : 'Manage protected apps',
                  icon: apps.isEmpty ? Icons.add_rounded : Icons.tune_rounded,
                  onPressed: () => context.push('/onboarding'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FadeSlideIn(
                delay: const Duration(milliseconds: 300),
                child: GhostButton(
                  label: 'Preview the breathing exercise',
                  icon: Icons.air_rounded,
                  onPressed: () => context.push('/breathing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.textTheme, required this.apps});
  final TextTheme textTheme;
  final List<ProtectedApp> apps;

  @override
  Widget build(BuildContext context) {
    final protecting = apps.isNotEmpty;
    final title = 'Guarding ${apps.length} app${apps.length == 1 ? '' : 's'}';
    final subtitle = protecting
        ? apps.map((a) => a.name).join(', ')
        : 'Not protecting anything yet';
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SnapMark(size: 56),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(subtitle, style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            protecting
                ? "When you open it, SnapOut steps in for 3 breaths first — so you choose, not the habit."
                : "Pick an app you doomscroll. SnapOut makes you take 3 breaths before it opens — so you choose, not the habit.",
            style: textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.accent = false});
  final String label;
  final String value;
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
                fontSize: 40,
                color: accent ? AppColors.accent : AppColors.textPrimary,
              )),
          const SizedBox(height: 2),
          Text(label, style: t.bodyMedium?.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}
