import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/providers.dart';
import '../../../core/services/stats_store.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/fade_slide_in.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  final _shareCardKey = GlobalKey();

  Future<void> _shareCard() async {
    try {
      final boundary =
          _shareCardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!
          .buffer
          .asUint8List();
      final file = File('${Directory.systemTemp.path}/snapout_stats.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: 'My focus stats, courtesy of SnapOut 🌿',
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't create the card.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stats = ref.watch(statsProvider);
    final isPro = ref.watch(proProvider).isPro;
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
                child: isPro
                    ? _ProStatsSection(
                        shareCardKey: _shareCardKey,
                        stats: stats,
                        onShare: _shareCard,
                      )
                    : const _LockedProCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProStatsSection extends StatelessWidget {
  const _ProStatsSection({
    required this.shareCardKey,
    required this.stats,
    required this.onShare,
  });

  final GlobalKey shareCardKey;
  final StatsSummary stats;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RepaintBoundary(
          key: shareCardKey,
          child: _ShareCard(stats: stats),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Share my stats',
          icon: Icons.ios_share_rounded,
          onPressed: onShare,
        ),
      ],
    );
  }
}

/// The branded card captured for sharing.
class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.stats});
  final StatsSummary stats;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final hours = stats.minutesSaved ~/ 60;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accentSoft, AppColors.bg],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [SnapMark(size: 28), SizedBox(width: AppSpacing.sm), Wordmark(fontSize: 22)],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('I snapped out', style: t.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ShareStat(value: '${stats.totalSkips}', label: 'skips'),
              const SizedBox(width: AppSpacing.xl),
              _ShareStat(value: '${stats.streakDays}', label: 'day streak'),
              const SizedBox(width: AppSpacing.xl),
              _ShareStat(value: '${hours}h', label: 'saved'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareStat extends StatelessWidget {
  const _ShareStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: t.displayMedium?.copyWith(fontSize: 36, color: AppColors.accent)),
        Text(label, style: t.bodyMedium?.copyWith(fontSize: 12)),
      ],
    );
  }
}

class _LockedProCard extends StatelessWidget {
  const _LockedProCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColors.textFaint),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shareable stats card', style: t.titleMedium),
                const SizedBox(height: 2),
                Text('Part of SnapOut Pro', style: t.bodyMedium?.copyWith(fontSize: 13)),
              ],
            ),
          ),
          _ProBadge(),
        ],
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
